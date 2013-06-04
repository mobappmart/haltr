class PaymentsController < ApplicationController

  unloadable
  menu_item Haltr::MenuItem.new(:payments,:payments_level2), :only => [:index]
  menu_item Haltr::MenuItem.new(:payments,:payment_new), :only => :new
  layout 'haltr'
  helper :haltr
  helper :sort

  include SortHelper

  before_filter :find_project_by_project_id, :except => [:destroy,:edit,:update]
  before_filter :find_payment, :only   => [:destroy,:edit,:update]
  before_filter :authorize

  include CompanyFilter
  before_filter :check_for_company

  def index
    sort_init 'payments.date', 'desc'
    sort_update %w(payments.date amount_in_cents invoices.number)

    payments = @project.payments.scoped

    unless params[:name].blank?
      name = "%#{params[:name].strip.downcase}%"
      payments = payments.scoped :conditions => ["LOWER(payments.payment_method) LIKE ? OR LOWER(reference) LIKE ?", name, name]
    end

    @payment_count = payments.count
    @payment_pages = Paginator.new self, @payment_count,
		per_page_option,
		params['page']
    @payments = payments.find :all, :order => sort_clause,
       :include => :invoice,
       :limit  => @payment_pages.items_per_page,
       :offset => @payment_pages.current.offset
  end


  def new
    @payment_type = params[:payment_type]
    if params[:invoice_id]
      @invoice = Invoice.find params[:invoice_id]
      @payment = Payment.new(:invoice_id => @invoice.id, :amount => @invoice.unpaid_amount)
    else
      @payment = Payment.new
    end
  end

  def edit
  end

  def create
    @payment = Payment.new(params[:payment].merge({:project=>@project}))
    if @payment.save
      flash[:notice] = l(:notice_successful_create)
      if @payment.invoice
        if params[:save_and_mail]
          MailNotifier.deliver_invoice_paid(@payment.invoice,params[:reason])
        end
        if @payment.invoice.is_paid?
          # paid state change automatically creates an Event,
          # delete it and create new one with email info (params[:reason])
          @payment.invoice.events.last.destroy
          Event.create(:name=>'paid',:invoice=>@payment.invoice,:user=>User.current,:info=>params[:reason])
        end
        redirect_to invoice_path(@payment.invoice)
      else
        redirect_to project_payments_path(@project)
      end
    else
      render :action => "new"
    end
  end

  def update
    if @payment.update_attributes(params[:payment])
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_payments_path(@project)
    else
      render :action => "edit"
    end
  end

  def destroy
    @payment.destroy
    redirect_to project_payments_path(@project)
  end

  private

  def find_payment
    @payment = Payment.find(params[:id])
    @project = @payment.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
