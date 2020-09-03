Workarea::Storefront::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    get 'login' => 'users/logins#new', as: :login
    post 'login' => 'users/logins#create'
    delete 'logout' => 'users/logins#destroy'
    get 'forgot_password' => 'users/passwords#new'
    post 'forgot_password' => 'users/passwords#create'
    get 'reset_password/:token' => 'users/passwords#edit', as: :reset_password
    patch 'reset_password/:token' => 'users/passwords#update'
    get 'change_password' => 'users/passwords#change'
    patch 'change_password' => 'users/passwords#make_change'

    resources :content_areas, only: :show
    resources :content_blocks, only: [:new, :show] do
      member { get :draft }
    end

    resources :menus, only: [:index, :show]
    resources :categories, only: :show
    resource :contact, only: [:show, :create]
    resources :pages, only: :show
    get 'accessibility', to: 'pages#accessibility'

    resources :products, only: :show do
      member do
        get :details
      end
    end

    resource :email_signup, only: [:show, :create]
    resource :search, only: :show

    get '/current_user', to: 'application#current_user_info', as: :current_user

    resource :cart, only: :show do
      resources :items, controller: 'cart_items', except: [:index, :new, :edit]

      post 'add_promo_code',  as: :add_promo_code_to
      get  'resume/:token',   as: :resume, to: 'carts#resume'
    end

    resources :orders, only: [:show] do
      collection do
        post  'lookup' => 'orders#lookup', as: :lookup
        match 'status' => 'orders#index', via: :get, as: :check
      end
    end
    # TODO remove in v4, no longer needed after lookup order session work
    resources :order, only: [] do
      post  'lookup' => 'orders#lookup', as: :lookup
      match 'status' => 'orders#index', via: :get, as: :check
    end
    match 'orders/status/:order_id/:postal_code' => 'orders#lookup', via: :get, as: :orders

    get 'checkout', to: 'checkouts#new'
    namespace :checkout do
      get   'addresses',    to: 'addresses#addresses'
      patch 'addresses',    to: 'addresses#update_addresses'

      get   'shipping',     to: 'shipping#shipping'
      patch 'shipping',     to: 'shipping#update_shipping'

      get   'payment',      to: 'payment#payment'

      patch 'place_order',  to: 'place_order#place_order'
      get   'confirmation', to: 'place_order#confirmation'
    end

    resources :downloads, only: :show

    resource :recent_views, only: :show
    resource :recommendations, only: :show

    resource :sitemap, only: :show

    namespace :users do
      resource  :account
      resources :addresses
      resources :credit_cards
      resources :orders, only: [:index, :show]
    end

    get '/robots.txt', to: 'pages#robots', defaults: { format: 'text' }, as: :robots_txt
    get '/health_check', to: 'application#health_check'

    get '/browserconfig.xml', to: 'pages#browser_config', defaults: { format: 'xml' }, as: :browser_config
    get '/site.webmanifest', to: 'pages#web_manifest', defaults: { format: 'json' }, as: :web_manifest

    get '/favicon.ico' => Dragonfly.app(:workarea).endpoint { |*args|
      Workarea::AssetEndpoints::Favicons.new(*args).ico }, defaults: { format: 'ico' }, as: :dynamic_favicon
    get '/favicons/:size.png' => Dragonfly.app(:workarea).endpoint { |*args|
      Workarea::AssetEndpoints::Favicons.new(*args).result }, defaults: { format: 'png' }, as: :dynamic_favicons

    get 'style_guides', to: 'style_guides#index', as: :style_guides
    get 'style_guides/:category', to: 'style_guides#category', as: :style_guides_category
    get 'style_guides/:category/:id', to: 'style_guides#show', as: :style_guide

    post 'analytics/new_session', to: 'analytics#new_session', as: :analytics_new_session
    post 'analytics/product_view/:product_id', to: 'analytics#product_view', as: :analytics_product_view
    post 'analytics/category_view/:category_id', to: 'analytics#category_view', as: :analytics_category_view
    post 'analytics/search', to: 'analytics#search', as: :analytics_search
    post 'analytics/search_abandonment', to: 'analytics#search_abandonment', as: :analytics_search_abandonment
    post 'analytics/filters', to: 'analytics#filters', as: :analytics_filters

    resources :content_security_violations, only: :create
  end

  match '/404', to: 'errors#not_found', via: :all, as: :not_found
  match '/500', to: 'errors#internal', via: :all, as: :internal_error
  match '/offline', to: 'errors#offline', via: :all, as: :offline

  get '/:locale', to: 'pages#home_page', via: :get, constraints: Workarea::I18n.routes_constraint
  root to: 'pages#home_page', via: :get
end
