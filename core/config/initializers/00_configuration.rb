Workarea::Configuration.define_fields do
  fieldset 'Users', namespaced: false do
    field 'Allowed Login Attempts',
      type: :integer,
      default: 6,
      description: 'How many failed login attempts before marking the user locked out'

    field 'Password Strength',
      type: :symbol,
      default: :weak,
      values: [
        ['Weak', :weak, title: 'Requires minimum 7 characters'],
        ['Medium', :medium, title: 'Requires minimum 7 characters of letters and numbers'],
        ['Strong', :strong, title: 'Requires minimum 8 characters consisting of letters, numbers, and special characters.']
      ],
      description: 'Password requirement level for customers. Admin users always require a strong password.'
  end

  fieldset 'Checkout', namespaced: false do
    field 'Checkout Expiration',
      type: :duration,
      default: 15.minutes,
      description: 'How long a checkout can be idle before the user is forced to restart'

    field 'Item Count Limit',
      type: :integer,
      default: 100,
      description: 'How many unique items can be added to a single cart'
  end

  fieldset 'Orders', namespaced: false do
    field 'Order Active Period',
      type: :duration,
      default: 2.hours,
      description: 'How long an order is active without changing before considering it abandoned'

    field 'Order Expiration Period',
      type: :duration,
      default: 6.months,
      description: 'How long to wait until abandoned orders are deleted from the database'

    field 'Recent Order Count',
      type: :integer,
      default: 3,
      description: 'Number of orders to show in account summary dashboard'

    field 'Storefront User Order Display Count',
      type: :integer,
      default: 50,
      description: 'Number of orders to display on the user order history page'
  end

  fieldset 'Shipping', namespaced: false do
    field 'Allow Shipping Address P.O. Box',
      id: :allow_shipping_address_po_box,
      type: :boolean,
      default: false,
      description: 'Whether or not to allow P.O. Box addresses for shipping addresses'

    field 'Shipping Dimensions',
      type: :array,
      default: [1, 1, 1],
      description: %(
        Default package dimensions to use for calculating shipping costs.
        It's recommended to set these to your average or standard box size when
        using shipping rates from a carrier. Dimensions on specific shipping SKUs
        will override this value.
      ).squish

    field 'Shipping Origin',
      type: :hash,
      default: {
        country: 'US',
        state: 'PA',
        city: 'Philadelphia',
        zip: '19106'
      },
      description: 'Origin location for calculating shipping costs'
  end

  fieldset 'Payment', namespaced: false do
    field 'Allow Payment Address P.O. Box',
      id: :allow_payment_address_po_box,
      type: :boolean,
      default: true,
      description: 'Whether or not to allow P.O. Box addresses for billing addresses'
  end

  fieldset 'Inventory', namespaced: false do
    field 'Low Inventory Threshold',
      type: :integer,
      default: 5,
      description: 'Minimum available quantity for a sku before inventory is considered low'
  end

  fieldset 'Content', namespaced: false do
    field 'Minimum Content Search Words',
      type: :integer,
      default: 5,
      description: 'Minimum number of words for content to be searchable on the storefront'

    field 'Placeholder Text',
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

    field 'Global Content Security Policy',
      type: :string,
      description: %(
        the security policy to enforce across the storefront via the
        "Content-Security-Policy" header. This will be combined with any
        page-specific policies defined in the content advanced settings.
      ).squish

    field 'Enforce Content Security Policy',
      type: :boolean,
      default: true,
      description: %(
        Determines whether content security policy is enforced or if it will
        only report violations. If true, policy is defined in the
        "Content-Security-Policy" header. Otherwise, any defined
        policies will be set in the "Content-Security-Policy-Report-Only" header.
        Reporting must be enabled below for disabled enforcement to do anything.
      ).squish

    field 'Report Content Security Violations',
      type: :boolean,
      default: false,
      description: %(
        Whether or not to add a report-uri to the "Content-Security-Policy"
        header to send reports back to the server when the policy is violated.
      ).squish
  end

  fieldset 'Search', namespaced: false do
    field 'Default Search Facet Result Sizes',
      type: :integer,
      default: 10,
      description: 'The number of filter results returned for each filter type.'

    field 'Search Facet Result Sizes',
      type: :hash,
      values_type: :integer,
      default: { color: 10, size: 10 },
      description: %(
        The number of filter results returned for any specified filter type. If no
        size is defined for a filter type, the default will be what is specified
        in the default config above.
      ).squish

    field 'Search Size Facet Sort',
      id: :search_facet_size_sort,
      type: :array,
      default: ['Extra Small', 'Small', 'Medium', 'Large', 'Extra Large'],
      description: %(
        The order the size facets will be displayed on storefront search results
        and category browse.
      ).squish

    field 'Search Sufficient Results',
      type: :integer,
      default: 2,
      description: %(
        The minimum number of search results required to consider the results
        sufficient. If a search result set is not sufficient, the search will
        try another pass with looser options to bring in more matches.
      ).squish

    field 'Search Suggestions',
      type: :integer,
      default: 5,
      description: 'How many search suggestions should be shown in the autocomplete searches.'
  end

  fieldset 'Communication', namespaced: false do
    field 'Show Privacy Popup', type: :boolean, default: false

    field 'Email From',
      type: :string,
      default: -> { "#{Workarea.config.site_name} <noreply@#{Workarea.config.host}>" },
      description: 'The email address used as the sender of system emails'

    field 'Email To',
      type: :string,
      default: -> { "#{Workarea.config.site_name} <customerservice@#{Workarea.config.host}>" },
      description: 'The email address that receives user generated emails, e.g. contact us inquiries'

    field 'Inquiry Subjects',
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

  fieldset 'Security', namespaced: false do
    field 'Safe IP Addresses',
      id: :safe_ip_addresses,
      type: :array,
      default: [],
      description: 'List of known IP addresses and/or IP addresses ranges a that should always have access to the site.'

    field 'Blocked IP Addresses',
      id: :blocked_ip_addresses,
      type: :array,
      default: [],
      description: 'List of known IP addresses and/or IP addresses ranges to block from site access.'
  end
end
