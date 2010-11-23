class InvoiceTemplatesController < ApplicationController 

  unloadable
  menu_item :haltr

  helper :invoices
  helper :sort
  include SortHelper

  before_filter :find_invoice_template, :except => [:index,:new,:create,:new_from_invoice]
  before_filter :find_project, :only => [:index,:new,:create]
  before_filter :find_invoice, :only => [:new_from_invoice]
  before_filter :authorize

  include CompanyFilter
  before_filter :check_for_company

  def index
    sort_init 'date', 'asc'
    sort_update %w(date number clients.name)

    c = ARCondition.new(["clients.project_id = ?",@project.id])

    unless params[:name].blank?
      name = "%#{params[:name].strip.downcase}%"
      c << ["LOWER(name) LIKE ? OR LOWER(address1) LIKE ? OR LOWER(address2) LIKE ?", name, name, name]
    end

    @invoice_count = InvoiceTemplate.count(:conditions => c.conditions, :include => [:client])
    @invoice_pages = Paginator.new self, @invoice_count,
		per_page_option,
		params['page']
    @invoices =  InvoiceTemplate.find :all,:order => sort_clause,
       :conditions => c.conditions,
       :include => [:client],
       :limit  =>  @invoice_pages.items_per_page,
       :offset =>  @invoice_pages.current.offset

    render :action => "index", :layout => false if request.xhr?
  end

  def new
    @invoice = InvoiceTemplate.new
    @invoice.client_id = params[:client]
    render :template => "invoices/new"
  end

  def edit
    @invoice = InvoiceTemplate.find(params[:id])
    render :template => "invoices/edit"
  end

  def create
    @invoice = InvoiceTemplate.new(params[:invoice])
    if @invoice.save
      flash[:notice] = 'Invoice was successfully created.'
      redirect_to :action => 'index', :id => @project
    else
      render :action => "new"
    end
  end

  def update
    if @invoice.update_attributes(params[:invoice])
      flash[:notice] = 'Invoice was successfully updated.'
      redirect_to :action => 'index', :id => @project
    else
      render :action => "edit"
    end
  end

  def destroy
    @invoice.destroy
    redirect_to :action => 'index', :id => @project
  end

  def showit
    @invoices_generated = @invoice.invoice_documents.sort
    render :template => "invoices/showit"
  end

  def new_from_invoice
    @invoice = InvoiceTemplate.new(@invoice_document.attributes)
    @invoice.created_at=nil
    @invoice.updated_at=nil
    @invoice.number=nil
    @invoice_document.invoice_lines.each do |line|
      @invoice.invoice_lines << InvoiceLine.new(line.attributes)
    end
    render :template => "invoices/new"
  end

  private

  def find_invoice_template
    @invoice = InvoiceTemplate.find params[:id]
    @lines = @invoice.invoice_lines
    @client = @invoice.client
    @project = @client.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_invoice
    @invoice_document = InvoiceDocument.find params[:id]
    @client = @invoice_document.client
    @project = @client.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
