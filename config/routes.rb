AudioBox::Application.routes.draw do

  match '/libraries/update_multiple',  :to => 'libraries#update_multiple'
  match '/folders/:id/update_multiple',  :to => 'folders#update_multiple'
  match '/files/:id/update_multiple',  :to => 'files#update_multiple'
  match '/files/:id/zip',  :to => 'files#zip'
  match '/files/:id/daisy',  :to => 'files#daisy'
  match '/sessions/login',  :to => 'sessions#login'
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'
  match '/folders/:id/new', :to => 'folders#new'


  # Resources
  resources :admins, :only => [:new, :create, :index]
  resources :sessions, :only => [:new, :create, :destroy]
  resources :reset_password, :except => [:index, :show, :destroy]
  resources :users, :except => :show
  resources :groups, :except => :show
  resources :files, :except => [:index, :new, :create]
  resources :shared_folders, :except => [:index]
  resources :libraries
  resources :coments, :except => [:index, :new, :create]

  # Update a collection of permissions
  resources :permissions, :only => :update_multiple do
    collection do
      put :update_multiple
    end
  end

  # Nested resources
  resources :folders, :shallow => true, :except => [:new, :create] do
    resources :folders, :only => [:new, :create]
    resources :files, :only => [:index, :new, :create] do
    	resources :coments, :only => [:index, :new, :create]
    end
  end

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
  #root :to => "libraries#index"
  root :to => "folders#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
