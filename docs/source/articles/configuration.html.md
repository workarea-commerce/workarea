---
title: Configuration
created_at: 2018/11/07
excerpt: Every Workarea application has Ruby and JavaScript configurations, which consist of customizable named values that provide designed extension points for the application and its installed plugins. Configuration, as an extension technique, is the proces
---

# Configuration

Every Workarea application has Ruby and JavaScript configurations, which consist of customizable named values that provide designed extension points for the application and its installed plugins. <dfn>Configuration</dfn>, as an extension technique, is the process of customizing configuration keys, known informally as <dfn>configs</dfn>, and their values.

Configuration allows _developers_ to customize an application beyond the capabilities of administrators. Because configs are _designed_ extension points, configuration is less expensive than other extension techniques, which require developers to extend the platform beyond its original design.

## Configuration Objects

Ruby and JavaScript configuration objects provide access to the current configuration of the application and allow developers to change the configuration.

### Ruby Configuration Object

Use `Workarea.config` to access the current Ruby configuration. The configuration object is hash-like (composed of keys and values) and also provides an accessor method for each key. This configuration object is actually a member of the Rails configuration, which is covered in more detail below.

The following example, which I ran in a Rails console, lists all the configs for my sample application.

```ruby
puts Workarea.config.keys.sort
# activity_excluded_types
# activity_size_on_dashboard
# address_attributes
# admin_break_points
# admin_max_most_visited
# admin_max_recently_visited
# admin_session_timeout
# admin_visit_excluded_paths
# allowed_login_attempts
# analytics_timezone
# asset_store
# asset_types
# blog_entries_on_index
# bulk_action_expiration
# cache_expirations
# cart_recommendations_count
# category_summary_product_count
# checkout_expiration
# checkout_steps
# clothing_swatch_size
# ... (truncated)
# user_activity_display_size
```

The config object contains _all_ platform configs, including those added as extensions by installed plugins.

The next example examines the values of several keys, demonstrating the varying complexity of configuration values.

```ruby
Workarea.config.blog_entries_on_index
# => 4

Workarea.config.max_admin_bookmarks
# => 10

Workarea.config.product_templates
# => [:test_product, :package, :family, :clothing]

Workarea.config.shipping_origin
# => {:country=>"US", :state=>"PA", :city=>"Philadelphia", :zip=>"19106"}

Workarea.config.pricing_calculators
# => #<Workarea::SwappableList:0x007f508b94d670 @source=["Workarea::Pricing::Calculators::ItemCalculator", "Workarea::Pricing::Calculators::CustomizationsCalculator", "Workarea::Pricing::Calculators::DiscountCalculator", "Workarea::Pricing::Calculators::TaxCalculator"]>

Workarea.config.elasticsearch_mappings.storefront
# => {:category=>{:properties=>{:query=>{:type=>"percolator"}}}, :storefront=>{:dynamic_templates=>[{:facets=>{:path_match=>"facets.*", :mapping=>{:type=>"keyword"}}}, {:numeric=>{:path_match=>"numeric.*", :mapping=>{:type=>"float"}}}, {:keywords=>{:path_match=>"keywords.*", :mapping=>{:type=>"keyword"}}}, {:sorts=>{:path_match=>"sorts.*", :mapping=>{:type=>"float"}}}, {:content=>{:path_match=>"content.*", :mapping=>{:type=>"text", :analyzer=>"text_analyzer"}}}, {:cache=>{:path_match=>"cache.*", :mapping=>{:index=>false}}}], :properties=>{:id=>{:type=>"keyword"}, :type=>{:type=>"keyword"}, :slug=>{:type=>"keyword"}, :suggestion_content=>{:type=>"string", :analyzer=>"text_analyzer"}, "facets.category_id"=>{:type=>"keyword"}, "facets.on_sale"=>{:type=>"keyword"}}}}
```

The Ruby configuration is also exposed through the _Settings_ dashboard in the Admin (_/admin/dashboards/settings_).

![Current configuration shown in Admin Settings](/images/current-configuration-shown-in-admin-settings.png)

### JavaScript Configuration Object

Use `WORKAREA.config` to access the current JavaScript configuration.

The following example, which I ran in a browser console, lists all the configs for my sample application in lexicographical order.

