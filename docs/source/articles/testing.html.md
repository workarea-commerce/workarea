---
title: Testing
excerpt: Workarea applications include an automated test suite. Tests are written using Minitest and follow the conventions for testing Rails applications, with some extensions. I don't cover Minitest and Rails testing in this guide since those topics are cove
---

# Testing

Workarea applications include an automated test suite. Tests are written using [Minitest](http://www.rubydoc.info/gems/minitest/5.9.1 "Minitest 5.9.1 API documentation") and follow the conventions for [testing Rails applications](http://guides.rubyonrails.org/v5.0/testing.html "A Guide to Testing Rails Applications (v5.0)"), with some extensions. I don't cover Minitest and Rails testing in this guide since those topics are covered extensively elsewhere. Instead, I focus on Workarea APIs, extensions, and conventions used to test Workarea applications and plugins.

As of version 3.2, the Workarea platform test suite is composed of tests written for Minitest and [Teaspoon](https://github.com/jejacks0n/teaspoon). In this guide I will focus on Minitest tests, because you can run and extend those tests from within your application (or plugin). <sup><a href="#notes" id="note-1-context">[1]</a></sup>

As you develop your application—by installing plugins, extending the platform's functionality, and adding functionality of your own—you will inevitably break existing functionality and introduce new functionality that may be broken or become broken over time. You should therefore run and maintain the platform test suite as you develop.

## Running Tests

Workarea applications include multiple test runners: the standard Rails test runner for running tests unique to the application, and several Workarea test runners to run the Workarea test suite (including your application's extensions to that suite). For the greatest test coverage, you need to use the Rails test runner **and** a Workarea test runner.

### Listing Test Runners

Test runners are rake tasks. The following example lists the test runners available to a sample Workarea application.

```bash
$ bin/rails -T test
rails test # Runs all tests in test folder except system ones
rails test:db # Run tests quickly, but also reset db
rails test:system # Run system tests only
rails workarea:test # Run workarea tests (with decorators)
rails workarea:test:app # Run all app-specific tests
rails workarea:test:admin # Run workarea admin tests (with decorators)
rails workarea:test:blog # Run workarea blog tests (with decorators)
rails workarea:test:browseoption # Run workarea browseoption tests (with decorators)
rails workarea:test:clothing # Run workarea clothing tests (with decorators)
rails workarea:test:contentsearch # Run workarea contentsearch tests (with decorators)
rails workarea:test:core # Run workarea/core tests (with decorators)
rails workarea:test:decorated # Run decorated tests
rails workarea:test:packageproducts # Run workarea packageproducts tests (with decorators)
rails workarea:test:reviews # Run workarea reviews tests (with decorators)
rails workarea:test:share # Run workarea share tests (with decorators)
rails workarea:test:storefront # Run workarea storefront tests (with decorators)
```

### Rails Test Runner

Test files in your application are a combination of tests and decorators. The tests are testing functionality unique to your application, while the decorators are testing your extensions to the Workarea platform.

Use the Rails test runner to run the tests unique to your **application**. You can also use the Rails test runner to run the platform's tests, but you need to provide the paths to those test files as arguments. It is therefore more convenient to use the Workarea test runners for that purpose.

```bash
$ bin/rails test --help
minitest options:
    -h, --help Display this help.
    -s, --seed SEED Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose Verbose. Show progress processing files.
    -n, --name PATTERN Filter run on /regexp/ or string.
        --exclude PATTERN Exclude /regexp/ or string from run.

Known extensions: rails, minitest_reporter, workarea, pride

Usage: bin/rails test [options] [files or directories]
You can run a single test by appending a line number to a filename:

    bin/rails test test/models/user_test.rb:27

You can run multiple files and directories at the same time:

    bin/rails test test/controllers test/integration/login_test.rb

By default test failures and errors are reported inline during a run.

Rails options:
    -e, --environment ENV Run tests in the ENV environment
    -b, --backtrace Show the complete backtrace
    -d, --defer-output Output test failures and errors after the test run
    -f, --fail-fast Abort test run on first failure or error
    -c, --[no-]color Enable color in the output
```

If you do not specify the optional _[files or directories]_ argument (see _usage_, above), the test runner uses a default pattern to choose which test files to run. This pattern excludes pathnames matching _test/system/\*\*/\*_. To include system tests, you must explicitly specifiy a pattern. The following example runs all tests within the application's _test_ directory (note the quotes which are required to pass the pattern itself as an argument).

```bash
$ bin/rails test 'test/**/*_test.rb'
```


#### Running Decorated Tests in Isolation

To run a test that you've decorated (e.g., a `.decorator` file in the `test/` directory), you must run the original `.rb` file that the test originated from. Your decorations will apply at runtime, much like how decoration works in the application code.

For example, given this decorator in **test/models/workarea/user_test.decorator**:

```ruby
module Workarea
  decorate UserTest do
    def test_new_example
      assert create_user.persisted?
    end
  end
end
```

Run the following command to run all `UserTest` examples in isolation:

```bash
$ bin/rails test $(bundle show workarea-core)/test/models/workarea/user_test.rb
```

You can also opt to run a single test in isolation, using the `-n` parameter:

```bash
$ bin/rails test $(bundle show workarea-core)/test/models/workarea/user_test.rb -n test_new_example
```

### Workarea Test Runners

Use the Workarea test runners to run **Workarea platform tests, including your application's extensions to those tests** (your test decorators). Choose the test runner that represents the tests you want to run: all tests, the tests from a particular engine, or only the tests your application is decorating (_workarea:test:decorated_).

The Workarea test runners will honor the same options and arguments as the Rails test runner, but you must pass them by setting the `TESTOPTS` shell variable rather than including them as options and arguments in the command line. The example below runs all platform tests with the _verbose_ and _seed_ options.

```bash
$ TESTOPTS='-v -s 51477' bin/rails workarea:test:decorated
```


### Re-Running Failures

When a test fails, the test runner provides an example command line you can use to re-run only the failed test. You should be aware of the following details regarding the example command line.

First, the example command line **always uses the Rails test runner** , even if the Workarea test runner was used to produce the failure. This is not a problem, but beware of which test runner you are using since you have to pass options and arguments differently depending on the runner.

Second, if the failing test is defined in a decorator, the example command line to re-run the test provides the path to the **original test case file** instead of the path to the decorator file. **Do not pass decorator paths as test runner arguments** —Minitest cannot load decorator files.

The following example shows a test failure from a decorator. Notice how the command line to re-run the test provides the path to the original test case file.

```bash
$ bin/rails workarea:test:decorated
Run options: --seed 34356

# Running:

..F

Failure:
Workarea::ApplicationDocumentTest#test_cleaning_array_values [/.../test/models/workarea/application_document_test.decorator:6]:
Expected false to be truthy.

From decorator: test/workers/workarea/mark_discounts_as_redeemed_test.decorator:5
bin/rails test /.../ruby/2.4.0/gems/workarea-core-3.0.10/test/models/workarea/application_document_test.rb

Finished in 0.157878s, 31.6699 runs/s, 31.6699 assertions/s.

4 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```


## Writing Tests

You can extend platform tests by decorating test case classes the same way you decorate other platform classes. To test functionality that isn't already covered by the platform's test suite, write new tests within your application.

### Writing Test Decorators

To [decorate](decoration.html) a test case, create a _.decorator_ file within your application with the same base name and path as the test case file in Workarea. Require the application test helper at the top of your decorator, and use the `decorate` method to decorate the test case class.

The following annotated examples show the `BulkIndexProductsTest` test case from Core, and a decorator for that test case from the [Workarea Browse Option](https://github.com/workarea-commerce/workarea-browse-option) plugin. Decorating tests works the same way in plugins as it does in applications. <sup><a href="#notes" id="note-2-context">[2]</a></sup>

**Notice the uniformity of the filesystem paths and the Ruby namespaces (the module nesting) between both files. For a test decorator to run properly, the filesystem paths and Ruby namespaces of both files must be aligned.**

```ruby
# original test case from workarea-core
# workarea-core/test/workers/workarea/bulk_index_products_test.rb

require 'test_helper'

module Workarea
  class BulkIndexProductsTest < Workarea::TestCase

    def test_perform
      Workarea::Search::Storefront.reset_indexes!

      Sidekiq::Callbacks.disable(IndexProduct) do
        products = Array.new(2) { create_product }

        assert_equal(0, Search::Storefront.count)
        BulkIndexProducts.new.perform(products.map(&:id))
        assert_equal(2, Search::Storefront.count)
      end
    end
  end
end
```

```ruby
# decorator from the workarea-browse_option plugin
# workarea-browse_option/test/workers/workarea/bulk_index_products_test.decorator

require 'test_helper'

module Workarea
  decorate BulkIndexProductsTest, with: :browse_option do

    # Replaces the only existing test within the test case
    def test_perform
      Workarea::Search::Storefront.reset_indexes!

      Sidekiq::Callbacks.disable(IndexProduct) do
        products = Array.new(2) { create_product }

        assert_equal(0, Search::Storefront.count)
        BulkIndexProducts.new.perform(products.map(&:id))
        assert_equal(2, Search::Storefront.count)

        products.first.update_attributes!(
          browse_option: 'color',
          variants: [
            { sku: 'SKU1', details: { color: ['Red'] } },
            { sku: 'SKU2', details: { color: ['Blue'] } }
          ]
        )

        assert_equal(2, Search::Storefront.count)
        BulkIndexProducts.new.perform(products.map(&:id))
        assert_equal(3, Search::Storefront.count)
      end
    end

    # Adds an additional test to the test case
    def test_escaping_product_ids
      Workarea::Search::Storefront.reset_indexes!

      foo_bar = create_product(id: 'FOO BAR')
      IndexProduct.perform(create_product(id: 'FOO'))
      IndexProduct.perform(create_product(id: 'BAR'))
      IndexProduct.perform(foo_bar)

      IndexProduct.clear(foo_bar)
      assert_equal(Search::Storefront.count, 2)
    end
  end
end
```

Within a test case decorator, you can extend every method in the test case and its ancestor chain, including setup/teardown methods, shared behaviors, factories, and other test helpers.

When you're ready to run a test you've decorated, you must provide the path to the original test case file, not your decorator file. See re-running failures above.

### Skipping Tests & Resolving Conflicts

As an application developer, you have final say over your test suite. Base platform and plugin test suites are written in isolation from each other, so when these tests are combined in a production application, some undesirable behavior may result. Plugins may provide overlapping or even conflicting functionality, which may cause tests that would otherwise pass to fail when run from your application. When this occurs, you will need to decorate the problematic tests to fix them.

Where appropriate, use the Minitest methods `skip` and `pass` to skip over or automatically pass particular tests. Feel empowered to do this for all tests that create problems for your application, whether temporarily or permanently. The following examples demonstrate some uses for skipping tests in a sample application.

```ruby
# board-game-supercenter/test/system/workarea/storefront/users/hearts_system_test.decorator

require 'test_helper'

module Workarea
  decorate Storefront::Users::HeartsSystemTest do
    # skip all tests in this test case
    decorated { setup :skip }
  end
end

# board-game-supercenter/test/system/workarea/admin/inventory_skus_system_test.decorator

require 'test_helper'

module Workarea
  decorate Admin::InventorySkusSystemTest do
    def test_editing_a_non_existent_sku
      skip('removed this feature')
    end
  end
end

# board-game-supercenter/test/system/workarea/admin/publish_authorization_system_test.decorator

require 'test_helper'

module Workarea
  decorate Admin::PublishAuthorizationSystemTest do
    def test_user_cannot_select_publish_now_in_workflows
      skip('defer until custom permission is implemented')
    end

    def test_user_cannot_submit_form_without_selecting_a_release
      skip('defer until custom permission is implemented')
    end
  end
end

# board-game-supercenter/test/documentation/workarea/api/storefront/checkouts_documentation_test.decorator

require 'test_helper'

module Workarea
  decorate Api::Storefront::CheckoutsDocumentationTest do
    def test_and_document_complete
      skip('remove until gift card upgrade')
    end
    def test_and_document_update
      skip('remove until gift card upgrade')
    end
    def test_and_document_reset
      skip('remove until gift card upgrade')
    end
    def test_and_document_show
      skip('remove until gift card upgrade')
    end
  end
end

# board-game-supercenter/test/models/workarea/payment/refund/credit_card_test.decorator

require 'test_helper'

module Workarea
  decorate Payment::Refund::CreditCardTest do
    def test_complete_refunds_on_the_credit_card_gateway
      skip('skip until gateway bug is resolved')
    end
  end
end
```

### Writing New Tests

Write new test cases to cover functionality not covered by platform tests, such as new features unique to your application.

When writing new tests, follow Workarea conventions (such as file names/paths and method names). The following examples show the boilerplate for a new [worker](workers.html) and its associated test case.

```ruby
# app/workers/workarea/import_inventory.rb

module Workarea
  class ImportInventory
    include Sidekiq::Worker

    def perform(*)
      # ...
    end
  end
end
```

```ruby
# test/workers/workarea/import_inventory_test.rb

require 'test_helper'

module Workarea
  class ImportInventoryTest < TestCase

    def test_perform
      # ...
    end
  end
end
```

In the example above, I require the application test helper, which bootstraps the test run with test setup and configuration from Rails and Workarea. Then I define a new test case class which inherits from `Workarea::TestCase`. Workarea provides a variety of test case classes from which your test cases can inherit. These are covered below.

When you're ready to run your tests, use the Rails test runner.

### Testing Configuration and Locales

Workarea and its plugins include a plethora of configuration options that define the behavior of its components. To sufficiently test this behavior, helpers are made available in your tests to help simulate different configuration scenarios for your application.

#### Temporarily Changing Global Configuration

To ensure that global configuration changes affect your code in expected ways, you can apply different configuration settings temporarily and run tests as if they are part of the global configuration. For example, here's a unit test from core that uses `Workarea.with_config` to ensure that admins are not affected by a change in `config.password_strength`:

```ruby
module Workarea
  class UserTest < TestCase
    def test_admins_have_more_advanced_password_requirements
      Workarea.with_config do |config|
        config.password_strength = :weak

        user = User.new(admin: false, password: 'password').tap(&:valid?)
        assert(user.errors[:password].blank?)

        user = User.new(admin: true, password: 'password').tap(&:valid?)
        assert(user.errors[:password].present?)

        user = User.new(admin: true, password: 'xykrDQXT]9Ai7XEXfe').tap(&:valid?)
        assert(user.errors[:password].blank?)
      end
    end
  end
end
```

#### Temporarily Changing Locale

It's also possible to change the locale for the duration of a test, using the `I18n.with_locale` method. This is the method used to change locale in `Workarea::I18nServerMiddleware`, but it's also useful within tests like so:

```ruby
module Workarea
  decorate UserTest do
    def test_title
      user = create_user

      I18n.with_locale :en do
        assert_equal 'Mister', user.title
      end

      I18n.with_locale :es do
        assert_equal 'Señor', user.title
      end
    end
  end
end
```

#### Time Manipulation

In previous versions of Workarea, the [Timecop](https://github.com/travisjeffery/timecop) gem was used to simulate running code at different points in time. Since Workarea 3.0.0, [ActiveSupport's Time Helpers](https://api.rubyonrails.org/v5.2/classes/ActiveSupport/Testing/TimeHelpers.html) methods (like `travel_to`) are used for changing the current time and date. Note that changes to the current time will *not* carry over to other tests, `Time.current` is reset to the actual current time of the machine after executing each test. Here's an example using `travel_to` within a unit test to see how data is presented over time:

```ruby
module Workarea
  module Analytics
    class DailyDataTest < TestCase
      def test_days_ago_index
        travel_to '2017/2/19'.in_time_zone(Workarea.config.analytics_timezone)
        assert_equal(6, DailyData.days_ago_index(1))
        assert_equal(5, DailyData.days_ago_index(2))

        travel_to '2017/2/20'.in_time_zone(Workarea.config.analytics_timezone)
        assert_equal(0, DailyData.days_ago_index(1))
        assert_equal(6, DailyData.days_ago_index(2))
      end
    end
  end
end
```


### Conditionally Defining Tests

As a plugin author, you can't control the environment in which your plugins' tests are run. It is therefore useful to define some tests only when certain conditions are met, such as another particular plugin being installed or optional code being present in the environment. The following examples demonstrate the concept of conditionally defining tests.

The following examples from Browse Option, Clothing, and Gift Cards demonstrate conditionally defining tests when another plugin is installed.

```ruby
# workarea-browse_option-1.2.1/test/integration/workarea/api/storefront/browse_option_product_integration_test.rb

require 'test_helper'

module Workarea
  module Api
    module Storefront
      class BrowseOptionProductIntegrationTest < Workarea::IntegrationTest
        if Plugin.installed?('Workarea::Api::Storefront')
          setup :product, :category, :index_product

          def product
            # ...
          end

          def category
            # ...
          end

          def index_product
            # ...
          end

          def test_category_show
            # ...
          end

          def test_product_show
            # ...
          end
        end
      end
    end
  end
end
```

```ruby
# workarea-clothing-2.1.1/test/integration/workarea/api/storefront/product_swatches_integration_test.rb

require 'test_helper'

module Workarea
  module Api
    module Storefront
      class ProductSwatchesIntegrationTest < Workarea::IntegrationTest
        if Plugin.installed?('Workarea::Api::Storefront')
          setup :set_product

          def set_product
            # ...
          end

          def test_shows_products
            # ...
          end
        end
      end
    end
  end
end
```

```ruby
# workarea-gift_cards-3.2.0/test/integration/workarea/api/storefront/balance_integration_test.rb

require 'test_helper'

module Workarea
  if Plugin.installed?(:api)
    module Api
      module Storefront
        class BalanceIntegrationTest < Workarea::IntegrationTest
          def test_balance_lookup
            # ...
          end
        end
      end
    end
  end
end
```

The following examples from Address Verification wrap test definitions in two other types of conditionals. The first, `Workarea::TestCase.running_in_gem?` is true only when the test case is run from the engine's embedded "dummy" app. This allows defining tests that are useful to the plugin maintainers but may be problematic to include in the test suites of applications that install the plugin.

The other, `Workarea.const_defined?` tests the environment for the presence of a particular constant before defining tests. Address Verification supports multiple address verification gateways (and therefore provides tests for multiple gateways), but only one gateway will be installed in a production app. The conditional ensures tests for only the installed gateway are run.

```ruby
# workarea-address_verification-2.0.2/test/lib/workarea/address_verification/ups_gateway_test.rb

require 'test_helper'

if Workarea::TestCase.running_in_gem? ||
   Workarea.const_defined?('AddressVerification::UpsGateway')

  require 'workarea/address_verification/ups_gateway'

  module Workarea
    module AddressVerification
      class UpsGatewayTest < TestCase
        def test_verify
          # ...
        end
      end
    end
  end
end

# workarea-address_verification-2.0.2/test/lib/workarea/address_verification/melissa_data_gateway_test.rb

require 'test_helper'

if Workarea::TestCase.running_in_gem? ||
   Workarea.const_defined?('AddressVerification::MelissaDataGateway')

  require 'workarea/address_verification/melissa_data_gateway'

  module Workarea
    module AddressVerification
      class MelissaDataGatewayTest < TestCase
        def test_verify
          # ...
        end
      end
    end
  end
end
```

## Test Case Types

All Workarea test cases inherit from one of the test case types below. The test case types generally differ in the size and scope of the Ruby API available within the test case, and the amount and type of setup and teardown that's done before/after each test in the test case.

For example, `Workarea::SystemTest` provides a staggering 584 instance methods and starts up a headless browser to interact with the running application before each test. This provides greater test fidelity and flexibility than other test types, but slower performance. Meanwhile, `Workarea::GeneratorTest` provides a smaller Ruby API specialized for testing generators (scripts) and does not perform any setup.

I summarize each of the test case types below. **All** of the test types below extend `Workarea::TestCase::Decoration`, which allows applications and plugins to decorate the tests within that test case (and test cases that inherit from it).

### Generic Tests

Generic test cases inherit from `Workarea::TestCase`.

Among the ancestors of `Workarea::TestCase` are `ActiveSupport::TestCase`, `Minitest::Test`, `Minitest::Assertions`, `ActiveSupport::Testing::Assertions`, and `ActiveSupport::Testing::TimeHelpers`. The class's instance methods include `running_in_gem?`, which is also available as the class method `Workarea::TestCase.running_in_gem?`.

### Integration Tests

Test cases inheriting from `Workarea::IntegrationTest` are testing how various parts of the platform and/or application are interacting.

`Workarea::IntegrationTest` inherits directly from `ActionDispatch::IntegrationTest`. Beginning with Workarea 3.1.0, `Workarea::IntegrationTest` includes `Workarea::IntegrationTest::Configuration`, a module used to share behavior with system tests. The class's instance methods include `set_current_user`.

### System Tests

Test cases inheriting from `Workarea::SystemTest` use a headless browser to interact with the application's UI the same way a user does. Workarea 3.2.0 and below used PhantomJS as a headless browser for running system tests, but Workarea 3.3.0 uses the Chrome webdriver for Selenium ("headless" Chrome) by default, which does not include a browser cache. Workarea 3.3.0 still depends on Poltergeist (the Capybara driver for PhantomJS) for upgrading applications that may still depend on facilities provided by PhantomJS, but all newly-written tests should execute under the Headless Chrome driver.

The ancestors of `Workarea::SystemTest` include `ActionDispatch::SystemTestCase` (since Workarea 3.1.0), `Workarea::IntegrationTest::Configuration` (since Workarea 3.1.0), and `Capybara::DSL`. Prior to Workarea 3.1.0, `Workarea::SystemTest` inherited directly from `Workarea::IntegrationTest`. Workarea 3.1.0 depends on Rails 5.1, which adds `ActionDispatch::SystemTestCase`, so `Workarea::SystemTest` inherits from that class instead. The instance methods for `SystemTest` include `t`, `clear_driver_cache`, and `wait_for_xhr`.

Workarea also extends the [Capybara DSL](https://github.com/teamcapybara/capybara#the-dsl) with the `#has_ordered_text?` method, available on element objects as well as generically in test case. All methods that manipulate the DOM will also call `#wait_for_xhr` before returning back to the callee, ensuring Ajax requests have finished before proceeding.

### View Tests

Test cases inheriting from `Workarea::ViewTest` provide the necessary API to test view helpers.

`Workarea::ViewTest` inherits directly from `ActionView::TestCase`. The class's instance methods include all of Rails' view helpers.

### Generator Tests

Test cases inheriting from `Workarea::GeneratorTest` provide an API suitable for testing the Rails generators included with Workarea.

`Workarea::GeneratorTest` inherits directly from `Rails::Generators::TestCase`.

## Test Help

Every test case file begins by requiring your application test helper, _test/test\_helper.rb_. This file sets up the environment for testing, as follows:

1. Boots your application in the _test_ Rails environment
2. Loads Rails' test help, _railties/lib/rails/test\_help.rb_, which bootstraps Rails testing
3. Loads Workarea's test help, _workarea-testing/lib/workarea/test\_help.rb_, which bootstraps Workarea testing

The Workarea test help file loads a large Ruby API into memory, including the Workarea test cases from which your own test cases inherit. However, it also includes many other modules that provide additional setup/teardown and instance methods to use within your tests. Many of the platform's test cases mix in these modules as needed, and they are available to mix into your own test cases as well.

### Additional Setup/Teardown

The following modules provide additional test setup and/or teardown.

- `Workarea::TestCase::Workers`
  - Setup and teardown for [workers](workers.html)
  - Included in `Workarea::TestCase`, `Workarea::IntegrationTest`, and `Workarea::SystemTest` by default
- `Workarea::TestCase::SearchIndexing`
  - Setup for Elasticsearch indexes
  - Included in `Workarea::IntegrationTest` and `Workarea::SystemTest` by default
- `Workarea::Storefront::CatalogCustomizationTestClass`
  - Setup and teardown for catalog customization tests

### Tests for Shared Behavior

The following modules provide tests for shared behavior. When included in a test case, each module provides the tests indicated below.

- `Workarea::DiscountConditionTests::OrderTotal`
  - `test_order_total?`
  - `test_order_total_qualifies?`

- `Workarea::DiscountConditionTests::PromoCodes`
  - `test_promo_codes_qualify?`

- `Workarea::DiscountConditionTests::ItemQuantity`
  - `test_item_quantity?`
  - `test_items_qualify?`

- `Workarea::Storefront::PaginationViewModelTest`
  - `test_total_pages`
  - `test_first_page`
  - `test_last_page`
  - `test_next_page`
  - `test_prev_page`

- `Workarea::Storefront::ProductBrowsingViewModelTest`
  - `test_has_filters`
  - `test_facets`

### Test Helpers

The following modules provide additional instance methods that are useful in certain test situations and are usually referred to as test _helpers_ or _macros_. I've listed the helper methods for each available module below.

- `Workarea::Admin::IntegrationTest`
  - `admin_user` (Also sets `current_user` to this user as additional test setup)
- `Workarea::Storefront::IntegrationTest`
  - `complete_checkout`
  - `product`
- `Workarea::Storefront::SystemTest`
  - `add_product_to_cart`
  - `add_user_data`
  - `create_supporting_data`
  - `fill_in_billing_address`
  - `fill_in_credit_card`
  - `fill_in_email`
  - `fill_in_new_card_cvv`
  - `fill_in_shipping_address`
  - `select_shipping_service`
  - `setup_checkout_specs`
  - `start_guest_checkout`
  - `start_user_checkout`
- `Workarea::BreakpointHelpers`
  - `resize_window_to`

### Factories

_Factories_ are specialized test helpers that provide shortcuts for creating model instances. A factory method, such as `create_product`, can generally be called without arguments and creates a model instance using default data appropriate for testing.

Core factories are organized into files under _workarea-testing/lib/workarea/testing/factories/_. However, test cases that use factories mix in only `Workarea::Factories`. Including this module automatically includes all factory methods from all factory modules in Core and in all installed plugins.

The following test case types include factories by default.

- `Workarea::TestCase`
- `Workarea::IntegrationTest`
- `Workarea::SystemTest`
- `Workarea::ViewTest`

Including factories in a test case adds the following instance methods.

- `complete_checkout`
- `create_admin_bookmark`
- `create_admin_search`
- `create_admin_visit`
- `create_analytics_category_revenue`
- `create_analytics_discount_revenue`
- `create_analytics_filter`
- `create_analytics_navigation`
- `create_analytics_product`
- `create_analytics_product_revenue`
- `create_analytics_search`
- `create_asset`
- `create_bulk_action_product_edit`
- `create_buy_some_get_some_discount`
- `create_category`
- `create_category_browse_search`
- `create_category_discount`
- `create_code_list`
- `create_comment`
- `create_content`
- `create_email_signup`
- `create_export`
- `create_free_gift_discount`
- `create_help_article`
- `create_inventory`
- `create_import`
- `create_menu`
- `create_order`
- `create_order_total_discount`
- `create_page`
- `create_payment`
- `create_payment_profile`
- `create_placed_order`
- `create_pricing_sku`
- `create_product`
- `create_product_attribute_discount`
- `create_product_browse_search_options`
- `create_product_discount`
- `create_product_placeholder_image`
- `create_product_search`
- `create_quantity_fixed_price_discount`
- `create_recommendations`
- `create_redirect`
- `create_release`
- `create_saved_credit_card`
- `create_search_customization`
- `create_search_settings`
- `create_shipping`
- `create_shipping_discount`
- `create_shipping_service`
- `create_shipping_sku`
- `create_tax_category`
- `create_taxon`
- `create_user`
- `create_user_activity`

### Factory Configuration

Each factory method uses a configurable set of default values to generate a model instance when no custom values are provided. Default values are either a `Hash` or a `Proc` instance that returns a hash consisting of values that are determined at the time the method is called. A `Proc` is executed within the context of the `Workarea::Factories` module, allowing access to other factory methods to generate default values like associations or ensure a unique name is generated for each model instance generated by the factory method.

```ruby
Workarea.configure do |config|
  config.testing_factory_defaults.inventory =
    { id: 'SKU', policy: 'standard', available: 5 }

  config.testing_factory_defaults.audit_log_entry = Proc.new do
    { modifier: create_user, audited: create_page }
  end

  config.testing_factory_defaults.shipping_service = Proc.new do
    { name: "Test #{shipping_service_count}", rates: [{ price: 1.to_m }] }
  end
end
```

These default values can be customized for your application to modify the default model instances across the entire test suite without having to decorate each individual test. A common use case would be adding a default value for a field that your application requires but is not required out of the base Workarea model (e.g. phone number on shipping address).

You can customize these values in your application's `test_helper.rb`

```ruby
# Modify the configuration for factory default values
# test/test_helper.rb

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__ )
require 'rails/test_help'
require 'workarea/test_help'

Workarea.configure do |config|
  config.testing_factory_defaults.shipping_address[:phone_number] = '2155551212'
end
```

Additionally, you can customize the factory default values for the duration of a single test by utilizing the `Workarea.with_config` method to temporarily modify the configuration values.

```ruby
# test/system/storefront/categories_system_test.decorator

require 'test_helper'

module Workarea
  decorate Storefront::CategoriesSystemTest do

    # Decorate setup method
    def set_products
      Workarea.with_config do |config|
        config.testing_factory_defaults.product.merge!(
          # add customized defaults
        )

        super
      end
    end
  end
end
```

## Adding & Extending Test Help

As you develop your application, you may have the need to extend the various test help modules described above, or add your own. The steps to to this are as follows.

1. Create new modules
2. Require them in your application test helper
3. Mix them into your test cases as needed

Plugins create these modules under _test/support/_ , or _test/factories/_ in the case of factories, since files at these paths are required automatically by the host application. Applications should follow these conventions, but files at these paths within the application are not required automatically, so you must require each module in your test helper.

In addition to creating your own modules, re-open existing modules as needed to extend them. The following examples show two new files: one file to add a **new factory module** , and another to **re-open an existing test helper**. Both files are **required in the application's test helper**.

```ruby
# Add factory methods to use within tests of your custom functionality
# test/factories/entertainment.rb

module Workarea
  module Factories
    module Entertainment

      # Register your factory to include it with the other factories
      Factories.add(self)

      # Add as many factory methods as you need
      def create_calendar(overrides = {})
        attributes = { name: 'Test Calendar' }.merge(overrides)
        Workarea::Entertainment::Calendar.create!(attributes)
      end

      # ...
    end
  end
end
```

```ruby
# Add a test help file which re-opens an existing test helper
# test/support/storefront_system_test_extensions.rb

# Re-open the module
module Workarea
  module Storefront
    module SystemTest

      # Redefine or extend the module's instance methods as needed
      def fill_in_email
        fill_in 'email', match: :first, with: 'bcrouse-new-account@workarea.com'
      end
    end
  end
end
```

```ruby
# Require your new modules in your test helper
# test/test_helper.rb

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__ )
require 'rails/test_help'
require 'workarea/test_help'

# Require additional test help
require 'factories/entertainment'
require 'support/storefront_system_test_extensions'
```

You can also extend the various test help methods for the duration of a single test case by decorating the test case (or defining your own test case) and extending the relevant instance methods there. The example below shows a test decorator extending a factory method.

```ruby
# test/workers/workarea/bulk_index_products_test.decorator

require 'test_helper'

module Workarea
  decorate BulkIndexProductsTest do

    # Decorate a factory method
    def create_product
      # ...
    end

    # Decorate a test
    def test_perform
      # Use the redefined create_product method within the test
    end
  end
end
```

## Notes

[1] If you're migrating to Workarea 3 from an earlier version, review the [<cite>Testing</cite> section of the 3.0 release notes](workarea-3-0-0.html#testing) for a summary of changes.

[2] An exception to this is the `with` option for `decorate`. By convention, plugins must include this option while applications can omit it.
