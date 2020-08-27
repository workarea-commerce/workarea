config = Workarea::Configuration.config
config.testing_factory_defaults = ActiveSupport::Configurable::Configuration.new

defaults = config.testing_factory_defaults

# factories.rb
defaults.admin_visit = { name: 'Dashboard', path: '/' }
defaults.admin_bookmark = { name: 'Dashboard', path: '/' }
defaults.audit_log_entry = Proc.new { { modifier: create_user, audited: create_page } }
defaults.email_signup = Proc.new { { email: "email-signup-#{email_signup_count}@workarea.com" } }
defaults.help_article = { name: 'Product Editing', category: 'Howto' }
defaults.inventory = { id: 'SKU', policy: 'standard', available: 5 }
defaults.release = { name: 'Content Release' }
defaults.shipping = { order_id: '1234' }
defaults.shipping_sku = { id: 'SKU1', weight: 2.3 }
defaults.shipping_service = Proc.new { { name: "Test #{shipping_service_count}", rates: [{ price: 1.to_m }] } }
defaults.tax_category = Proc.new { { name: 'Clothing', code: tax_categories_count, rates: [{ percentage: 0.06, country: 'US', region: 'PA' }] } }

# factories/bulk_action.rb
defaults.bulk_action_product_edit = Proc.new { { query_id: Workarea::Search::AdminProducts.new.to_global_id } }
defaults.sequential_product_edit = { ids: %w(1 2 3) }

# factories/catalog.rb
defaults.category = { name: 'Test Category' }
defaults.product = { name: 'Test Product', details:  { 'Material' => 'Cotton', 'Style' => '12345' }, filters:  { 'Material' => 'Cotton', 'Style' => '12345' }, variants: [{ sku: 'SKU', regular: 5.00 }] }
defaults.create_product_placeholder_image = Proc.new { { image: product_image_file_path } }

# factories/comment.rb
defaults.comment = { author_id: '1234', body: 'foo bar' }

# factories/content.rb
defaults.asset = Proc.new { { name: 'Test Asset', tag_list: 'test', file: product_image_file_path } }
defaults.content = { name: 'Test content' }
defaults.page = { name: 'Test Page' }

# factories/data_file.rb
defaults.import = { model_type: 'Workarea::Catalog::Product' }
defaults.export = Proc.new { { model_type: 'Workarea::Catalog::Product', query_id: Workarea::Search::AdminProducts.new.to_global_id } }

# factories/fulfillment.rb
defaults.fulfillment_sku = { id: '2134', policy: 'shipping' }
defaults.fulfillment_token = { order_id: '1234', order_item_id: '3456', sku: '2134' }

# factories/insights.rb
defaults.insights_product_by_week = Proc.new { { product_id: "foo-#{product_by_week_count}", reporting_on: Time.current } }
defaults.insights_search_by_week = Proc.new { { query_string: "foo #{search_by_week_count}", searches: 1, reporting_on: Time.current } }
defaults.hot_products = Proc.new { { results: Array.new(3) { create_product_by_week.as_document } } }
defaults.cold_products = Proc.new { { results: Array.new(3) { create_product_by_week.as_document } } }
defaults.top_products = Proc.new { { results: Array.new(3) { create_product_by_week.as_document } } }
defaults.trending_products = Proc.new { { results: Array.new(3) { create_product_by_week.as_document } } }
defaults.top_discounts = Proc.new { { results: Array.new(3) { { discount_id: rand(1000) } } } }

# factories/navigation.rb
defaults.taxon = { name: 'Test Taxon' }
defaults.redirect = { path: '/faq', destination: '/pages/faq' }
defaults.menu = Proc.new { { taxon: create_taxon } }

