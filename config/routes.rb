Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  get 'static_pages/index'
  get 'recovery' => 'users#recovery'
  post 'recovery' => 'users#recovery'
  post 'recovery_step2' => 'users#recovery_step2'
  post 'create_recovery_session' => 'users#create_recovery_session'
  get 'recovery_step1/:token_session', to: "users#recovery_step1", as: :recovery_step1
  get 'password_reset/:token', to: "users#password_reset", as: :password_change
  post 'password_reset/:token'=>"users#password_change"
  post 'create_sms' => 'users#create_sms'
  #get 'validate_sms/:token', to: 'users#validate_sms', as: :validate_sms
  post 'validate_sms' => 'users#validate_sms'
  get 'recovery_final' => "users#recovery_final"
  get 'recovery_support' => "users#recovery_support"
  post 'recovery_support_final' => "users#recovery_support_final"
  get 'recovery_sms' => "users#recovery_sms"


  get 'admin/stats' => "admin#stats"
  resources :users do
    get "dashboard"
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'static_pages#index'

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
