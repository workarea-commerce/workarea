module Workarea
  module Configuration
    def self.config
      Rails.configuration.workarea
    end

    def self.setup_defaults
      Rails.configuration.workarea = ActiveSupport::Configurable::Configuration.new

      config.site_name = 'Workarea'
      config.host = 'www.example.com'
      config.email_to = 'customerservice@example.com'
      config.email_from = 'noreply@example.com'

      # Config sent to the ImageMagick through Dragonfly for optimizing jpgs
      # All metadata profiles are removed, comments cleared by comment -set ""
      # +profile takes a list of profiles to be removed
      # 8bim: Adobe path information
      # exif: Camera metadata
      # iptc: information exchange metadata
      # xmp: Extensible metadata platform (Adobe Metadata)
      config.jpg_encode_options = '+profile "8bim,exif,iptc,xmp" -set comment "" -interlace Plane -quality 85'

      # Stores instances of payment gateways for Workarea::Payment to use
      config.gateways = ActiveSupport::Configurable::Configuration.new
      config.gateways.shipping = ActiveShipping::Workarea.new

      # Whether or not to allow po box addresses for shipping/payment
      config.allow_shipping_address_po_box = false
      config.allow_payment_address_po_box = true

      # How to validate whether an address is a PO Box
      config.po_box_regex = /(?:P(?:ost(?:al)?)?[\.\-\s]*(?:(?:O(?:ffice)?[\.\-\s]*)?B(?:ox|in|\b|\d)|o(?:ffice|\b)(?:[-\s]*\d)|code)|box[-\s\b]*\d)/i

      # How long a user stays logged in
      config.admin_session_timeout = 1.hour
      config.customer_session_timeout = 10.minutes

      # How long the completed order cookie lasts, i.e. how long they have to
      # sign up for an account after placing the order and have the order
      # details copied to the account. Be careful changing this.
      config.completed_order_timeout = 10.minutes

      # How long a password reset stays valid
      config.password_reset_timeout = 2.hours

      # How long the built-in HTTP cache lasts TODO remove in v4
      config.page_cache_ttl = 15.minutes

      # Where to store Dragonfly asset files
      config.asset_store = (Rails.env.test? || Rails.env.development?) ? :file_system : :s3

      # Different types of available Content::Assets
      config.asset_types = %w(image pdf flash video audio text)

      # Product detail page templates
      config.product_templates = [:option_selects, :option_thumbnails]

      # Customization classes available to validate product customizations
      config.customization_types = []

      # How many times to retry image importing on failure
      config.images_import_retries = 2

      # How long an order is considered active before considering it abandoned
      config.order_active_period = 2.hours

      # How long to lock an order when an attempt to place it is being made
      # @deprecated as of v3.2 locking is handled via Workarea::Lock
      config.order_lock_period = 10.seconds

      # How long a checkout can be idle before the user is forced to restart
      config.checkout_expiration = 15.minutes

      # How long to wait until abandoned orders are deleted from the database
      config.order_expiration_period = 6.months

      # Number of orders to display on the user order history page
      config.storefront_user_order_display_count = 50

      # The available tender types for purchase/refund, used in order to
      # determine purchase precedence and in reverse for refund precedence.
      config.tender_types = [:store_credit, :credit_card]

      # How many failed login attempts before marking the user locked out
      config.allowed_login_attempts = 6

      # How long an account is locked out after making too many
      # failed login attempts
      config.lockout_period = 30.minutes

      # How long an adminstrators password lasts
      config.password_lifetime = 90.days

      # How many passwords to keep and validate against
      config.password_history_length = 4

      # Password requirement level: :weak, :medium, or :strong
      config.password_strength = :weak

      # Default page size for products
      config.per_page = 20

      # The multiplier used to decay views and sales scores.
      # This decay is applied weekly.
      config.score_decay = 0.9

      # How many search suggestions should be shown in the
      # autocomplete searches
      config.search_suggestions = 5

      # The minimum number of search results required to consider the results
      # sufficient. If a search result set is not sufficient, the search will
      # try another pass with looser options to bring in more matches.
      config.search_sufficient_results = 2

      # Default values for search boosts
      config.default_search_boosts = {
        name: 3,
        description: 0.25,
        category_names: 1,
        details: 1,
        facets: 2
      }

      # How long logged search queries are stored
      config.search_query_expiration = 30.days

      # How many products to consider stale in a reindexing batch for freshness.
      config.stale_products_size = 100

      # Minimum number of words for content to be searchable on the storefront
      config.minimum_content_search_words = 5

      # Subjects list for the contact form { 'slug' => 'description' }
      config.inquiry_subjects = {
        'orders' => 'Orders',
        'returns' => 'Returns and Exchanges',
        'products' => 'Product Information',
        'feedback' => 'Feedback',
        'general' => 'General Inquiry'
      }

      # Attributes used when copying addresses or comparing them
      config.address_attributes = [
        :first_name,
        :last_name,
        :company,
        :street,
        :street_2,
        :city,
        :region,
        :postal_code,
        :country,
        :phone_number,
        :phone_extension
      ]

      # User activity record length, e.g. the number of recently viewed products
      # to store.
      config.max_user_activities = 6

      # Map of ActiveMerchant credit card issuer to friendly display name of
      # issuer. Used to display issuer name and issuer icon in views. Unknown
      # values will display as titleized version of the ActiveMerchant key passed
      credit_card_issuers = Hash.new { |hash, key| key.titleize }
      config.credit_card_issuers = credit_card_issuers.merge(
        'visa' => 'Visa',
        'diners_club' => "Diner's Club",
        'master' => 'MasterCard',
        'discover' => 'Discover',
        'american_express' => 'American Express'
      )

      config.credit_card_issuers['bogus'] = 'Test Card' unless Rails.env.production?

      # Most credit card processors won't let a capture/purchase be refunded until
      # the transaction settles. (Most processors settle once a day).  If your processor
      # allows immediate refuding you can include extra tests around refund operations.
      config.run_credit_card_refund_tests = false

      # Determines the order in which discounts are calculated.
      config.discount_application_order = %w(
        Workarea::Pricing::Discount::Product
        Workarea::Pricing::Discount::ProductAttribute
        Workarea::Pricing::Discount::Category
        Workarea::Pricing::Discount::BuySomeGetSome
        Workarea::Pricing::Discount::QuantityFixedPrice
        Workarea::Pricing::Discount::FreeGift
        Workarea::Pricing::Discount::OrderTotal
        Workarea::Pricing::Discount::Shipping
      )

      # How long a discount can go unused before being considered stale. Stale
      # discounts will be automatically deactivated, and this will show in the
      # admin.
      config.discount_staleness_ttl = 30.days

      # Number of orders to show in account summary dashboard
      config.recent_order_count = 3

      # How many products show in a category summary content block
      config.category_summary_product_count = 6

      # How many products show in product insights content block
      config.product_insights_count = 6

      # Colors and theming for customer-facing emails
      # TODO: v4 remove
      config.email_theme = ActiveSupport::OrderedOptions.new
      config.email_theme.width = 600
      config.email_theme.background_color = '#ffffff'
      config.email_theme.layout_link_color = '#000000'
      config.email_theme.layout_separator_color = '#dddddd'
      config.email_theme.layout_background_color = '#bbbbbb'
      config.email_theme.banner_image_width = '277'
      config.email_theme.banner_image_height = '50'
      config.email_theme.heading_color = '#333333'
      config.email_theme.text_color = '#000000'
      config.email_theme.link_color = '#7a2d82'
      config.email_theme.table_background_color = '#a9a9a8'
      config.email_theme.table_border_color = '#999999'

      # Number of results to show in admin jump to search autocomplete
      config.default_admin_jump_to_result_count = 15

      # Whether or not to enforce the Workarea.config.host meaning, redirect
      # to the Workarea.config.host if the current request host doesn't match.
      #
      config.enforce_host = !Rails.env.test? && !Rails.env.development?

      # An array of the available breakpoints for the storefront,
      # Also used by admin for content preview and allowing a content block to
      # conditionally show or hide at a given breakpoint.
      Workarea.config.storefront_break_points = {
        small: 320,
        medium: 760,
        wide: 960,
        x_wide: 1160
      }

      # An array of the available breakpoints for the admin
      Workarea.config.admin_break_points = {
        small: 320,
        medium: 760,
        wide: 960,
        x_wide: 1160
      }

      # An array of breakpoints to be used in content preview
      # Can be configured independantly of all site breakpoints
      config.content_preview_breakpoints = ['small', 'medium', 'wide']

      # Origin location for calculating shipping costs
      config.shipping_origin = {
        country: 'US',
        state: 'PA',
        city: 'Philadelphia',
        zip: '19106'
      }

      # Global options for calculating shipping costs
      config.shipping_options = { units: :imperial }

      # Default package dimensions to use for calculating shipping costs.
      # It's recommended to set these to your average or standard box size when
      # using shipping rates from a carrier.
      #
      # Dimensions on a specific Shipping::Sku will override these.
      #
      config.shipping_dimensions = [1, 1, 1]

      # The content block types currently available. Most easily customized by
      # calling Workarea::Content.define_block_types
      config.content_block_types = SwappableList.new

      # Field mappings for category rules
      config.product_rule_fields = {
        search: 'search',
        category: 'facets.category_id',
        price: 'numeric.price',
        on_sale: 'facets.on_sale',
        available_inventory: 'numeric.inventory',
        created_at: 'created_at',
        excluded_products: '_id'
      }

      # The number of activity entries to show on the admin dashboard
      config.activity_size_on_dashboard = 5

      # Max amount of words to use for meta description smart defaults
      config.meta_description_max_words = 30

      # Define content areas used by views to render content. These settings are
      # used to define what areas to allow administration.
      config.content_areas = {
        'category' => %w(above_results below_results),
        'checkout' => %w(confirmation confirmation_signup),
        'customization' => %w(above_results),
        'generic' => %w(default),
        'layout' => %w(header_promo footer_navigation),
        'search' => %w(results no_results)
      }

      # Configuration for what navigation items to show in the admin jump to
      config.jump_to_navigation = {
        'Help' => :help_index_path,
        'Activity' => :activity_path,
        'Dashboard' => :root_path,
        'Products' => :catalog_products_path,
        'Assets' => :content_assets_path,
        'Categories' => :catalog_categories_path,
        'Redirects' => :navigation_redirects_path,
        'Orders' => :orders_path,
        'Pages' => :content_pages_path,
        'People' => :users_path,
        'Discounts' => :pricing_discounts_path,
        'Releases' => :releases_path,
        'Taxonomy' => :navigation_taxons_path,
        'Navigation' => :navigation_menus_path,
        'Pricing' => :pricing_skus_path,
        'Orders dashboard' => :orders_dashboards_path,
        'Catalog dashboard' => :catalog_dashboards_path,
        'Store dashboard' => :store_dashboards_path,
        'Search settings' => :search_settings_path,
        'Shipping services' => :shipping_services_path,
        'Search results customization' => :search_customizations_path,
        'Transactional email content' => :content_emails_path,
        'People dashboard' => :people_dashboards_path,
        'Inventory' => :inventory_skus_path,
        'Promo code lists' => :pricing_discount_code_lists_path,
        'Payment transactions' => :payment_transactions_path,
        'Tax categories' => :tax_categories_path,
        'Trash' => :trash_index_path,
        'Email signups' => :email_signups_path,
        'Imports and Exports' => :data_files_path,
        'Sales over Time Report' => :sales_over_time_report_path,
        'Average Order Value Report' => :average_order_value_report_path,
        'Sales by Traffic Referrer Report' => :sales_by_traffic_referrer_report_path,
        'Sales by Product Report' => :sales_by_product_report_path,
        'Sales by Category Report' => :sales_by_category_report_path,
        'Sales by SKU Report' => :sales_by_sku_report_path,
        'Sales by Discount Report' => :sales_by_discount_report_path,
        'Sales by Country Report' => :sales_by_country_report_path,
        'Customers Report' => :customers_report_path,
        'First-time vs Returning Sales Report' => :first_time_vs_returning_sales_report_path,
        'Searches Report' => :searches_report_path,
        'Low Inventory Report' => :low_inventory_report_path
      }

      # Params to permit when creating URLs on browse pages for facet links
      # and the sorting form. The current facets are appended to this list.
      config.permitted_facet_params = [
        :controller,
        :action,
        :id,
        :utf,
        :q,
        :sort
      ]

      # For monitoring, threshold for how many sidekiq jobs can be queued before
      # it is flagged as needing attention. Does not affect the behavior of sidekiq.
      #
      config.sidekiq_critical_queue_size = 25_000

      # Exclude content related to the list of classes from being index for
      # search. They will not show up in content search results.
      #
      config.exclude_from_content_search_index = %w(
        Workarea::Catalog::Category
        Workarea::Search::Customization
        Workarea::Navigation::Menu
      )

      # Fields to be skipped when storing changesets for releases
      config.untracked_release_changes_fields = %w(created_at updated_at slug)

      # Placeholder text used for content block default data.
      config.placeholder_text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin sagittis faucibus augue, sit amet mattis leo tincidunt ac. Nullam vulputate eleifend enim. Nunc eu lorem semper, convallis ipsum pharetra, pretium metus. Donec lobortis dolor ac metus vulputate vulputate nec at nulla. Suspendisse potenti. Praesent placerat elementum justo quis malesuada. Donec sollicitudin ligula augue, rutrum vestibulum ex rutrum in. Integer id orci eu nisl accumsan suscipit a ut sapien. Nam non justo at nibh laoreet tempus. Sed sagittis velit eu tellus imperdiet, et ultricies justo aliquet. Fusce id felis sem.'

      # Maximum number of most visited to show for admin shortcuts
      config.admin_max_most_visited = 3

      # Maximum number of recently visited to show for admin shortcuts
      # TODO unused, remove in v4
      config.admin_max_recently_visited = 5

      # Encoding for CSV files imported through the admin
      # TODO unused, remove in v4
      config.import_csv_file_encoding = 'r:ISO-8859-1'

      # Number of displayable bookmarks in the admin
      config.max_admin_bookmarks = 10

      # What classes get run as part of Workarea::Seeds.run
      # Plugins and implementations should add to this list.
      config.seeds = SwappableList.new(
        %w(
          Workarea::SearchSettingsSeeds
          Workarea::EmailContentSeeds
          Workarea::TaxSeeds
          Workarea::ShippingServicesSeeds

          Workarea::AssetsSeeds
          Workarea::CategoriesSeeds
          Workarea::ProductsSeeds
          Workarea::CustomerServicePagesSeeds
          Workarea::BrowsingPagesSeeds
          Workarea::DiscountsSeeds
          Workarea::DynamicContentSeeds
          Workarea::BrowseNavigationSeeds
          Workarea::CustomerServiceNavigationSeeds
          Workarea::SystemContentSeeds

          Workarea::AdminsSeeds
          Workarea::CustomersSeeds
          Workarea::OrdersSeeds
          Workarea::InquiriesSeeds
          Workarea::HelpSeeds
          Workarea::InsightsSeeds
        )
      )

      # How many searches to index in the storefront for suggestions
      config.max_searches_to_index = 1000

      # The name of the asset placeholder image file
      # TODO v3.5 remove
      # @deprecated will be removed in v3.5, use `image_placeholder_image_name`
      config.placeholder_asset_name = 'placeholder.png'

      # The name of the asset placeholder image file
      config.image_placeholder_image_name = 'placeholder.png'

      # The name of the product placeholder image file
      config.product_placeholder_image_name = 'product_placeholder.jpg'

      # The name of the OpenGraph placeholder image file
      config.open_graph_placeholder_image_name = 'open_graph_placeholder.png'

      # The name of the OpenGraph placeholder image file
      config.favicon_placeholder_image_name = 'favicon_placeholder.png'

      # Additional search option types to include in query building
      # query, post_filter, and aggregations are always included.
      config.search_query_options = %w(sort size from suggest)

      # The number of filter results returned for each filter type. As of
      # ElasticSearch 5, 0 no longer denotes returning all values. A value
      # greater than 0 must be defined.
      config.default_search_facet_result_sizes = 10

      # The number of filter results returned for any specified filter type.
      # If no size is defined for a filter type, the default will be
      # what's specified in the default config above.
      config.search_facet_result_sizes = { color: 10, size: 10 }

      # Define how facet values should be sorted when displayed on the
      # storefront. You can provide a symbol for elasticsearch supported order
      # options - :count, :alphabetical_asc, or :alphabetical_desc. You can also
      # provide a proc or the name of a class that responds to `call`. The proc
      # or class will be handed the hash of facets values with count along with
      # the name of the facet and should return the sorted hash.
      #
      # Providing a proc
      # color: -> (name, result) { # reorder results here }
      #
      config.search_facet_sorts = {
        category: :alphabetical_asc,
        color: :count,
        size: 'Workarea::Search::FacetSorting::Size'
      }

      # The default sorting of facet types not defined in
      # Workarea.config.search_facet_sorts. See search_facet_sorts for
      # valid options.
      config.search_facet_default_sort = :count

      # The size to use for a facet aggregation when being ordered dynamically
      # through a proc or class. We do this to return all values so the facets
      # returned can be sorted before being narrowed to the size defined
      # in Workarea.config.search_facet_result_sizes
      config.search_facet_dynamic_sorting_size = 100

      # The order the size facets will be rendered in on storefront search
      # results and category browse.
      config.search_facet_size_sort =
        ['Extra Small', 'Small', 'Medium', 'Large', 'Extra Large']

      # Countries available for use
      config.countries = [Country['US'], Country['CA']]

      # Classes to use when trying to find a name for a content block based on
      # its fields. Must be a Mongoid::Document and instances must respond to
      # #name
      config.content_block_name_search_classes = SwappableList.new(
        %w(
          Workarea::Content::Asset
          Workarea::Navigation::Taxon
          Workarea::Catalog::Category
          Workarea::Content::Page
        )
      )

      # Mappings used for the various Elasticsearch indexes
      config.elasticsearch_mappings = ActiveSupport::Configurable::Configuration.new
      config.elasticsearch_mappings.admin = {
        admin: {
          dynamic_templates: [
            {
              facet_values: {
                path_match: 'facets.*',
                mapping: {  type: 'keyword', analyzer: 'keyword' }
              }
            }
          ],
          properties: {
            id: { type: 'keyword' },
            name: { type: 'keyword' },
            model_class: { type: 'keyword' },
            type: { type: 'keyword' },
            status: { type: 'keyword' },
            keywords: { type: 'keyword' },
            search_text: { type: 'text', analyzer: 'text_analyzer' },
            jump_to_text: { type: 'text', analyzer: 'autocomplete_analyzer' },
            jump_to_search_text: { type: 'text', analyzer: 'autocomplete_analyzer' },
            jump_to_position: { type: 'integer' },
            jump_to_param: { type: 'keyword' },
            updated_at: { type: 'date' },
            releasable: { type: 'boolean' },
            placed_at: { type: 'date' }
          }
        }
      }

      config.elasticsearch_mappings.storefront = {
        category: { properties: { query: { type: 'percolator' } } },
        storefront: {
          dynamic_templates: [
            {
              facets: {
                path_match: 'facets.*',
                mapping: {  type: 'keyword' }
              }
            },
            {
              numeric: {
                path_match: 'numeric.*',
                mapping: { type: 'float' }
              }
            },
            {
              keywords: {
                path_match: 'keywords.*',
                mapping: { type: 'keyword' }
              }
            },
            {
              sorts: {
                path_match: 'sorts.*',
                mapping: { type: 'float' }
              }
            },
            {
              content: {
                path_match: 'content.*',
                mapping: { type: 'text', analyzer: 'text_analyzer' }
              }
            },
            {
              cache: {
                path_match: 'cache.*',
                mapping: { index: false }
              }
            }
          ],
          properties: {
            id: { type: 'keyword' },
            type: { type: 'keyword' },
            slug: { type: 'keyword' },
            suggestion_content: { type: 'string', analyzer: 'suggestion_analyzer' },

            # This would be covered by the facets dynamic mapping but to reduce
            # the likelihood of no-field-mapping errors, including
            # out-of-the-box mappings here.
            'keywords.name' => { type: 'keyword' },
            'keywords.catalog_id' => { type: 'keyword' },
            'keywords.sku' => { type: 'keyword' },
            'facets.category_id' => { type: 'keyword' },
            'facets.on_sale' => { type: 'keyword' }
          }
        }
      }

      config.elasticsearch_mappings.help = {
        help: {
          dynamic_templates: [
            {
              facet_values: {
                path_match: 'facets.*',
                mapping: {  type: 'string', analyzer: 'keyword' }
              }
            }
          ],
          properties: {
            id: { type: 'string', index: 'not_analyzed' },
            name: { type: 'string', analyzer: 'text_analyzer' },
            body: { type: 'string', analyzer: 'text_analyzer' },
            created_at: { type: 'date' }
          }
        }
      }

      config.elasticsearch_mappings.order = {
        order: {
          properties: {
            id: { type: 'string', index: 'not_analyzed' },
            email: { type: 'string', index: 'not_analyzed'},
            user_id: { type: 'string', index: 'not_analyzed'},
            status: { type: 'string', index: 'not_analyzed'},

            placed: { type: 'boolean' },
            placed_at: { type: 'date' },
            placed_in: { type: 'integer' },

            guest_checkout: { type: 'boolean' },
            returning_customer: { type: 'boolean' },

            total_value: { type: 'double' },
            total_price: { type: 'double' },
            total_revenue: { type: 'double' },

            shipping_services: { type: 'string', index: 'not_analyzed'},
            regions: { type: 'string', index: 'not_analyzed'},
            payment_methods: { type: 'string', index: 'not_analyzed'},

            discounts: { type: 'string', index: 'not_analyzed'},
            discounts_redeemed: { type: 'integer' },

            created_at: { type: 'date' },
            expires_at: { type: 'date' }
          }
        }
      }

      # The Elasticsearch settings used for all indexes. Invalid if used as
      # defined here because the synonym filter isn't defined. If you want to
      # use these, use Workarea::Search::Settings.current.elasticsearch_settings
      # instead. That method will add the synonyms for the current locale, as
      # defined by the admin.
      #
      # Feel free to customize these to achieve the best possible search
      # results. Read the documentation here:
      #
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis.html
      #
      config.elasticsearch_settings = {
        analysis: {
          filter: {
            snowball: { type: 'snowball', language: 'English' }
          },
          analyzer: {
            text_analyzer: {
              type: 'custom',
              tokenizer: 'standard',
              char_filter: %w(html_strip),
              filter: %w(lowercase synonym snowball)
            },
            autocomplete_analyzer: {
              type: 'custom',
              tokenizer: 'standard',
              filter: %w(lowercase stop)
            },
            suggestion_analyzer: {
              type: 'custom',
              tokenizer: 'standard',
              char_filter: %w(html_strip),
              filter: %w(lowercase)
            }
          }
        }
      }

      # In test env, only use a single shard. This is for consistency when
      # scoring documents in testing. Elasticsearch scores can vary based on
      # number of shards.
      #
      # http://www.elasticsearch.org/guide/en/elasticsearch/guide/current/relevance-is-broken.html
      #
      if Rails.env.test?
        config.elasticsearch_settings.merge!(
          number_of_shards: 1,
          number_of_replicas: 0
        )
      end

      # Used in the logarithm to smooth out the effect views has on product
      # scoring in search. A factor greater than 1 increases the effect, and a
      # factor less than 1 decreases the effect
      config.default_search_views_factor = 1

      # Used to add in scores from fields that didn't win the dismax. Setting it
      # to 1 makes it an even boolean OR between fields.
      config.search_dismax_tie_breaker = 0.5

      # The minimum number of documents a term should appear in before being
      # considered a relevant term to suggest in search.
      config.search_suggestion_min_doc_freq = 2

      # Used in the admin ChangesetsHelper to map types of releasables to icons
      # Icons are displayed on planned changes view
      config.releasable_icons = {
        block: 'workarea/admin/icons/content.svg',
        customization: 'workarea/admin/icons/search.svg',
        discount: 'workarea/admin/icons/pricing_discount.svg',
        menu: 'workarea/admin/icons/menu.svg',
        price: 'workarea/admin/icons/pricing_sku.svg',
        product: 'workarea/admin/icons/products.svg',
        sku: 'workarea/admin/icons/variants.svg'
      }

      # Classes run as middleware for storefront site searches
      config.storefront_search_middleware = SwappableList.new(
        %w(
          Workarea::Search::StorefrontSearch::Redirect
          Workarea::Search::StorefrontSearch::ExactMatches
          Workarea::Search::StorefrontSearch::ProductMultipass
          Workarea::Search::StorefrontSearch::SpellingCorrection
          Workarea::Search::StorefrontSearch::Template
        )
      )

      # Release session timeout - how long a release is worked on before a
      # reminder is shown.
      config.release_session_timeout = 30.minutes

      # The number of pages viewed before an admin is reminded that they have a
      # release in their session.
      config.release_session_max_page_views = 30

      # The document types to exclude from activity feed
      config.activity_excluded_types = SwappableList.new(
        %w(Workarea::Release::Changeset)
      )

      # The regexes, names, and links used to show tracking links in order history.
      # Used in ShippingCarrierViewModel
      config.shipping_service_tracking_links = {
        /^1Z/i => ['UPS', 'http://wwwapps.ups.com/WebTracking/track?track=yes&trackNums='],
        /^[0-9]{12,15}$/ => ['FedEx', 'http://www.fedex.com/Tracking?action=track&tracknumbers='],
        /^[0-9]{4,4}\s?[0-9]{4,4}\s?[0-9]{4,4}\s?[0-9]{4,4}\s?[0-9]{4,4}\s?[0-9]{2,2}$/ => ['USPS', 'https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=']
      }

      # The paths to exclude from logged admin page visits
      config.admin_visit_excluded_paths = %w(root_path toolbar_path)

      # Minimum available quantity for a sku before
      # low inventory status is displayed.
      config.low_inventory_threshold = 5

      # Maximum number of similar products to store with each product.
      # See https://github.com/Pathgather/predictor#limiting-similarities
      config.max_recommendation_similarities = 64

      # How long an order or session contents contribute to recommendations.
      # Adjust this for performance depending on volume.
      config.recommendation_expiration = 90.days

      # Default sources for product-based recommendations. This OOB order is
      # based on conversion rate.
      config.product_based_recommendation_default_sources = %w(custom similar purchased)

      # Number of recommendations to show on the detail page
      config.detail_page_recommendations_count = 6

      # Number of recommendations to show in the personalized recommendations
      # content block
      config.personalized_recommendations_count = 6

      # Number of recommendations to show in transactional emails
      config.email_recommendations_count = 4

      # Number of recommendations to show on the cart
      config.cart_recommendations_count = 6

      # Maximum number of admin related help articles to return
      config.max_admin_related_help = 3

      # The TTL of bulk action records
      config.bulk_action_expiration = 6.months

      # Classes used to update checkout data and determine checkout status.
      # Used in Workarea::Checkout
      config.checkout_steps = SwappableList.new(
        %w(
          Workarea::Checkout::Steps::Addresses
          Workarea::Checkout::Steps::Shipping
          Workarea::Checkout::Steps::Payment
        )
      )

      # Classes used to determine the status of a Workarea::Fulfillment
      config.fulfillment_status_calculators = SwappableList.new(
        %w(
          Workarea::Fulfillment::Status::NotAvailable
          Workarea::Fulfillment::Status::Open
          Workarea::Fulfillment::Status::Canceled
          Workarea::Fulfillment::Status::Shipped
          Workarea::Fulfillment::Status::PartiallyShipped
          Workarea::Fulfillment::Status::PartiallyCanceled
        )
      )

      # Classes used to determine the status of a Workarea::Order
      config.order_status_calculators = SwappableList.new(
        %w(
          Workarea::Order::Status::Cart
          Workarea::Order::Status::Canceled
          Workarea::Order::Status::Placed
          Workarea::Order::Status::Checkout
          Workarea::Order::Status::Abandoned
        )
      )

      # Classes used to determine the status of a Workarea::Payment
      config.payment_status_calculators = SwappableList.new(
        %w(
          Workarea::Payment::Status::NotApplicable
          Workarea::Payment::Status::Pending
          Workarea::Payment::Status::Authorized
          Workarea::Payment::Status::Captured
          Workarea::Payment::Status::Refunded
          Workarea::Payment::Status::PartiallyCaptured
          Workarea::Payment::Status::PartiallyRefunded
        )
      )

      # Defines the state level for payment and fulfillment statuses.
      config.status_state_indicators = {
        open: 'pending',
        canceled: 'done',
        shipped: 'done',
        partially_shipped: 'danger',
        partially_canceled: 'danger',
        not_applicable: 'done',
        pending: 'danger', # payment pending
        authorized: 'pending',
        captured: 'done',
        refunded: 'done',
        partially_captured: 'danger',
        partially_refunded: 'done',
        not_available: 'pending'
      }

      # Classes used to determine the status of a Workarea::Release
      config.release_status_calculators = SwappableList.new(
        %w(
          Workarea::Release::Status::Unscheduled
          Workarea::Release::Status::Scheduled
          Workarea::Release::Status::Published
          Workarea::Release::Status::Undone
          Workarea::Release::Status::ScheduledUndo
        )
      )

      # How many recent views to show
      config.user_activity_display_size = 4

      # Classes used to manage inventory. Must inherit from
      # Workarea::Inventory::Policies::Base. The first in this list will be used
      # as the default (Ignore is highly recommended default).
      config.inventory_policies = SwappableList.new(
        %w(
          Workarea::Inventory::Policies::Ignore
          Workarea::Inventory::Policies::Standard
          Workarea::Inventory::Policies::DisplayableWhenOutOfStock
          Workarea::Inventory::Policies::AllowBackorder
        )
      )

      # Classes used to calculate pricing. They are run in this order.
      config.pricing_calculators = SwappableList.new(
        %w(
          Workarea::Pricing::Calculators::ItemCalculator
          Workarea::Pricing::Calculators::CustomizationsCalculator
          Workarea::Pricing::Calculators::OverridesCalculator
          Workarea::Pricing::Calculators::DiscountCalculator
          Workarea::Pricing::Calculators::TaxCalculator
        )
      )

      # values changed on a product when copied via CopyProduct
      config.product_copy_default_attributes = {
        active: false,
        slug: nil,
        created_at: nil,
        updated_at: nil
      }

      # Fields that do not get copied to the new order when cloning an order.
      config.copy_order_ignored_fields = %i(
        token checkout_started_at placed_at canceled_at created_at updated_at
      )

      # Options to pass to gravatar when looking up an image for an admin avatar
      # See more info at https://en.gravatar.com/site/implement/images/
      config.gravatar_options = { s: 80, default: 'identicon' }

      # Length of time that Rails' caches exist
      #
      # WARNING - changing these values will affect your application's performance
      #
      config.cache_expirations = ActiveSupport::Configurable::Configuration.new
      config.cache_expirations.http_cache = 15.minutes
      config.cache_expirations.content_blocks = 1.hour
      config.cache_expirations.discount_application_groups = 15.minutes
      config.cache_expirations.shipping_services = 1.hour
      config.cache_expirations.tax_rate_by_code = 5.minutes
      config.cache_expirations.products_default_category = 1.day
      config.cache_expirations.render_content_blocks = 1.hour
      config.cache_expirations.cart_recommendations_fragment_cache = 3.hours
      config.cache_expirations.categories_fragment_cache = 1.hour
      config.cache_expirations.pages_fragment_cache = 1.hour
      config.cache_expirations.product_pricing_fragment_cache = 1.week
      config.cache_expirations.product_summary_fragment_cache = 75.minutes
      config.cache_expirations.product_show_fragment_cache = 1.hour
      config.cache_expirations.left_navigation_fragment_cache = 1.day
      config.cache_expirations.sitemap_fragment_cache = 1.day
      config.cache_expirations.free_gift_attributes = 1.hour
      config.cache_expirations.reports = 1.hour

      # Send transactional emails. Allows default transaction emails to be
      # disabled when using third-party email services.
      config.send_transactional_emails = true

      # How much to boost an exact match in a search result. Result scores are
      # then checked against this value, and if a result has at least this score
      # the response will redirect to that result. It should be sufficiently
      # high as to not be accidentally triggered by a normal matching score.
      config.search_exact_match_score = 9_999

      # How much boost is given to search results where there is a phrase match
      # with the product name. People associate a lot of weight with name
      # matching so it makes sense to dramatically boost these matches. This
      # should be less than search_exact_match_score so it doesn't accidentally
      # trigger an exact match.
      config.search_name_phrase_match_boost = 999

      # Allow skipping enforcing host
      config.skip_enforce_host = ->(request) { request.user_agent =~ /ELB-Health/ }

      # Determines the time a lock is held before it automatically releases
      config.default_lock_expiration = 30.seconds

      # How many items per-page to use when performing a bulk action from the
      # admin. If you find your bulk action Sidekiq workers are using too much
      # memory, lower this value.
      config.bulk_action_per_page = 500

      # location to store results of performance tests
      config.performance_test_output_path = 'tmp/performance'

      # Maximum percentage increase in time between performance test runs
      config.performance_test_max_percentage_of_change = 0.25

      # Number of previous result times to compare a performance test
      # time against
      config.performance_test_comparisons = 3

      # Limit outgoing email in qa / staging environments to admin users
      # If the below lambda evaluates to true then the message will be sent
      # A boolean value can also be used - the test environment sets this to false
      config.send_email = lambda { |message|
        return true if Rails.env.in?(%w(test development production))
        recipients = (Array(message.to) + Array(message.cc) + Array(message.bcc)).compact

        recipients.any? do |email|
          email.in?(Workarea::User.admins.pluck(:email))
        end
      }

      # The number of orders to load per query when generating
      # product recommendations
      config.product_recommendation_index_page_size = 500

      # The number of user_activity documents to load per query when generating
      # search recommendations
      config.search_recommendation_index_page_size = 500

      # Capybara window dimensions
      config.capybara_browser_width = 1400
      config.capybara_browser_height = 768

      # Whether the app should skip connecting to external services on boot,
      # such as Mongo, Elasticsearch, or Redis.
      config.skip_service_connections = ENV['WORKAREA_SKIP_SERVICES'].to_s =~ /true/

      # This is a feature flag, which enables localized active fields. If you're
      # upgrading, you can set this to false to avoid having to do a MongoDB
      # migration.
      config.localized_active_fields = true

      # Options passed to headless chrome driver at initialization
      #
      # This will be renamed in an upcoming minor to allow for more flexibility
      # in how Chrome gets configured.
      config.headless_chrome_options = [
        'headless',
        'disable-gpu',
        'disable-popup-blocking',
        '--enable-features=NetworkService,NetworkServiceInProcess',
        "--window-size=#{config.capybara_browser_width},#{config.capybara_browser_width}"
      ]

      # HTTP caching headers can mess up system tests so we disable HTTP caching in tests.
      # Certain tests (for instance, AB testing plugin) want to be able to test caching
      # headers correctly, so we offer disabling this. But it should only be done on a test
      # by test basis, turning this off will break system tests completely.
      config.strip_http_caching_in_tests = true

      # Determines the sort order for the option selections for those product detail
      # templates. Return the options passed in the order you'd like them to
      # appear in the template. We pass the product in case there are other
      # factors to base sorting on.
      config.option_selections_sort = ->(product, options) { options.sort_by(&:name) }

      # Maximum character length of the :return_to URL, so a cookie
      # overflow error won't get thrown.
      config.return_to_url_max_length = 800

      # All fields on the User model which related to permissions. Used to
      # determine which fields to grant to super admin.
      config.permissions_fields = %i(admin releases_access store_access
        catalog_access search_access orders_access people_access reports_access
        settings_access marketing_access help_admin permissions_manager
        can_publish_now can_restore)

      # Whitelist of sizes that will be processed with AssetEndpoints::Favicons
      # Used for favicons_path(size)
      config.favicon_allowed_sizes = %w(32x32 16x16 150x150 180x180 192x192 512x512)

      # Data used for generating .webmanifest content and related meta tags
      # See https://developer.mozilla.org/en-US/docs/Web/Manifest for options.
      config.web_manifest = ActiveSupport::Configurable::Configuration.new

      # Used for the Windows Metro tile background color.
      # Default matches Metro's blue.
      config.web_manifest.tile_color = '#2d89ef'

      # Used to define a background color within the site.webmanifest. Useful
      # when the manifest is available before the application styles.
      # Default is white.
      config.web_manifest.background_color = '#ffffff'

      # Used to customize elements of the browser for various platforms.
      # Default is Workarea blue.
      config.web_manifest.theme_color = '#0060ff'

      # Preferred display mode for the web application when loaded from a
      # smartphone homescreen.
      config.web_manifest.display_mode = 'standalone'

      # Fields ignored in the generated import samples
      config.data_file_ignored_fields = %w(
        subscribed_user_ids
        last_indexed_at
        pricing_cache_key
        lock_expires_at
        product_attributes
        password_digest
        super_admin
        user_activity_id
        checkout_by_id
        price_adjustments
        purchased
      )

      # Supported file formats for generic data file management. The first will be the default.
      config.data_file_formats = %w(json csv)

      # How many examples to show in the import sample file produced in the admin
      config.data_file_sample_size = 2

      # How long to keep records of import/export around
      config.data_file_operation_ttl = 3.months

      # Define files used for asset manifests
      config.asset_manifests = ActiveSupport::Configurable::Configuration.new
      config.asset_manifests.storefront_stylesheet = 'workarea/storefront/application.css'
      config.asset_manifests.storefront_email_stylesheet = 'workarea/storefront/email.css'
      config.asset_manifests.storefront_javascript = 'workarea/storefront/application.js'
      config.asset_manifests.storefront_javascript_head = 'workarea/storefront/head.js'

      # An admin selecting more items than this threshold will be taken
      # to a second page to confirm their deletion. Otherwise a basic
      # confirmation dialog will be used. This is to minimize the risk of
      # accidentally deleting a large number of items.
      config.bulk_action_deletion_confirmation_threshold = 10

      config.product_rule_preview_search_classes = {
        'Workarea::Search::Customization' => 'Workarea::Search::ProductSearch',
        'Workarea::Catalog::Category' => 'Workarea::Search::CategoryBrowse'
      }

      # The percentage of products/categories/discounts to be displayed within
      # the admin as top and/or trending based on revenue of the last 4 weeks.
      config.top_or_trending_threshold = {
        product: 0.03,
        category: 0.03,
        discount: 0.03
      }

      # Regular Expression for HTML5 Pattern Validation of filters in
      # the admin. Filters can be added through the UI, but they cannot
      # be named "Type" or "type", otherwise the attribute could cause
      # mapping issues within Elasticsearch. This pattern also validates
      # a lack of trailing or preceding spaces, as these are typical
      # typing errors that are difficult to see within the admin.
      #
      # It is not generally recommended that you change this setting.
      config.product_filter_input_validation_pattern = '\b(?!type|Type)\b\S+$|^(\S+\s\S+)*$'

      # How long direct-to-s3 upload URLs last - they are signed and expire after
      # this amount of time.
      config.product_bulk_image_upload_access_time = 5.minutes

      # How product bulk image upload image naming conventios get validated
      config.direct_upload_product_image_filename_regex = /[^.]*\.\d+\..+/

      # How product bulk image upload image naming conventions get processed into
      # attributes for the image. This default provides the convention:
      # `product_id.position.option.jpg`. So for example, `00A.1.green.jpg` would
      # create an image for the `00A` product with position of 1 and option of green.
      config.direct_upload_product_image_filename_processor = lambda do |filename|
        pieces = filename.split('.')

        {
          product_id: pieces[0],
          position: pieces[1].to_i,
          option: pieces.length > 3 ? pieces[2] : nil
        }
      end

      # Provide some dummy credentials for testing. These get passed to Fog
      # which will be mocked in the test env.
      if Rails.env.test?
        config.s3 = {
          region: 'us-east-1',
          bucket_name: 'workarea',
          access_key_id: '{ACCESS_KEY_ID}',
          secret_access_key: '{SECRET_ACCESS_KEY}',
        }
      end

      # The default amount of time over which to report when generating reports
      # in the admin.
      config.reports_default_starts_at = -> { 3.months.ago }

      # The maximum number of results to display in the admin for a report.
      # Additional results can be retrieved with an export.
      config.reports_max_results = 500

      # How long to keep records of reports exports around
      config.reports_export_ttl = 3.months

      # Skip the appending of partials or assets by using a mix of strings,
      # regular expressions, or Procs.
      config.skip_partials = []
      config.skip_stylesheets = []
      config.skip_javascripts = []

      # The maximum number of products a category can have featured before
      # IndexCategoryChanges will queue individual workers for batches of
      # products rather than indexing the products inline. This change prevents
      # memory issues with storing a large elasticsearch request in memory.
      config.category_inline_index_product_max_count = 100

      # The number of documents to move at a time when generating insights
      # aggregation data.
      config.insights_aggregation_per_page = 1000

      # How many products to include in product-list insights, like promising
      # products, star products, etc.
      config.insights_products_list_max_results = 4

      # How many users to include in user-list insights, like best customers,
      # customers at risk, etc.
      config.insights_users_list_max_results = 5

      # How many users to include in category-list insights, like top categories,
      # hot categories, etc.
      config.insights_categories_list_max_results = 5

      # How many searches to include in search-list insights, like popular
      # searches, searches without results, etc.
      config.insights_searches_list_max_results = 5

      # How many searches to include in release-list insights, like upcoming
      # releases and release reminder.
      config.insights_releases_list_max_results = 3

      # How many searches to include in discount-list insights, like top
      # discounts and most discount given.
      config.insights_discounts_list_max_results = 3

      # Models that are represented in insights. Used to dynamically
      # fetch documents associated to generated insights.
      config.insights_model_classes = %w(
        Workarea::Catalog::Category
        Workarea::Catalog::Product
        Workarea::Release
        Workarea::Pricing::Discount
        Workarea::Navigation::Menu
      )

      # Options passed to Chartkick gem for rendering graphs.
      config.default_chartkick_options = {
        width: '90%',
        height: '150px',
        colors: %w(#0060ff #ff8100),
        thousands: ','
      }

      # Configuration keys to hide from Settings Dashboard
      config.hide_from_settings = %i(gateways)

      # The default length of time to tell elasticsearch to keep the scroll
      # context alive.
      config.elasticsearch_default_scroll = '3m'

      # This is how long data will count towards sorting scores. Sorting scores
      # drive top sellers and most popular sorts.
      config.sorting_score_ttl = 1.year

      # The number of data points in an admin sparkline. These are shown on
      # index pages, in cards, and in autocompletes.
      config.admin_sparkline_size = 10

      # The maximum number of categories that are returned by
      # +Search::Storefront::Product::Categories.find_categories!+ when
      # a user attempts to view all categories by rules for a given
      # product in the admin.
      config.product_categories_by_rules_max_count = 100

      # Parameters to ignore when rendering breadcrumbs for search results
      config.exclude_from_search_results_breadcrumbs = %i(
        action
        controller
        authenticity_token
        utf
        terms_facets
        range_facets
        rules
        pass
      )

      # Taxonomy for default seeds
      config.default_seeds_taxonomy = {
        'Clothing' => ['T-Shirts', 'Shoes', 'Loungewear'],
        'Tech' => ['Phone Cases', 'Headphones', 'Gaming'],
        'Books' => ['Fiction', 'Non-Fiction', "Children's"],
        'Toys' => ['Puzzles', 'Board Games', 'Outdoor']
      }

      # Options for reading and decoding CSV import data. Use this
      # setting to configure the `:encoding` options for `CSV.foreach`
      # if your CSV files are failing to import with a UTF-8 encoding
      # error.
      config.csv_import_options = {}
    end
  end
end
