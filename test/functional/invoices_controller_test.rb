require File.dirname(__FILE__) + '/../test_helper'

class InvoicesControllerTest < ActionController::TestCase
  fixtures :companies, :invoices, :invoice_lines, :taxes

  include Haltr::XmlValidation

  def setup
    User.current = nil
    @request.session[:user_id] = 2
  end

  test "must_redirect_if_not_configured" do
    # deconfigure onlinestore
    companies(:company1).destroy
    get :index, :id => 'onlinestore'
  end

  test 'facturae30' do
    get :show, :id => 4, :format => 'facturae30'
    assert_response :success
    xml = @response.body
    assert xml
    #TODO assert_equal [], facturae_errors_xsd(xml)
  end

  test 'facturae31' do
    get :show, :id => 4, :format => 'facturae31'
    assert_response :success
    xml = @response.body
    assert xml
    # TODO assert_equal [], facturae_errors_xsd(xml)
  end

  test 'facturae32' do
    Invoice.find(2).save!
    get :show, :id => 4, :format => 'facturae32'
    assert_response :success
    xml = @response.body
    assert xml
    assert_equal [], facturae_errors_xsd(xml)
  end

  test 'facturae_xml_i5_vat_excemption' do
    get :show, :id => 5, :format => 'facturae32'
    assert_response :success
    xml = @response.body
    assert_equal [], facturae_errors_online(xml)
  end

  test 'facturae_xml_i6_vat_and_charges' do
    get :show, :id => 6, :format => 'facturae32'
    assert_response :success
    xml = @response.body
    assert_equal [], facturae_errors_online(xml)
  end

  test 'facturae_xml_i7_vat_10_vat_20_and_charges' do
    get :show, :id => 7, :format => 'facturae32'
    assert_response :success
    xml = @response.body
    assert_equal [], facturae_errors_online(xml)
  end

  test 'biiubl20_xml_i4' do
    get :show, :id => 4, :format => 'biiubl20'
    assert_response :success
    xml = @response.body
    assert_equal [], ubl_errors(xml)
  end

  test 'biiubl20_xml_i5_vat_excemption' do
    get :show, :id => 5, :format => 'biiubl20'
    assert_response :success
    xml = @response.body
    assert_equal [], ubl_errors(xml)
  end

  test 'biiubl20_xml_i6_vat_and_charges' do
    get :show, :id => 6, :format => 'biiubl20'
    assert_response :success
    xml = @response.body
    assert_equal [], ubl_errors(xml)
  end

  test 'peppolubl20_xml_i7_vat_10_vat_20_and_charges' do
    get :show, :id => 7, :format => 'peppolubl20'
    assert_response :success
    xml = @response.body
    assert_equal [], ubl_errors(xml)
  end

  test 'facturae_xml_i8_vat_10_irpf_10_and_charges' do
    get :show, :id => 8, :format => 'facturae32'
    assert_response :success
    xml = @response.body
    assert_equal [], facturae_errors_online(xml)
  end

end