# factories/order.rb
defaults.order = { email: 'bcrouse@workarea.com' }
defaults.placed_order = Proc.new { { id: '1234', email: 'bcrouse-new@workarea.com', placed_at: Time.current } }
defaults.fraudulent_order = Proc.new { { id: '1234', email: 'bcrouse-new@workarea.com', fraud_decision: { decision: :declined, message: "declined for fraud", response: "test response" } } }
defaults.shipping_address = { first_name: 'Ben', last_name: 'Crouse', street: '22 S. 3rd St.', street_2: 'Second Floor', city: 'Philadelphia', region: 'PA', postal_code: '19106', country: 'US' }
defaults.billing_address = { first_name: 'Ben', last_name: 'Crouse', street: '22 S. 3rd St.', street_2: 'Second Floor', city: 'Philadelphia', region: 'PA', postal_code: '19106', country: 'US' }
defaults.checkout_payment = { payment: 'new_card', credit_card: { number: '1', month: '1', year: Time.current.year + 1, cvv: '999' } }

# factories/payment.rb
defaults.payment = {}
defaults.payment_profile = { email: 'user@workarea.com', reference: '1243' }
defaults.saved_credit_card = Proc.new { { profile: Workarea::Payment::Profile.lookup(Workarea::PaymentReference.new(create_user)), first_name: 'Ben', last_name: 'Crouse', number: '1', month: 1, year: Time.current.year + 1, cvv: '999' } }
defaults.transaction = { action: 'authorize', amount: 5.to_m }

# factories/pricing.rb
defaults.buy_some_get_some_discount = { name: 'Test Discount', purchase_quantity: 1, apply_quantity: 1, percent_off: 100 }
defaults.category_discount = { name: 'Test Discount', amount_type: 'percent', amount: 50, category_ids: %w(1 2 3) }
defaults.code_list = { name: 'Test Code List', count: 2 }
defaults.free_gift_discount = { name: 'Test Discount', sku: 'SKU2' }
defaults.order_total_discount = { name: 'Order Total Discount', amount_type: 'percent', amount: 10 }
defaults.pricing_sku = { id: '2134' }
defaults.product_attribute_discount = { name: 'Test Discount', attribute_name: 'foo', attribute_value: 'bar', amount: 10 }
defaults.product_discount = { name: 'Test Discount', amount_type: 'percent', amount: 50, product_ids: ['PRODUCT1'] }
defaults.quantity_fixed_price_discount = { name: 'Quantity Price Discount', quantity: 3, price: 10, product_ids: ['PRODUCT'] }
defaults.shipping_discount = { name: 'Shipping Discount', amount: 0, shipping_service: 'Ground' }

# factories/recommendation.rb
defaults.recommendations = {}
defaults.user_activity = {}

# factories/search.rb
defaults.search_settings = { terms_facets: %w(Color Size), range_facets: { price: [{ to: 9.99 }, { from: 10, to: 19.99 }, { from: 20, to: 29.99 }, { from: 30, to: 39.99 }, { from: 40 }] } }
defaults.search_customization = { id: 'foo', query: 'Foo' }
defaults.admin_search = Proc.new { { results: [create_product, create_product, create_product], stats: {}, facets: { 'color' => { 'Red' => 2, 'Blue' => 1 } }, total: 3, page: 1, per_page: Workarea.config.per_page } }
defaults.product_browse_search_options = Proc.new { { products: [create_product, create_product, create_product], stats: {}, facets: { 'color' => { 'Red' => 2, 'Blue' => 1 } }, total: 3, page: 1, per_page: Workarea.config.per_page } }

# factories/segments.rb
defaults.segment = Proc.new { { name: 'Philadelphians', rules: [{ _type: 'Workarea::Segment::Rules::Geolocation', locations: %w(Philadelphia) }] } }

# factories/user.rb
defaults.user = Proc.new { { email: "user#{user_count}@workarea.com", password: 'W3bl1nc!', first_name: 'Ben', last_name: 'Crouse' } }

# factories/fraud_decision.rb
defaults.fraud_decision = { decision: :no_decision, message: 'Workarea default fraud check.' }