```js
console.log(Object.keys(WORKAREA.config).sort().join('\n'))
// categorizedAutocompleteFields
// contentBlocks
// contentEditorForms
// dashboardCharts
// date
// datepickerFields
// datetimepicker
// deletionForms
// dropzones
// formSubmittingControls
// forms
// helpLookupButtons
// imageFileExtensions
// messages
// productImagesSortable
// recommendationsSortables
// remoteSelects
// storefrontBreakPoints
// tooltipster
// validationErrorAnalyticsThrottle
// wysiwygs
```

The config object contains _all_ platform configs relevant to the current page, including those added as extensions by installed plugins. The configuration object is specific to the current UI (e.g. Admin, Storefront), since each UI has its own JavaScript manifests, which load different JavaScript config files.

### Accessing the Ruby Configuration in JavaScript

The Admin and Storefront configuration files, _workarea-admin/app/assets/javascripts/workarea/admin/config.js.erb_ and _workarea-storefront/app/assets/javascripts/workarea/storefront/config.js.erb_, are processed by ERB during compilation, providing access to the application's Ruby configuration.

The following example demonstrates how responsive break points sizes are read from a Ruby config in order to write them to a JavaScript config.

```js
<%# workarea-storefront/app/assets/javascripts/workarea/storefront/config.js.erb %>

<%# ... %>

WORKAREA.config.storefrontBreakPoints = {
    sizes: {
        <% Workarea.config.storefront_break_points.each do |name, size| %>
            '<%= name %>': <%= size %>,
        <% end %>
    },

    ie9Matches: [
        'small',
        'medium',
        'wide'
    ]
};

<%# ... %>
```

The same values are therefore accessible through Ruby and JavaScript.

```ruby
# Storefront break points in Ruby

Workarea.config.storefront_break_points
# => {:small=>320, :medium=>760, :wide=>960, :x_wide=>1160}
```

```js
// Storefront break points in JavaScript

console.log(JSON.stringify(WORKAREA.config.storefrontBreakPoints.sizes))
// => {"small":320,"medium":760,"wide":960,"x_wide":1160}
```

## Configuring an App in Ruby

To configure an app in Ruby, modify config values or add config keys from within an initializer or an environment-specific configuration file. It is also possible to modify the configuration temporarily, which is useful for testing (see below).

### Initializers & Environment Files

Write Workarea configuration code anywhere you would write Rails configuration code, most likely within an initializer or an environment-specific config file. The boilerplate for a Workarea application includes the following initializer.

```ruby
# config/initializers/workarea.rb

Workarea.configure do |config|
  # Basic site info
  config.site_name = 'Board Game Supercenter'
  config.host = 'board-game-supercenter.dev'
  config.email_to = 'customerservice@board-game-supercenter.dev'
  config.email_from = 'noreply@board-game-supercenter.dev'
end
```

The `Workarea.configure` method yields the Workarea configuration object to its block, providing a convenient interface for bulk configuration. Application developers typically write their configuration code within this block.

Rails also provides environment-specific files, such as _config/environments/development.rb_ and _config/environments/production.rb_. Write environment-specific configuration code within the appropriate environment file.

The plugins I looked at are less consistent than applications in where they write their configuration code. When writing configuration code within a plugin, I recommend using initializers that describe the type of configuration, such as _config/initializers/seeds.rb_ and _config/initializers/assets.rb_. Or, for small plugins, use a single generic initializer, such as _config/initializers/workarea.rb_.

Some existing plugins write configuration code in the _engine.rb_ file, within inline intializers. Avoid that technique in new plugins—such initializers run _after_ the application's initializers, making it more difficult for an application to override values specified in the plugin.

### Modifying Values

Within your initializer, modify existing configuration values as needed by assigning a new value or manipulating the existing value, as shown in the following examples.

```ruby
Workarea.config.blog_entries_on_index = 5

Workarea.config.seeds.push('Workarea::SharesSeeds')

Workarea.config.seeds << 'Workarea::ReviewSeeds'

Workarea.configure do |config|
  config.jump_to_navigation.merge!('Reviews' => :reviews_path)
end

Workarea.config.seeds.insert_after('Workarea::ProductsSeeds', 'Workarea::PackageProductSeeds')

Workarea.configure do |config|
  config.product_templates += %i(package family)
end

Workarea.config.product_templates << :clothing

Workarea.configure do |config|
  config.storefront_search_middleware.swap(
    'Workarea::Search::StorefrontSearch::Template',
    'Workarea::Search::StorefrontSearch::TemplateWithContent'
  )
end

Workarea.config.clothing_swatch_size ||= '44x'

Workarea.config.product_copy_default_attributes ||= {}
Workarea.config.product_copy_default_attributes.merge!(
  total_reviews: 0,
  average_rating: nil
)
```

