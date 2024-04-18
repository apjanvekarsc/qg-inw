Rails.application.routes.draw do


  resources :whitelisted_identities, except: [:index,:new] do
    member do
      get :audit_logs
      put :revoke
      put :ratify
      put :approve
      put :reject
    end
    collection do
      get :index
      put :index
    end
  end

  namespace :api do
    namespace :v1 do
      resources :whitelisted_identities
    end
  end

  get '/new_whitelisted_identities' => 'whitelisted_identities#new'
  get '/download_attachment' => 'whitelisted_identities#download_attachment'

  resources :purpose_codes do
    member do
      get :audit_logs
      put :approve
    end

    collection do
      get :index
      put :index
    end
  end

  resources :partners do
    member do
      get :audit_logs
      put :approve
      put :resend_notification
    end

    collection do
      get :index
      put :index
    end
  end

  resources :partner_lcy_rates do
    member do
      get :audit_logs
      put :approve
    end

    collection do
      get :update_lcy_for_mtss
      get :index
      put :index
      get :tokenize_data
      get :tokenize_data_proc
    end
  end

  resources :inw_remittance_rules do
      member do
        get :audit_logs
        put :approve
      end
    end

  get '/inw_error_msg' => "inw_remittance_rules#error_msg"

  resources :inw_guidelines do
      member do
        get :audit_logs
        put :approve
      end
    end

  resources :banks do
    member do
      get :audit_logs
      put :approve
    end
  end

  resources :inward_remittances, except: :index do
    member do
      put 'release'
    end
    collection do
      get :index
      put :index
    end
  end

  get '/inward_remittances/:id/identity/:id_id' => 'inward_remittances#identity'
  get '/inward_remittances/:id/remitter_identities' => 'inward_remittances#remitter_identities'
  get '/inward_remittances/:id/beneficiary_identities' => 'inward_remittances#beneficiary_identities'
  get '/inward_remittances/:id/audit_logs/:step_name' => 'inward_remittances#audit_logs'

  get '/sdn/search' => 'aml_search#find_search_results'
  get '/sdn/search_results' => 'aml_search#results'
  get '/sdn/search_result' => 'aml_search#search_result'
end
