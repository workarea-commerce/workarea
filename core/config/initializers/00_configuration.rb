Workarea::Configuration.define_fields do
  fieldset :users, namespaced: false do
    field :allowed_login_attempts,
      type: :integer,
      default: 6,
      description: 'How many failed login attempts before marking the user locked out'

    field :password_strength,
      type: :symbol,
      default: :weak,
      values: [
        ['Weak', :weak, title: 'Requires minimum 7 characters'],
        ['Medium', :medium, title: 'Requires minimum 7 characters of letters and numbers'],
        ['Strong', :strong, title: 'Requires minimum 8 characters consisting of letters, numbers, and special characters.']
      ],
      description: 'Password requirement level for customers. Admin users always require a strong password.'
  end

  fieldset :checkout, namespaced: false do
    field :checkout_expiration,
      type: :duration,
      default: 15.minutes,
      description: 'How long a checkout can be idle before the user is forced to restart'

    field :item_count_limit,
      type: :integer,
      default: 100,
      description: 'How many unique items can be added to a single cart'
  end

  fieldset :orders, namespaced: false do
    field :order_active_period,
      type: :duration,
      default: 2.hours,
      description: 'How long an order is active without changing before considering it abandoned'

    field :order_expiration_period,
      type: :duration,
      default: 6.months,
      description: 'How long to wait until abandoned orders are deleted from the database'

    field :recent_order_count,
      type: :integer,
      default: 3,
      description: 'Number of orders to show in account summary dashboard'

    field :storefront_user_order_display_count,
      type: :integer,
      default: 50,
      description: 'Number of orders to display on the user order history page'
  end

  fieldset :shipping, namespaced: false do
    field :allow_shipping_address_po_box,
      name: 'Allow Shipping Address P.O. Box',
      type: :boolean,
      default: false,
      description: 'Whether or not to allow P.O. Box addresses for shipping addresses'

    field :shipping_dimensions,
      type: :array,
      default: [1, 1, 1],
      values_type: :integer,
      description: %(
        Default package dimensions to use for calculating shipping costs.
        It's recommended to set these to your average or standard box size when
        using shipping rates from a carrier. Dimensions on specific shipping SKUs
        will override this value.
      ).squish

    field :shipping_origin,
      type: :hash,
      default: {
        country: 'US',
        state: 'PA',
        city: 'Philadelphia',
        zip: '19106'
      },
      description: 'Origin location for calculating shipping costs'

    # This can be overwritten within the app to use a proc for more complex
    # scenarios.
    field 'Default Shipping Service Tax Code',
      type: String,
      required: false,
      description: %(
        Tax code assigned to shipping options when an existing service does
        not exist. This is useful for third-party gateways to assign tax codes
        to dynamically generated options.
      ).squish
  end

  fieldset :payment, namespaced: false do
    field :allow_payment_address_po_box,
      name: 'Allow Payment Address P.O. Box',
      type: :boolean,
      default: true,
      description: 'Whether or not to allow P.O. Box addresses for billing addresses'
  end

  fieldset :inventory, namespaced: false do
    field :low_inventory_threshold,
      type: :integer,
      default: 5,
      description: 'Minimum available quantity for a sku before inventory is considered low'
  end

  fieldset :content, namespaced: false do
    field :automate_seo_data,
      type: :boolean,
      default: true,
      description: 'Globally control whether automated SEO content is generated'

    field :minimum_content_search_words,
      type: :integer,
      default: 5,
      description: 'Minimum number of words for content to be searchable on the storefront'

    field :placeholder_text,
      type: :string,
      default: %(
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin sagittis
        faucibus augue, sit amet mattis leo tincidunt ac. Nullam vulputate
        eleifend enim. Nunc eu lorem semper, convallis ipsum pharetra, pretium
        metus. Donec lobortis dolor ac metus vulputate vulputate nec at nulla.
        Suspendisse potenti. Praesent placerat elementum justo quis malesuada.
        Donec sollicitudin ligula augue, rutrum vestibulum ex rutrum in.
        Integer id orci eu nisl accumsan suscipit a ut sapien. Nam non justo at
        nibh laoreet tempus. Sed sagittis velit eu tellus imperdiet, et ultricies
        justo aliquet. Fusce id felis sem.
      ).squish,
      description: 'Placeholder text used for content block default data'
  end

  fieldset :search, namespaced: false do
    field :search_facet_result_sizes,
      type: :hash,
      values_type: :integer,
      default: { color: 10, size: 10 },
      description: %(
        The number of filter results returned for any specified filter type. If no
        size is defined for a filter type, the default will be what is specified
        in the default config below.
      ).squish

    field :default_search_facet_result_sizes,
      type: :integer,
      default: 10,
      description: %(
        The number of filter results returned for each filter type when not
        specified above.
      ).squish

    field :search_facet_size_sort,
      name: 'Search Size Facet Sort',
      type: :array,
      default: ['Extra Small', 'Small', 'Medium', 'Large', 'Extra Large'],
      description: %(
        The order the size facets will be displayed on storefront search results
        and category browse.
      ).squish

    field :search_sufficient_results,
      type: :integer,
      default: 2,
      description: %(
        The minimum number of search results required to consider the results
        sufficient. If a search result set is not sufficient, the search will
        try another pass with looser options to bring in more matches.
      ).squish

    field :search_suggestions,
      type: :integer,
      default: 5,
      description: 'How many search suggestions should be shown in the autocomplete searches.'
  end

  fieldset :communication, namespaced: false do
    field :show_privacy_popup, type: :boolean, default: false

    field :email_from,
      type: :string,
      default: -> { "#{Workarea.config.site_name} <noreply@#{Workarea.config.host}>" },
      description: 'The email address used as the sender of system emails'

    field :email_to,
      type: :string,
      default: -> { "#{Workarea.config.site_name} <customerservice@#{Workarea.config.host}>" },
      description: 'The email address that receives user generated emails, e.g. contact us inquiries'

    field :inquiry_subjects,
      type: :hash,
      default: {
        'orders' => 'Orders',
        'returns' => 'Returns and Exchanges',
        'products' => 'Product Information',
        'feedback' => 'Feedback',
        'general' => 'General Inquiry'
      },
      description: 'Subjects list for the contact form'
  end

  fieldset :recaptcha_v3, name: 'reCAPTCHA v3' do
    description %(
      <p>reCAPTCHA v3 returns a score for each request without user friction.
      The score is based on interactions with your site and enables you to take
      an appropriate action for your site. Register reCAPTCHA v3 keys
      <a href="https://g.co/recaptcha/v3">here</a>.</p>
      <p>If this verification fails, and you have reCAPTCHA v2 configured,
      Workarea will challenge the user with reCAPTCHA v2. We recommend
      configuring both.</p>
    ).squish.html_safe

    field :site_key, name: 'v3 Site Key', type: :string, required: false
    field :secret_key, name: 'v3 Secret Key', type: :string, required: false, encrypted: true
    field :minimum_score,
      name: 'Minimum Score',
      type: :float,
      default: 0.5,
      description: %(
        The minimum score required to consider the user a human and not a bot.
        1.0 is very likely a good interaction, 0.0 is very likely a bot.
      ).squish
  end

  fieldset :recaptcha_v2, name: 'reCAPTCHA v2' do
    description %(
      <p><strong>Don't configure this without configuring reCAPTCHA v3 above.</strong></p>
      <p>reCAPTCHA v2 verifies if an interaction is legitimate with the “I am not a
      robot” checkbox and invisible reCAPTCHA badge challenges. Register
      reCAPTCHA v2 keys <a href="https://www.google.com/recaptcha/admin/create">
      here</a>.</p>
      <p>This is only used in Workarea if reCAPTCHA v3 isn't configured or the v3
      verification fails. We recommend configuring both.</p>
    ).squish.html_safe

    field :site_key, name: 'v2 Site Key', type: :string, required: false
    field :secret_key, name: 'v2 Secret Key', type: :string, required: false, encrypted: true
  end

  fieldset :security, namespaced: false do
    field :safe_ip_addresses,
      name: 'Safe IP Addresses',
      type: :array,
      default: [],
      required: false,
      description: 'List of known IP addresses and/or IP addresses ranges a that should always have access to the site.'

    field :blocked_ip_addresses,
      name: 'Blocked IP Addresses',
      type: :array,
      default: [],
      required: false,
      description: 'List of known IP addresses and/or IP addresses ranges to block from site access.'
  end
end
