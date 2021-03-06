/* Load file (located in relative path on the server) via AJAX (in synchronous mode) */
function loadFile(sUrl){

  var response;

  $.ajax({
    url: sUrl,
    method: 'get',
    dataType: 'text',
    async: false
  }).done( function(html) {
    response = html;
  }).fail( function(html) {
    alert('Something went wrong loading the xslt resource...');
  });

  return response;
}


function terms(){
  if ($('#invoice_terms').val() == "custom") {
    $('#invoice_due_date').prop('disabled', false);
    $('#due_date_cal').show();
  } else {
    $('#invoice_due_date').prop('disabled', true);
    $('#due_date_cal').hide();
  }
}

$(document).ready(function() {

  /* Bind update payment stuff in an issued invoice form */
  $('select#invoice_client_id').bind('ajax:success', function(evt, data, status, xhr){
    $('#payment_stuff').html(xhr.responseText);
    terms();
  })

  $(document).on('change', '#invoice_terms', function(e) {
    terms();
  });

  $(document).on('change', '#invoice_payment_method, #client_payment_method', function(e) {
    if ($(this).val()==13) {
      $('#payment_other').show();
    } else {
      $('#payment_other').hide();
    }
  });

  /* Called after an invoice line is added by cocoon
   *  taxNames exemple = "tax1 tax2 tax3"
   */
  $('#invoice_lines').bind('cocoon:after-insert', function(e, added_line) {
    var taxes = $('#invoice_lines').data('taxNames');
    var taxes_array = taxes.split(" ");
    for (var i = 0, length = taxes_array.length; i < length; i++) {
      global_tax_check_changed(taxes_array[i]);
      copy_last_line_tax(taxes_array[i]);
    };
  });

  $(document).on('change', '.global_tax', function(e) {
    tax_name = $(this).data('taxName');
    tax_code = $(this).val();
    global_tax_changed(tax_name,tax_code);
  });

  $(document).on('change', '.global_tax_check', function(e) {
    tax_name = $(this).data('taxName');
    global_tax_check_changed(tax_name);
  });

  $(document).on('change', '#client_taxcode', function(e) {
    client_taxcode_changed();
  });

  if ( $('#client_taxcode')[0] ) { client_taxcode_changed() };

});


function client_taxcode_changed() {
  var taxcode = $('#client_taxcode').val();
  // do nothing if rendering a short form
  // (on invoices / invoice_templates)
  // or if taxcode is empty
  if (!$('#client_taxcode').data('short') && taxcode != "") {
    $.ajax({
      url: $('#client_taxcode').data('checkCifUrl'),
      data: 'value=' + taxcode,
      dataType: "html"
    }).done(function( html ) {
      $("#cif_info").html(html);
    })
  }
}

/* Iterate over all selects of a tax and update its values */
function global_tax_changed(tax_name, tax_code) {
  $('select.tax_'+tax_name).each(function(index) {
    $('select.tax_'+tax_name).eq(index).val(tax_code);
  });
  // call tax_changed to show/hide tax comment if exempt
  tax_changed(tax_name,tax_code);
}

/* Update form when a tax becomes global or line-specific.
 * Enables/disables global tax selector and shows/hides per line ones.
 * Iterate over all selects of a tax and update its values
 */
function global_tax_check_changed(tax_name) {
  $('#'+tax_name+'_global').prop('disabled', $('#'+tax_name+'_multiple').prop('checked'));
  if ($('#'+tax_name+'_multiple').prop('checked')) {
    $('#'+tax_name+'_title').show();
    $('td.tax_'+tax_name).show();
  } else {
    global_tax_changed(tax_name,$('#'+tax_name+'_global').val());
    $('#'+tax_name+'_title').hide();
    $('td.tax_'+tax_name).hide();
  }
}

/* Copy last line tax percent */
function copy_last_line_tax(tax_name) {
  var last_value;
  var tax_selects = $('select.tax_'+tax_name);
  if (tax_selects.size() > 1) {
    last_value = $('select.tax_'+tax_name).eq(tax_selects.size() - 2).val();
  } else {
    last_value = $('#'+tax_name+'_global').val();
  }
  tax_selects.last().val(last_value);
}

/* A tax select has changed.
 * Show comment if selected value is exempt,
 * or hide it if there are no exempt selects for this tax.
 */
function tax_changed(tax_name, tax_code) {
  if (tax_code.match(/_E$/)) {
    $('#'+tax_name+'_comment').show();
  } else {
    var hide_comment = true;
    $('select.tax_'+tax_name).each(function(index) {
      if ($('select.tax_'+tax_name).eq(index).val().match(/_E$/)) {
        hide_comment = false;
      }
    });
    if ( hide_comment ) {
      $('#'+tax_name+'_comment').hide();
    }
  }
}

/*
 * Functions for received invoices view
 */

// shows form to send mail when refusing an invoice
// also hides form showed on show_accepted_form
function show_refused_form() {
  $("#invoice-refuse").show();
  $("#invoice-accept").hide();
}

// shows form to send mail when accepting an invoice
// also hides form showed on show_refused_form
function show_accepted_form() {
  $("#invoice-refuse").hide();
  $("#invoice-accept").show();
}

