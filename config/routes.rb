# redmine 2 / rails 3 style

# NOTE: all xml and json requests will use Redmine's API auth
#        %w(xml json).include? params[:format]

resources :events
match '/statistics' => 'statistics#index'

match '/clients/check_cif/:id' => 'clients#check_cif', :via => :get
match '/clients/link_to_profile/:id' => 'clients#link_to_profile', :via => :get
match '/clients/unlink/:id' => 'clients#unlink', :via => :get
match '/clients/allow_link/:id' => 'clients#allow_link', :via => :get
match '/clients/deny_link/:id' => 'clients#deny_link', :via => :get
resources :projects do
  resources :clients, :only => [:index, :new, :create]
  match :people, :controller => 'people', :action => 'index', :via => :get
  match 'companies/linked_to_mine', :controller => 'companies', :action => 'linked_to_mine', :via => :get
  match 'my_company', :controller => 'companies', :action => 'my_company', :via => :get
  match 'invoices/send_new' => 'invoices#send_new_invoices', :via => :get
  match 'invoices/download_new' => 'invoices#download_new_invoices', :via => :get
  match 'invoices/update_payment_stuff' => 'invoices#update_payment_stuff', :via => :get
  resources :invoices, :only => [:index, :new, :create]
  resources :received, :only => [:index, :new, :create]
  resources :invoice_templates, :only => [:index, :new, :create]
  match 'new_invoices_from_template' => 'invoice_templates#new_invoices_from_template', :via => :post
  match 'create_invoices' => 'invoice_templates#create_invoices', :via => :post
  match 'update_taxes' => 'invoice_templates#update_taxes'
  match 'report/issued_3m' => 'invoices#report', :via => :get
  resources :payments, :only => [:index, :new, :create]
  match 'payments/import_aeb43_index' => 'payments#import_aeb43_index'
  match 'payments/import_aeb43' => 'payments#import_aeb43'
  match 'payments/n19_index' => 'payments#n19_index'
end
match 'payments/n19/:id' => 'payments#n19', :via => :get
match 'payments/n19_done/:id' => 'payments#n19_done', :via => :post
resources :clients do
  resources :people, :only => [:index, :new, :create]
end

resources :people
resources :invoices
match 'invoices/mark_sent/:id' => 'invoices#mark_sent', :via => :get, :as => :mark_sent
match 'invoices/mark_not_sent/:id' => 'invoices#mark_not_sent', :via => :get, :as => :mark_not_sent
match 'invoices/mark_closed/:id' => 'invoices#mark_closed', :via => :get, :as => :mark_closed
match 'invoices/send_invoice/:id' => 'invoices#send_invoice', :via => :get, :as => :send_invoice
match 'invoices/legal/:id' => 'invoices#legal', :via => :get, :as => :legal
match 'invoices/amend_for_invoice/:id' => 'invoices#amend_for_invoice', :via => :post, :as => :amend_for_invoice
match 'invoices/duplicate_invoice/:id' => 'invoices#duplicate_invoice', :via => :get, :as => :duplicate_invoice
match 'invoices/destroy_payment/:id' => 'invoices#destroy_payment', :via => :delete, :as => :destroy_payment
match 'invoices/mail/:id' => 'invoices#mail', :via => :get

# public access to an invoice using the client hash
match 'invoice/download/:client_hashid/:invoice_id' => 'invoices#download', :client_hashid => /.*/, :invoice_id => /\d+/, :via => :get
match 'invoice/:client_hashid/:invoice_id' => 'invoices#view', :client_hashid => /.*/, :invoice_id => /\d+/, :via => :get

# public access to a company logo, knowing the id and the file name
# TODO should be companies controller
match 'invoices/logo/:attachment_id/:filename' => 'invoices#logo', :attachment_id => /\d+/, :filename => /.*/

  resources :invoices, :has_many => :events, :collection => { :by_taxcode_and_num => :get }
resources :received
match 'received/mark_refused/:id' => 'received#mark_refused', :as => :mark_refused
match 'received/mark_refused_with_mail/:id' => 'received#mark_refused_with_mail', :as => :mark_refused_with_mail
match 'received/mark_accepted/:id' => 'received#mark_accepted', :as => :mark_accepted
match 'received/mark_accepted_with_mail/:id' => 'received#mark_accepted_with_mail', :as => :mark_accepted_with_mail

resources :invoice_templates
match 'invoice_templates/new_from_invoice/:id' => 'invoice_templates#new_from_invoice'

match 'projects/:project_id/payments/new/:invoice_id(/:payment_type)' => 'payments#new'
resources :payments

match '/companies/logo/:taxcode' => 'companies#logo', :via => :get
resources :companies, :only => [:update]
