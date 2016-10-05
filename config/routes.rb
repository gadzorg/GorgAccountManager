Rails.application.routes.draw do
  get 'admin/index'
  
  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks",
    :sessions => "users/sessions"
    }
  
  get 'static_pages/index'
  get 'recovery' => 'users#recovery'
  post 'recovery' => 'users#recovery'
  post 'recovery_step2' => 'users#recovery_step2'
  post 'create_recovery_session' => 'users#create_recovery_session'
  get 'recovery_step1/:token_session', to: "users#recovery_step1", as: :recovery_step1
  get 'password_reset/:token', to: "users#password_reset", as: :password_change
  post 'password_reset/:token'=>"users#password_change"

  get 'password_change_u', to: "users#password_change_logged", as: :password_change_u
  post 'create_sms' => 'users#create_sms'
  #get 'validate_sms/:token', to: 'users#validate_sms', as: :validate_sms
  post 'validate_sms' => 'users#validate_sms'
  get 'recovery_final' => "users#recovery_final"
  get 'recovery_inscription_final' => "users#recovery_inscription_final"
  get 'recovery_support' => "users#recovery_support"
  post 'recovery_support_final' => "users#recovery_support_final"
  get 'recovery_sms' => "users#recovery_sms"
  
  get 'recovery_inscription/:token', to: "users#recovery_inscription", as: :user_recovery_inscription
  post 'password_change_inscription/:token', to: "users#password_change_inscription", as: :password_change_inscription


  get 'charts_term_type' => 'charts#term_type'
  get 'charts_sessions_dates' => 'charts#sessions_dates'
  get 'charts_used_link' => 'charts#used_link'

  get 'admin/stats' => "admin#stats"
  get 'admin/inscriptions' => "admin#inscriptions"
  post 'admin/inscriptions' => "admin#add_inscriptions"
  get 'admin/searches' => "admin#searches"
  get 'admin/search_user' => "admin#search_user"
  post 'admin/search_user' => "admin#search_user"
  get 'admin/info_user' => "admin#info_user"
  get 'admin/recovery_sessions' => "admin#recovery_sessions"
  resources :users do
    get "dashboard"
    get 'password_change_logged'
    post 'password_change_logged_step2'
    patch 'password_change_logged_step2'
  end

  namespace :module do
    get "merge/me" => "merge#user"
    # get "merge/address/me" => "merge#address"
    #post "merge/update_soce_user" => "merge#update_soce_user"
    get 'merge/user/:hruid', to: "merge#user", as: :merge_user, :constraints => {:hruid => /[^\/]+/}
    post 'merge/update_soce_user/:hruid', to: "merge#update_soce_user", as: :merge_update_soce_user, :constraints => {:hruid => /[^\/]+/}
    get 'merge/address/:hruid', to: "merge#address", as: :merge_address, :constraints => {:hruid => /[^\/]+/}
  end

  #get 'info_user/:hruid', to: "admin#info_user", as: :admin_info_user, :constraints => {:hruid => /[^\/]+/}

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'static_pages#index'

  get 'admin' => 'admin#index'
  get 'roles' => 'roles#index'

  resources :users do

    resources :roles, only: [:create,:destroy]

    get :autocomplete_user_hruid, :on => :collection
    get :search_by_id, :on => :collection
    get :sync, to: 'users#sync_with_gram', on: :member


  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
