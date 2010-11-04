module InvoicesHelper

  def status_column(invoice)
    if invoice.closed?
      link_to("Closed", {:action => :mark_not_sent, :id => invoice}, :style => 'color: blue;')
    elsif invoice.sent?
      link_to("Sent", {:action => :mark_closed, :id => invoice}, :style => 'color: green;')
    else
      link_to("New", :action => :mark_sent, :id => invoice)
    end
  end

  def clients_for_select
    Client.find(:all, :order => 'name', :conditions => ["project_id = ?", @project]).collect {|c| [ c.name, c.id ] }
  end

  def add_invoice_line_link(invoice_form)
    link_to_function 'Add line' do |page|
      invoice_form.fields_for(:invoice_lines, InvoiceLine.new, :child_index => 'NEW_RECORD') do |line_form|
        html = render(:partial => 'invoice_line', :locals => { :f => line_form })
        page << "$('invoice_lines').insert({ bottom: '#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()) });"
      end
    end
  end

end
