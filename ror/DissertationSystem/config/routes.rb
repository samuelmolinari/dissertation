DissertationSystem::Application.routes.draw do
  get "notification_centre/recognition"

  get "image_administrator/index"
  
  get "image_administrator/face"

  get "eigenface/learn"

  get "album/next_photo"

  get "album/prev_photo"

  get "uploader/upload"

  get "manage/albums"

  get "manage/album"

  get "manage/photos"

  get "manage/photo"

  get "manage/tags"
  
  get "manage/tag"

  get "manage/faces"

  get "manage/index"
  
  get "manage/recognitions"
  
  get "manage/autocomplete_user"

  get "user/profile"

  get "user/index"

  get "user/photos"

  get "user/photo"

  get "user/albums"

  get "user/album"
  
  get "user/id"

  get "home/index"

  get "auth/authenticate"

  get "auth/login"

  get "auth/logout"

  get "auth/reset"

  get "account/create"

  get "account/delete"

  get "account/settings"

  get "account/privacy"

  get "account/profile"
  
  get "account/train_new_face"
  
  resources :account
  resources :auth
  resources :home
  resources :manage
  
  match 'user/:uname(/:action(/:id))(.:format)' => "user#", :constraints => { :uname => /[0-9A-Za-z\-\._]+/ }
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'manage#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
  
end
