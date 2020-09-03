Workarea::Admin::Engine.routes.draw do
  mount Sidekiq::Web,
    at: '/sidekiq',
    constraints: Workarea::RoutesConstraints::SuperAdmin.new,
    anchor: false

  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    resource :activity, only: :show
    resources :trash, only: :index do
      member { post :restore }
    end
    resources :timeline, only: :show
    resources :featured_products, only: [:edit, :update] do
      member do
        get :select
        post :add
        delete :remove
      end
    end

    resources :bulk_actions, only: [:create, :destroy] do
      member do
        get :selected
      end
    end
    resources :bulk_action_deletions, only: :edit do
      member { delete :confirm }
    end
    resources :bulk_action_product_edits, only: [:edit, :update] do
      member do
        get :review
        post :publish
      end
    end
    resources :bulk_action_sequential_product_edits, only: :edit do
      member do
        post :publish

        get 'product/:index', action: 'product', as: :product
        patch 'product/:index', action: 'update_product'
      end
    end
    resources :bulk_action_order_exports,
      only: [:show, :edit, :update], controller: :bulk_action_exports
    resources :bulk_action_user_exports,
      only: [:show, :edit, :update], controller: :bulk_action_exports
    resources :bulk_action_pricing_discount_code_list_exports,
      only: [:show, :edit, :update], controller: :bulk_action_exports
    resources :bulk_action_email_signup_exports,
      only: [:show, :edit, :update], controller: :bulk_action_exports

    resources :commentables, only: [] do
      resources :comments, except: :new do
        collection do
          put :subscribe
          put :unsubscribe
        end
      end
    end

    resources :content_assets do
      collection do
        get 'insert', to: 'content_assets#insert'
      end
    end

    resources :data_files, only: :index do
      member { get :errors }
    end
    resources :data_file_exports, only: [:show, :new, :create]
    resources :data_file_imports, only: [:new, :create] do
      get :sample, on: :collection
    end
    resources :data_file_tax_imports, only: [:new, :create]

    resource :impersonations, only: [:create, :destroy]
    resource :guest_browsing, only: [:create, :destroy]

    resources :help
    resources :help_assets, only: [:index, :create, :destroy]

    # TODO: v4 use help_articles/ over help/
    get 'help_articles/:id', to: redirect('help/%{id}'), as: :help_article

    resources :content do
      member do
        get :advanced
        get :preview
      end

      resources :areas, only: [] do
        resources :blocks, except: [:show, :new, :edit], controller: 'content_blocks' do
          collection do
            patch :move
          end

          member do
            post :copy
          end
        end
      end
    end

    resources :content_block_drafts, only: :create

    resources :create_releases, only: [:index, :create, :edit, :update] do
      member do
        get :plan
      end
    end

    resources :releases do
      resources :changesets, only: [:index, :destroy]
      resources :releasables, only: [:index, :show]
      resource :undo, controller: 'create_release_undos', only: [:new, :create] do
        get :review
        post :complete
      end

      member do
        get 'edit_for/:type', action: :edit_for, as: :edit_for
        get :undo
        get :original
        patch :publish
      end

      collection do
        get 'list'
        get 'calendar_feed/:token/site_planner.ics', action: :calendar_feed, as: :calendar_feed
      end
    end

    resource :release_session, only: :create do
      post :touch
    end

    resource :report do
      get :average_order_value
      get :customers
      get :first_time_vs_returning_sales
      get :insights
      get :low_inventory
      get :reference
      get :sales_by_category
      get :sales_by_country
      get :sales_by_discount
      get :sales_by_product
      get :sales_by_sku
      get :sales_by_tender
      get :sales_by_traffic_referrer
      get :sales_over_time
      get :searches
      get :timeline
      get :content_security_policy_violations

      resources :custom_events, only: [:create, :update, :destroy]

      post :export
      get '/:id/download', action: :download, as: :download
    end

    get 'jump_to', to: 'jump_to#index'

    resources :orders, only: [:index, :show] do
      member do
        get :attributes
        get :timeline
        get :fraud
      end

      resources :shippings, only: :index
    end

    # TODO remove in v4
    resources :shippings, only: :show

    resources :payments, only: :show

    resources :payment_transactions, only: [:index, :show]

    resources :fulfillments, only: :show
    resources :fulfillment_skus do
      resources :fulfillment_tokens, as: :tokens
    end

    resources :catalog_products, except: [:new, :create] do
      resources :variants, controller: 'catalog_variants', except: :show do
        collection do
          post :move
        end
      end
      resource :recommendations, only: [:edit, :update]
      resources :categorizations, only: [:index, :create, :destroy]

      resources :images, only: [:index, :create, :edit, :update, :destroy], controller: 'catalog_product_images' do
        collection do
          post :positions
          get  :options
        end
      end

      member do
        get :content
        get :insights
      end

      collection do
        get :filters
        get :details
      end
    end

    resources :catalog_product_copies, only: [:new, :create]

    resources :create_catalog_products, except: :show do
      member do
        get :variants
        post :save_variants

        get :details
        post :save_details

        get :images
        post :save_images

        get :content
        post :save_content

        get :categorization
        post :save_categorization

        get :publish
        post :save_publish
      end
    end

    resources :create_users, except: :show

    get '/catalog_variants/details', to: 'catalog_variants#details'

    resources :catalog_categories, except: [:new, :create] do
      member do
        get :insights
      end
    end

    resources :product_list, only: [] do
      resources :product_rules, except: [:show] do
        member do
          get :preview
        end
      end
    end

    resources :create_catalog_categories, except: :show do
      member do
        get :products
        get :featured_products
        get :rules
        get :new_rule
        get 'edit_rule/:rule_id', action: :edit_rule, as: :edit_rule
        get :content
        get :taxonomy
        post :save_taxonomy
        get :navigation
        post :save_navigation
        get :publish
        post :save_publish
      end
    end

    resources :create_pricing_discounts, except: :show do
      collection do
        get :details
        get :rules
      end
      member do
        get :publish
        post :save_publish
      end
    end

    resources :pricing_discount_code_lists do
      member { get :promo_codes }
    end

    resources :pricing_overrides, only: [:edit, :update]

    resources :content_pages, except: [:new, :create]

    resources :content_page_copies, only: [:new, :create]

    resources :create_content_pages, except: :show do
      member do
        get :content
        get :taxonomy
        post :save_taxonomy
        get :navigation
        post :save_navigation
        get :publish
        post :save_publish
      end
    end

    resources :content_presets, only: [:new, :create, :destroy]
    resources :pricing_skus, except: :destroy do
      resources :prices, except: :show
    end
    resources :navigation_redirects, only: [:index, :show, :create, :edit, :destroy]
    resource :search, only: :show do
      member do
        get :live
      end
    end
    resource  :search_settings, only: [:show, :update]
    resources :search_customizations, except: :new do
      member do
        get :insights
        get :analyze
      end
    end

    resources :pricing_discounts, except: [:new, :create] do
      resources :redemptions, only: [:index], controller: 'pricing_discount_redemptions'

      member do
        get :rules
        get :insights
      end
    end
    resources :navigation_menus do
      collection do
        post :sort
        post :move
      end
    end
    resources :navigation_taxons do
      collection { get :select }

      member do
        get :select
        get :insert
        get :children
        patch :move
        patch :sort
      end
    end

    resource :direct_uploads, only: [:new, :create] do
      member do
        put 'upload/:type/:filename', action: :upload, as: :upload
        get :product_images
      end
    end

    resources :inventory_skus

    resources :users, except: :create do
      member do
        get :cart
        get :orders
        get :addresses
        get :permissions
        get :insights
        post :send_password_reset
        patch :unlock
      end
    end

    resources :unsubscribes, only: [] do
      member do
        get :status_report
        get :commentable
      end
    end

    resources :segments, except: [:new, :create] do
      resources :rules, except: [:show, :new, :edit], controller: 'segment_rules'
      resources :segmentables, only: [:index]

      member do
        get :insights
      end
    end
    resource :segment_override, only: [:show, :create]
    resources :segment_rules, only: [] do
      collection do
        get :geolocation_options
      end
    end

    resources :create_segments, except: :show do
      member do
        get :rules
        get :new_rule
        get 'edit_rule/:rule_id', action: :edit_rule, as: :edit_rule
        get :review
      end
    end

    resources :bookmarks, only: [:create, :destroy]

    resources :shipping_services
    resources :tax_categories do
      resources :tax_rates, except: :show, as: :rates, path: 'rates'
    end

    get 'toolbar', to: 'toolbar#show', as: 'toolbar'

    resources :content_emails, only: [:index, :edit, :update]

    get 'style_guides', to: 'style_guides#index', as: :style_guides
    get 'style_guides/:category', to: 'style_guides#category', as: :style_guides_category
    get 'style_guides/:category/:id', to: 'style_guides#show', as: :style_guide
  end

  resources :email_signups, only: [:index, :destroy]

  get '/:locale', to: 'application#index', via: :get, constraints: Workarea::I18n.routes_constraint

  resource :dashboards, only: [] do
    get :store
    get :catalog
    get :orders
    get :people
    get :search
    get :marketing
    get :reports
    get :settings
  end

  resource :configuration, only: [:show, :update]

  resources :shipping_skus, except: [:destroy]

  root to: 'dashboards#index', via: :get
end
