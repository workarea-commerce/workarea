---
title: Testing Concepts
created_at: 2020/01/23
excerpt: Explanation of Workarea testing concepts, such as tests, decorators, runners, test cases, factories
---

# Testing Concepts

Workarea includes a test suite and tools for extending Workarea with your own tests.
This document explains the following concepts related to testing with the Workarea platform:

* Workarea's [tests and decorators](#tests-amp-decorators) and the [test runners](#test-runners) to run those tests
* The composition of Workarea test files, including the [test helper](#test-helper), [test case types](#test-case-types), [test case mixins](#test-case-mixins), and [test factories](#test-factories)
* The [headless Chrome](#headless-chrome) browser used to run certain tests


## Tests & Decorators

Workarea applications are Rails applications and therefore inherit the toolchain and patterns for [testing Rails apps](https://guides.rubyonrails.org/testing.html).
Refer to that document for Rails testing fundamentals, such as Minitest, test cases, and assertions.

However, a new Workarea application includes a broad feature set by default and therefore includes _tests_ for those features.
You can run the platform's own tests (referred to here as _Workarea tests_, to differentiate them from application tests) from your application.
( See [Run Tests](/articles/run-tests.html). )

You can also extend the platform's test suite by writing _decorators_ for existing tests and writing your own tests (referred to here as _application tests_ to differentiate them from Workarea tests).
( See [Decorate & Write Tests](/articles/decorate-and-write-tests.html). )

When you extend Workarea with your own customizations and functionality, you should extend the test suite as well.
As a general rule, you should __prefer writing new test cases over decorating existing test cases__.
New tests are easier to reason about and run.
( See [Run Tests](/articles/run-tests.html). )

However, in some situtations decorating an existing test case is necessary.
__Decorate a Workarea test case when your platform extensions have caused an existing test to fail__.
In this case, decorate the test case and fix or skip the failing tests.
( See [Decorate & Write Tests](/articles/decorate-and-write-tests.html). )
Furthermore, use a test case decorator to fix existing tests only.
If you need to write new tests, write them in their own (new) test case within your application.


## Test Runners

_Test runners_ are command line applications used to run tests (Workarea tests and application tests).

Rails provides [its own test runners](https://guides.rubyonrails.org/testing.html#the-rails-test-runner), and Workarea adds test runners that make it more convenient to run Workarea tests.
Knowing which test runner to use with which arguments can be confusing, so refer to the recipes in [Run Tests](/articles/run-tests.html).


## Test Helper

Every Rails test file begins by requiring the application _test helper_, a file located at `<application_root>/test/test_helper.rb`.
This file boots the application into an appropriate test environment and bootstraps it for testing.
This includes loading Rails' test help, `<railties>/lib/rails/test_help.rb`, and Workarea's test help, `<workarea-testing>/lib/workarea/test_help.rb`.

You'll see this file required in the boilerplate for [writing your own tests](/articles/decorate-and-write-tests.html).


## Test Case Types

Workarea defines its own _test case types_, and all Workarea test cases inherit from one of those types.

When [writing your own tests](/articles/decorate-and-write-tests.html), choose the appropriate test case type.
Refer to the following table for brief descriptions, and click through to the sources to see the full implementation of each type.

| Test Case Type | Description |
| --- | --- |
| [`Workarea::TestCase`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/test_case.rb) | Generic Workarea test case based on `ActiveSupport::TestCase` that supports test decorators and other Workarea extensions |
| [`Workarea::IntegrationTest`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/integration_test.rb) | Workarea integration test case based on `ActionDispatch::IntegrationTest` that provides decorator support, Workarea extensions, and additional instance methods, such as `set_current_user` |
| [`Workarea::SystemTest`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/system_test.rb) | Workarea system test case based on `ActionDispatch::SystemTestCase` that provides [Headless Chrome](#headless-chrome) setup and extensions to Capybara, such as `wait_for_xhr` |
| [`Workarea::ViewTest`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/view_test.rb) | Workarea view test case based on `ActionView::TestCase` |
| [`Workarea::MailerTest`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/mailer_test.rb) | Workarea mailer test case based on `ActionMailer::TestCase` |
| [`Workarea::GeneratorTest`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/generator_test.rb) | Workarea generator test case based on `Rails::Generators::TestCase` |


## Test Case Mixins

Many of the test case types described above include behavior that is defined in shared modules, referred to here as _test case mixins_.
You can mix these modules into any test case that doesn't already include them.

Therefore, when [writing your own tests](/articles/decorate-and-write-tests.html), after choosing the appropriate test case type, mix in any additional modules required for your specific test case.
Refer to the following table.

You can also extend these mixins to change their behavior as needed for your application.
( See [Extend Test Case Mixins](/articles/extend-test-case-mixins.html). )

| Test Case Mixin | Description |
| --- | --- |
| [`Workarea::TestCase::Workers`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/test_case.rb#L38-L60) | Provides setup and teardown to enable [workers](/articles/workers.html) to run (inline) |
| [`Workarea::TestCase::SearchIndexing`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/test_case.rb#L62-L73) | Provides setup for use of Elasticsearch indexes |
| [`Workarea::TestCase::Mail`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/test_case.rb#L75-L89) | Provides setup and teardown enabling sending of mail |
| [`Workarea::Admin::IntegrationTest`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/admin/integration_test.rb) | Ensures a default Admin user |
| [`Workarea::Storefront::IntegrationTest`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/storefront/integration_test.rb) | Provides test "macros" such as `complete_checkout` |
| [`Workarea::Storefront::SystemTest`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/storefront/system_test.rb) | Provides test "macros" such as `add_product_to_cart` |
| [`Workarea::BreakpointHelpers`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/storefront/breakpoint_helpers.rb) | Provides test "macros" such as `resize_window_to` |


## Test Factories

_Test factories_ are modules whose methods provide shortcuts for creating model instances.
Within your tests, you can call factory methods (e.g. `create_product`) to create model instances with default data appropriate for testing.

View the Base factories in [`<workarea-testing>/lib/workarea/testing/factories/`](https://github.com/workarea-commerce/workarea/tree/v3.5.3/testing/lib/workarea/testing/factories).

Many test case types include factories by default, and you can include factories in any test cases that don't by including [`Workarea::Factories`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/testing/factories.rb) within the test case definition.
All other factories "register" themselves with this "master" module, so that only this module must be included to provide access to all factory methods.

Within your application, you can configure the default data for each factory, and you can add your own factories for your own custom functionality.
( See [Configure & Add Test Factories](/articles/configure-and-add-test-factories.html). )


## Headless Chrome

Since Workarea 3.3.0, system tests use an instance of _headless Chrome_, driven by Selenium.
When running the tests locally, Workarea will use your standard Chrome installation.

To support all environments, you can configure the arguments passed to Chrome and Selenium.
( See [Configure Headless Chrome](/articles/configure-headless-chrome.html). )