### Adding Keys

A plugin may add new configuration keys to provide applications with extension points for the functionality provided by the plugin. To add a new key, simply assign a value to it.

```ruby
Workarea.config.and_now_for_something_completely_different = 'Anthologies are cool'
```

### Temporary Configuration (Testing)

In the context of tests, it can be useful to change a config temporarily, perhaps for the duration of a single test or assertion.
The procedure to do this is described in [Decorate & Write Tests, Change Configuration within a Test](/articles/decorate-and-write-tests.html#change-configuration-within-a-test).


## Configuring an App in JavaScript

To configure an app in JavaScript, modify config values or add config keys from within a JavaScript config file and [append](/articles/appending.html) the config file to an append point within the relevant manifest to include it on the page.

( Alternatively, if you are working in an application that is [overriding](/articles/overriding.html) the relevant manifest, you can require the config file within your manifest override. )

The following examples for the fictional store <cite>Board Game Supercenter</cite> demonstrate appending an application-specific JavaScript config file in the Storefront.

```js
// board_game_supercenter/app/assets/javascripts/workarea/storefront/board_game_supercenter/config.js

WORKAREA.config.messages.delay = 5000;
```


```js
# board_game_supercenter/config/initializers/appends.rb

Workarea.append_javascripts(
  'storefront.config',
  'workarea/storefront/board_game_supercenter/config'
)
```

Similarly, the following examples append an Admin config file for the fictional <cite>Workarea Loyalty</cite> plugin.

```js
// workarea-loyalty/app/assets/javascripts/workarea/admin/loyalty/config.js

WORKAREA.config.loyaltyBadges = {
    events: ['hover']
}
```


```ruby
# workarea-loyalty/config/initializers/appends.rb

Workarea.append_javascripts(
  'admin.config',
  'workarea/admin/loyalty/config'
)
```

If you need access to the Ruby config object within your JavaScript config file, use a file ending in _.js.erb_ instead. See example above.

## Rails Configuration

You should also be familiar with [configuring your Rails application](http://guides.rubyonrails.org/configuring.html), since Workarea depends on several Rails configuration values.

Use `Rails.application.config` or `Rails.configuration` to access the Rails configuration object. The Ruby configuration for Workarea is actually a member of the Rails configuration.

```ruby
Workarea.config == Rails.application.config.workarea
# => true

Workarea.config == Rails.configuration.workarea
# => true
```

However, Workarea makes use of additional Rails configs that live outside the Workarea-specific configuration. Two important examples are the application time zone and locales, each covered below.

### Configuring the Application Time Zone

[Since Workarea 3.2.0](/release-notes/workarea-3-2-0.html#uses-rails-time-zone-to-display-all-dates-times), you must configure a time zone for the admin side of your Workarea application. Set `config.time_zone` in your Rails general configuration in `config/application.rb`.

```ruby
# config/application.rb

module YourApp
  class Application < Rails::Application
    # ...
    config.time_zone = 'Eastern Time (US & Canada)'
    # ...
  end
end
```

Rails provides a command to list the time zones it recognizes, which is demonstrated in the following shell session:

```bash
$ bin/rails -T time
rails time:zones[country_or_offset] # List all time zones, list by two-letter country code (`rails time:zones[US]`), or list by UTC offset (`rails time:zones[-8]`)
$ bin/rails time:zones

* UTC -11:00 *
American Samoa
International Date Line West
Midway Island

… more …

* UTC +13:00 *
Nuku'alofa
Samoa
Tokelau Is.

$ bin/rails time:zones[US]

* UTC -10:00 *
America/Adak
Hawaii

… more …

* UTC -05:00 *
America/Detroit
America/Indiana/Marengo
America/Indiana/Petersburg
America/Indiana/Vevay
America/Indiana/Vincennes
America/Indiana/Winamac
America/Kentucky/Louisville
America/Kentucky/Monticello
Eastern Time (US & Canada)
Indiana (East)

$ bin/rails time:zones[-5]

* UTC -05:00 *
Bogota
Eastern Time (US & Canada)
Indiana (East)
Lima
Quito

$
```

### Configuring Locales

Other important Rails configurations are the _available locales_, _default locale_, and _locale fallbacks_. All of Workarea's user interfaces are internationalized and therefore depend on these values.

Review the [Configure Locales](/articles/configure-locales.html) guide for coverage of this topic.
