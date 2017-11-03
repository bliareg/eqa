Rails.application.routes.draw do
  get 'transactions/new'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_scope :user do
     get 'users/sign_up/:referral_token', to: 'users/registrations#referral_invitation', as: 'referral_invitation'
  end
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks",
                                    sessions: 'users/sessions',
                                    passwords: 'users/passwords',
                                    registrations: 'users/registrations',
                                    confirmations: 'users/confirmations' }

  namespace :test_modules, shallow: true do
    resources :test_cases_positions, only: :update
  end
  get 'raise_error', to: 'pages#raise_error', as: :raise_error if Rails.env.staging? || Rails.env.development?

  scope path: :jira_plugin, controller: :jira_plugins do
    get :atlassian_connect, action: :atlassian_connect
    get :add_on_config, action: :add_on_config
    post :installed, action: :installed
    post :uninstalled, action: :uninstalled
    put ':id/add_organization_token', action: :add_token, as: :add_token
    get 'project_overview/:project_key', action: :project_overview
    get 'test_objects/:project_key', action: :test_objects
    get 'test_plans/:project_key', action: :test_plans
    get 'test_runs/:project_key', action: :test_runs
    get 'test_reports/:project_key', action: :test_reports
    get 'crashes/:project_key', action: :crashes
  end


  unless Rails.env.standalone?
    # resources :payment_methods, only: [:create, :destroy] do
    #   member { put :make_default }
    # end
    resources :billings, only: [:index] do
      collection { put :toggle_autopayment }
      collection { put :update_licenses_amount }
    end
    resources :payments, only: :index
    # resources :payments, only: [:create] do
    #   collection { post :transaction_webhook }
    #   collection { post :disbursement_webhook }
    #   collection { post :webhook }
    # end

    resources :paypal_payments, only: [:create] do
      collection { post :execute }
      collection { post :sale_webhook }
      collection { delete :cancel }
    end

    resources :promocodes, only: [] do
      collection { post :check }
    end
  else
    resources :licenses, only: [:new, :index, :create]
  end

  get '/users/profile/referral_program', controller: :referrals, action: :show, as: :referral_program
  resources :referrals, only: [] do
    collection { post :send_email }
    collection { get :show_emails }
  end

  namespace :users do
    get 'expiration_reminder_payments/expired'
    get 'expiration_reminder_payments/expiring'
  end

  mount ActionCable.server => '/cable'
  devise_scope :user do 
    get '/users' => 'devise/registrations#new'
    put '/activate_account/:user_id' => 'users#activate_account', as: :activate_account
    get '/users/password' => 'devise/passwords#new'
    get 'unconfirmed' => 'users/confirmations#unconfirmed'
    post '/users/confirmation/unconfirmed' => 'users/confirmations#resend_unconfirmed'
    get 'resend' => 'users/confirmations#resend'
    get 'confirmation_instruction' => 'users/confirmations#instruction'
  end

  root to: 'pages#index'
  scope path: '/projects/:project_id', controller: :test_runs do
    post 'select_test_cases', action: :select_cases, as: :select_test_cases
    post 'select_modules', action: :select_modules, as: :select_modules
    get 'test_run_profile_data/:id', action: :profile_data, as: :test_run_profile_data
    post 'set_result', action: :set_result, as: :set_result
    post 'update_result_status', action: :update_result_status
  end
  get '/projects/:project_id/export_issues', to: 'exports#issues', as: :export_issues
  get '/projects/:test_plan_id/export_cases', to: 'exports#cases', as: :export_cases
  get '/projects/:test_run_id/export_run_results', to: 'exports#run_results', as: :export_run_results

  post 'sdk_downloads/android', to: 'sdk_downloads#android', as: :download_android
  post 'sdk_downloads/ios', to: 'sdk_downloads#ios', as: :download_ios

  scope path: ':job_id/', controller: :progress_bars do
    get    'progress_info', action: :progress_info, as: :progress_info
    delete 'kill_job',      action: :kill_job,      as: :kill_job
    post   'retry_job',     action: :retry_job,     as: :retry_job
  end

  scope path: '/projects/:project_id', controller: :imports do
    get  'upload_csv',    action: 'upload_csv',    as: :upload_csv
    post 'map_fields',    action: 'map_fields',    as: :map_fields
    post 'select_fields', action: 'select_fields', as: :select_fields
    post 'import',        action: :import,         as: :import

    post 'map_test_case_fields',     action: 'map_test_case_fields',     as: :map_test_case_fields
    post 'select_test_cases_fields', action: 'select_test_cases_fields', as: :select_test_cases_fields
    post 'import_test_cases',        action: :import_test_cases,         as: :import_test_cases
  end

  scope module: 'api/v1' do
    scope path: 'projects/', controller: :crashes do
      post 'upload_crashes', action: :upload_crashes, as: :upload_crashes
    end
    scope path: 'api/v1' do
      scope path: 'projects', controller: :issues do
        post 'issue_info',        action: :issue_info
        post 'issues/create',     action: :create
      end
      scope controller: :users do
        get 'organization/members', action: :organization_members
        get 'users/show', action: :show
        get 'projects/members_list', action: :project_members_list
        post 'sign_in', action: :sign_in
        delete 'sign_out', action: :sign_out
      end
    end
  end
  namespace :api do
    namespace :v1 do
      resources :organizations, except: [:new, :edit], shallow: :true do
        resources :roles, except: [:new, :edit]
      end
      resources :projects, except: [:new, :edit]
      resources :statuses, except: [:new, :edit]

      resources :test_objects, except: [:new, :update, :edit]
      resources :test_runs, except: [:new, :edit], shallow: true do
        resources :test_run_results, except: [:new, :edit, :create], module: :test_runs
      end
      resources :issues, except: [:new, :create, :edit], shallow: true do
        resources :attachments, only: [:create, :destroy], module: :issues
      end

      resources :test_plans, except: [:new, :edit], shallow: true do
        resources :test_modules, except: [:new, :edit], shallow: true, module: :test_plans do
          resources :test_cases, except: [:new, :edit, :index], module: :test_modules
        end
      end
      get ':parent_name/:parent_id/test_cases', to: 'test_plans/test_modules/test_cases#index', as: :test_cases
    end
  end

  scope path: '/projects/:project_id', controller: :test_plans do
    get 'new_test_plan',        action: :new,     as: :new_test_plan
    post 'create_test_plan',    action: :create,  as: :create_test_plan
    get 'test_plans/:id',       action: :show,    as: :load_test_plan
    get 'test_plans/:id/edit',  action: :edit,    as: :edit_test_plan
    put 'update_test_plan',     action: :update,  as: :update_test_plan
    delete 'test_plans/:id',    action: :destroy, as: :destroy_test_plan
    get 'test_plans/:id/destroy_test_plan_confirm', action: :destroy_confirm, as: :destroy_test_plan_confirm
  end

  scope path: '/crashes', controller: :crashes do
    get ':project_id/:id/convert_to_issue', action: :convert_to_issue, as: :convert_to_issue
  end

  scope path: '/test_plan/', controller: :test_modules do
    get ':test_plan_id/new_test_module', action: :new, as: :new_test_module
    post ':test_plan_id/create_test_module', action: :create, as: :create_test_module
    get ':id/test_plan_profile',      action: :index,   as: :test_plan_profile
    get ':id/edit_test_module',       action: :edit,    as: :edit_test_module
    put ':id/update_test_module',     action: :update,  as: :update_test_module
    delete ':id/destroy_test_module', action: :destroy, as: :destroy_test_module
    get ':id/destroy_module_confirm', action: :destroy_module_confirm, as: :destroy_module_confirm
  end

  resource :test_cases, only: [], shallow: true do
    resources :comments, only: [:create]
  end

  get '/test_cases/:id/destroy_case_confirm', to: 'test_cases#destroy_case_confirm', as: :destroy_case_confirm
  resources :test_plans, only: [], shallow: true do
    resources :test_module_positions, only: :update, param: :test_plan_id, module: :test_plans
    resources :test_cases, except: :index, shallow: true
  end
  put '/test_case/update_cases_module', action: :update_cases_module, controller: :test_cases

  resources :projects do
    scope shallow: true do
      resources :test_reports, param: 'parent_name/:parent_id/:object_name',
                               only: [:show, :index]
      resources :test_runs do
        member { post :clone }
        resources :test_run_results, only: [:show, :destroy], module: :test_runs
        resources :test_run_result_positions, only: :update, param: :test_run_id, module: :test_runs
      end
      resources :crashes, only: [:index, :destroy]
      resources :copy_test_cases, only: [:new, :create],
                                  module: 'projects/test_plans'
      resources :test_plans, only: :index

      scope module: 'projects' do
        resources :integrations,    only: :index
        resources :test_activities, only: :index
        resources :settings,        only: :index
        resource  :settings,        only: [] do
          get 'team'
          get 'delete'
        end

        resources :test_objects, only: [:index, :new, :create, :show, :destroy] do
          scope module: 'test_objects' do
            resources :mailers, only: [:new, :create, :show]
          end
        end
      end

      get 'synchronizations/choose', to: 'synchronizations#choose', as: :synchronization_choose
      resources :synchronizations, only: :index

      resources :synchronizations, except: [:show, :index], path: 'plugin/:plugin_name' do
        scope module: 'synchronizations' do
          resource :destroy_confirmations, only: [:show]
        end
      end

      scope module: 'synchronizations', path: '/sync' do
        resources :sync_mobile_builds, only: [:new, :create]
        resources :sync_issues, only: [:new, :create]
      end
    end

    resources :statuses, only: [:destroy, :update, :create]
    scope module: 'statuses' do
      resources :project_statuses, only: :update
      resource :positions, only: :update
    end
  end
  resources :test_reports, only: :create do
    collection { post :send_email }
  end 

  scope path: '/projects/:id', controller: :projects do
    put 'refresh_token',   action: :refresh_token
    get 'add_members',     action: :add_members
    post 'add_members',    action: :invite_users_to_project
    get 'destroy_project_confirm', action: :destroy_project_confirm, as: :destroy_project_confirm
    put 'update',          action: :update,                as: :project_update
    put 'remove_project_logo', action: :remove_logo,       as: :remove_project_logo
  end

  resource :issues, only: [], shallow: true do
    scope module: 'issues' do
      resources :time_managements, only: [:update, :create, :destroy]
    end
    resources :comments, only: [:create, :update, :destroy]
  end

  scope path: '/projects/:project_id', controller: :issues do
    resources :issues, except: [:edit]
    resources :attachments, only: [:destroy], controller: :issues, action: :destroy_attachment
  end

  get '/report_bug', to: 'issues#new_bug', as: :new_bug
  post '/report_bug', to: 'issues#report_bug', as: :report_bug

  resources :organizations, only: [:new, :create, :destroy, :index, :show]
  resource :user, only: [:update, :edit]
  scope controller: :users do
    get 'users/profile/edit_password',         action: :edit_password,           as: :edit_password
    post ':user_id/change_password',           action: :change_password,         as: :change_password
    post 'users/invite_users',                 action: :invite_users,            as: :invite_users
    put 'users/:id/invitation_user_update',    action: :invitation_user_update,  as: :invitation_user_update
    get 'users/:token/invitation_user_update', action: :invitation_user_edit,    as: :invitation_user_edit
    put 'users/:id/destroy_avatar',            action: :destroy_avatar,          as: :destroy_avatar
    get '/deactivate_confirmation',            action: :deactivate_confirmation, as: :deactivate_confirmation
    put 'users/toggle_payment_notification', action: :toggle_payment_notification, as: :toggle_payment_notification
  end

  scope path: '/organizations/:organization_id', controller: :organizations do
    get 'projects',   action: :projects,   as: :organization_projects
    get 'members',    action: :members,    as: :organization_profile_members
    get 'settings',   action: :settings,   as: :organization_settings
    get 'invitation', action: :invitation, as: :organization_invitation
    get 'new_invitation', action: :new_invitation, as: :organization_new_invitation
    get 'edit',       action: :edit,       as: :organization_edit
    get '/destroy_organization_confirm', action: :destroy_organization_confirm, as: :destroy_organization_confirm
    put 'update',        action: :update,          as: :organization_update
    put 'remove_organization_logo', action: :remove_logo, as: :remove_organization_logo
    put 'refresh_token',   action: :refresh_token, as: :refresh_organization_token
  end

  scope controller: :roles do
    post 'organizations/members/change_member_role', action: :change_member_role
    delete 'organizations/members/delete_member_role', action: :destroy_member_role
  end

  resources :notifications, only: :index
  scope controller: :notifications do
    put 'toggle_notifications', action: :toggle_notifications
  end

  resources :column_visibilities, only: [:edit, :update] do
    member { put :update_column_size }
    member { put :update_sort_order }
  end
  resources :uniqueness_validations, only: :create
  post 'role/:id', to: 'roles#change_notification', as: 'change_notification'
end
