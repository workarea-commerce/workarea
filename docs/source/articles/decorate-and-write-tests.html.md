---
title: Decorate & Write Tests
created_at: 2020/01/23
excerpt: How to decorate Workarea tests and write your own application tests
---

# Decorate & Write Tests

From your application, you can decorate the tests that ship with Workarea, and you can write your own application tests.
See [Testing Concepts, Tests & Decorators](/articles/testing-concepts.html#tests-amp-decorators) for more info, including an explanation of when to decorate vs when to write your own.

This doc explains how to [Decorate a Workarea Test Case](#decorate-a-workarea-test-case), as well as how to [skip a Workarea test](#skip-a-workarea-test) if you need to.

This doc also covers how to [Write an Application Test Case](#write-an-application-test-case), and when doing so, the following recipes may also be useful:

* [Change Configuration within a Test](#change-configuration-within-a-test)
* [Change Locale within a Test](#change-locale-within-a-test)
* [Change Time within a Test](#change-time-within-a-test)


## Decorate a Workarea Test Case

Before decorating a Workarea test case, review the advice in [Testing Concepts, Tests & Decorators](/articles/testing-concepts.html#tests-amp-decorators).

If you've determined a test case decorator is appropriate for your situation, [decorate](/articles/decoration.html) a [test case](/articles/testing-concepts.html#test-case-types-amp-mixins) much like you would for any other Ruby class, except the pathname of the decorator must match the pathname of the original file (except for the file extension).

For example, to decorate the class definition at:

```
workarea-core/test/models/workarea/payment/credit_card_integration_test.rb
```

Create the decorator file at:

```
<app_or_plugin_root>/test/models/workarea/payment/credit_card_integration_test.decorator
```

This parity is necessary for the decorator to be applied to the class when tests are run.

If you need to add new tests rather than fix existing tests, create a new test file for your tests instead of creating a decorator, e.g.:

```
<app_or_plugin_root>/test/models/workarea/payment/<project_name>_credit_card_integration_test.rb
```


### Skip a Workarea Test

One reason to decorate a test case is to skip one or more tests.
Your custom platform extensions may break some tests, and it may make more sense to skip those tests rather than get them passing.

For example, an address management integration may have moved the ability to manage addresses out of Workarea and into another system.
The tests for managing addresses will therefore fail, but it doesn't make sense to fix them.
Skip all tests within this test case instead:

```
# <application_root>/test/system/workarea/storefront/addresses_system_test.decorator

require 'test_helper'

module Workarea
  decorate Storefront::AddressesSystemTest do
    decorated { setup :skip }
  end
end
```

Another example is to skip specific tests within a test case while waiting for another feature to be implemented or for a platform bug to be fixed:

```
# <application_root>/test/system/workarea/storefront/addresses_system_test.decorator

require 'test_helper'

module Workarea
  decorate Storefront::AddressesSystemTest do
    def test_managing_addresses
      skip('defer until customer user management is implemented')
    end
  end
end
```

```
# <application_root>/test/models/workarea/payment/refund/credit_card_test.decorator

require 'test_helper'

module Workarea
  decorate Payment::Refund::CreditCardTest do
    def test_complete_refunds_on_the_credit_card_gateway
      skip('skip until gateway bug is resolved')
    end
  end
end
```


## Write an Application Test Case

Although you sometimes need to decorate Workarea tests, it's more common to write your own (application) tests.
( See [Testing Concepts, Tests & Decorators](/articles/testing-concepts.html#tests-amp-decorators). )

To create a test, create a new file to represent the test case.
Choose a pathname within `<application_root>/test/` based on Workarea conventions.
For examples, see:

* [`/test/` directory for Workarea Core](https://github.com/workarea-commerce/workarea/tree/master/core/test)
* [`/test/` directory for Workarea Storefront](https://github.com/workarea-commerce/workarea/tree/master/storefront/test)

Within the test file, first require the [test helper](/articles/testing-concepts.html#test-helper), and then define your test case class, inheriting from a Workarea [test case type](/articles/testing-concepts.html#test-case-types).
Mix in any additional [test case mixins](/articles/testing-concepts.html#test-case-mixins) you may need.

The following boilerplate may help:

```
# <application_root>/test/workers/workarea/import_inventory_test.rb

require 'test_helper'

module Workarea
  class ImportInventoryTest < TestCase

    def test_perform
      # ...
    end
  end
end
```

### Change Setup/Teardown Behavior

To change how tests are set up or torn down between each individual run, use the `setup` and `teardown` DSL methods:

```ruby
module Workarea
  class ImportInventoryTest < TestCase
    setup :setup_custom_logic
    teardown :teardown_custom_logic

    def test_perform
      # ...
    end

    def setup_custom_logic
      # do your custom setup logic here
    end

    def teardown_custom_logic
      # do your custom teardown logic here
    end
  end
end
```

Applications may also use the block style for this, but **plugins should not use this style** as it is impossible to decorate in an application:

```ruby
module Workarea
  class ImportInventoryTest < TestCase
    setup do
      # do your custom setup logic here
    end

    teardown do
      # do your custom teardown logic here
    end

    def test_perform
      # ...
    end
  end
end
```

As of Workarea 3.5.0, `Workarea::TestCase` will do a few cleanup tasks for you on teardown, so writing tests like this won't accidentally leak configuration and cause random test failures:

```ruby
module Workarea
  decorate UserTest do
    # When decorating tests with different setup code, make sure to enclose
    # your `setup` and `teardown` calls in a `decorated { }` block.
    decorated do
      setup :use_custom_authentication_gateway
    end

    def use_custom_authentication_gateway
      Workarea.config.gateways.authentication = 'MyCustomAuthGateway'
    end
  end
end
```

In order to take advantage of all this, however, it's best to use the `setup` and `teardown` DSL methods. This will run the setup/teardown code located in `Workarea::TestCase`, and prevent random tests from failing. **Do not** set up or teardown your tests by overriding the `#setup` and `#teardown` instance methods, as this will not use the logic in `Workarea::TestCase` and possibly cause some difficult-to-diagnose issues in your tests.

### Change Configuration within a Test

Since Workarea 3.5.0, the global configuration is reset before each test. You can therefore change the configuration within a test and have it affect only that test. Here is an example from Workarea Core:

```
module Workarea
  class UserTest < TestCase
    def test_admins_have_more_advanced_password_requirements
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
```

Prior to Workarea 3.5.0, you must wrap configuration changes in `Workarea.with_config` to ensure they reset after the test.
Here is the same example from above using `Workarea.with_config`:

```
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


### Change Locale within a Test

It's also possible to change the locale for the duration of a test, using the `I18n.with_locale` method.
This is the method used to change locale in `Workarea::I18nServerMiddleware`, but it's also useful within tests like so:

```
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

### Change Time within a Test

Since Workarea 3.0.0, use [ActiveSupport's time helper methods](https://api.rubyonrails.org/v5.2/classes/ActiveSupport/Testing/TimeHelpers.html) (e.g. `travel_to`) to change the time and date within tests.
Note that changes to the current time will not carry over to other tests&mdash;`Time.current` is reset to the actual current time of the machine after executing each test.
Here's an example using `travel_to` within a unit test to see how data is presented over time:

```
module Workarea
  module Insights
    class TopCategoriesTest < TestCase
      setup :add_data, :time_travel

      def add_data
        # ...
      end

      def time_travel
        travel_to Time.zone.local(2018, 11, 1)
      end

      def test_generate_monthly!
        # ...
      end

      # ...
    end
  end
end
```
