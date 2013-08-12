NjcBookclub::Application.routes.draw do
  get "books/index"
  get "books/manage"
  get "books/i_have_one"
  get "books/best_books"
  get "books/best_sharer"
  post "books/i_have_one"
  resources :books

  get "readings/index"
  get "readings/manage"
  resources :readings
  controller :readings do
    get "readings/manage" => :manage
  end

  controller :users do
    get "find_password" => :find_password
    post "reset_password" => :reset_password
  end

  resources :users
  resources :categories

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"

  controller :bookclub do
    get "bookclub" => :index    
    post "bookclub" => :index
    get "bookclub/show_books_by_category" => :index
    get "bookclub/show_books_by_query" => :index
    post "bookclub/show_books_by_query" => :index
    get "bookclub/show_books_by_owner" => :index
    get "bookclub/show_books_by_reader" => :index
    get "bookclub/show_suggested" =>:index
  end

  get "bookclub/index"
  get "bookclub/news"
  get "bookclub/billboard"
  get "bookclub/faq"
  get "bookclub/contact"
  get "bookclub/show_books_by_category"
  get "bookclub/show_books_by_owner"
  get "bookclub/show_books_by_query"
  post "bookclub/show_books_by_query"
  get "bookclub/show_books_by_reader"
  get "bookclub/show_suggested"
  get "bookclub/lend_book"
  post "bookclub/lend_book"

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
  root :to => "bookclub#index", :as => "bookclub"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
