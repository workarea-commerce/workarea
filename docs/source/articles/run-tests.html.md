---
title: Run Tests
created_at: 2020/01/23
excerpt: How to run Workarea and application tests and decorators
---

# Run Tests

The platform ships with its own tests (Workarea tests), which you can run from your application.
When you run Workarea tests, any decorators you've written for those tests are applied.
You can also write your own tests (application tests) that further extend the platform.
( See also [Testing Concepts, Tests & Decorators](/articles/testing-concepts.html#tests-decorators). )

You run tests using one of many test runners.
( See [Testing Concepts, Test Runners](/articles/testing-concepts.html#test-runners). )

It can be confusing which to use for a given situation, so this document provides instructions to:

* [Run All Tests](#run-all-tests)
* [Run Workarea Tests](#run-workarea-tests)
* [Run Application Tests](#run-application-tests)

Once you are familiar with these procedures, you may only need a reminder of specific details.
In those situations you may want to refer to:

* [List Test Runners](#list-test-runners)
* [Display Rails Test Runner Help](#display-rails-test-runner-help)
* [Pass Arguments to Workarea Test Runners](#pass-arguments-to-workarea-test-runners)


## Run All Tests

Use the default Workarea test runner to run all tests: Workarea tests including your decorations of those tests, plus your own application tests.

```
bin/rails workarea:test
```

You can also run this command with arguments. See [Pass Arguments to Workarea Test Runners](#pass-arguments-to-workarea-test-runners).


## Run Workarea Tests

Additional Workarea test runners allow you to run tests by engine or run all plugin tests.

Run tests for a specific Workarea engine:

```
bin/rails workarea:test:<engine>
```

For example:

```
bin/rails workarea:test:core
```

```
bin/rails workarea:test:storefront
```

```
bin/rails workarea:test:gift_cards
```

Alternatively, run tests for all installed Workarea plugins (all engines except Core, Admin, Storefront):

```
bin/rails workarea:test:plugins
```

You can also run the above commands with arguments. See [Pass Arguments to Workarea Test Runners](#pass-arguments-to-workarea-test-runners).


### Run Specific Workarea Tests

To run individual/specific Workarea test cases and tests, use the Rails test runner.
Pass the pathnames of the test files you'd like to run as arguments to the test runner.
Use `bundle show` to easily find the installation location of each Workarea engine.

For example, run the `UserTest` test case from Workarea Core:

```
bin/rails test $(bundle show workarea-core)/test/models/workarea/user_test.rb
```

Use additional arguments to be more specific about which tests to run.
For example, use `-n` to run specific tests within a test case:

```
bin/rails test $(bundle show workarea-core)/test/models/workarea/user_test.rb -n test_new_example
```

To see all available arguments, see [Display Rails Test Runner Help](#display-rails-test-runner-help).


### Run Decorated Workarea Tests

You may want to run only the Workarea tests that you've decorated within your application.

Run _all_ decorated tests:

```
bin/rails workarea:test:decorated
```

( See also [Pass Arguments to Workarea Test Runners](#pass-arguments-to-workarea-test-runners). )

Run _specific_ decorated tests using the general procedure for [running specific Workarea tests](#run-specific-workarea-tests).
However, the pathnames you pass as arguments must be the original `*.rb` test files within the Workarea engine(s), not the `*.decorator` files within your application.
You must locate the pathnames to the original test files and pass those to the test runner to run the tests.


## Run Application Tests

Run your application tests like you would in any other Rails application (using the generic Rails test runner):

```
bin/rails test
```

Be aware, the default Rails test runner doesn't run system tests. To run system tests, use:

```
bin/rails test:system
```

To see all available arguments for these test runners, refer to [Display Rails Test Runner Help](#display-rails-test-runner-help).


### Run Specific Application Tests

To run specific application tests, pass the pathnames of the test files as arguments to the Rails test runner:

```
bin/rails test <paths>
```

For example:

```
bin/rails test test/models/article_test.rb
```

Additional arguments are also available for more control over which tests are run and how they are run.
See [Display Rails Test Runner Help](#display-rails-test-runner-help).


### Run `.decorator` Test Files

Developers often make the mistake of passing `*.decorator` file pathnames as test runner arguments.
Because [decorators](https://developer.workarea.com/articles/decoration.html#decorators) are extensions of existing classes, they are not complete test cases on their own and therefore can't be run as tests.
You must instead locate the pathnames of the original `*.rb` test files and pass those pathnames as arguments.

See [Run Decorated Workarea Tests](#run-decorated-workarea-tests).


## List Test Runners

Once you are familiar with the commands from the sections above, you may simply need a refesher of which test runners exist.

List all available test runners (Rails and Workarea):

```
bin/rails -T test
```

Output will differ from app to app, depending on which plugins are installed and other variables, so run this command within your application to see which test runners are available.


## Display Rails Test Runner Help

To see all the arguments accepted by the Rails test runner, view its inline help:

```
bin/rails test --help
```

The output lists all available arguments for the test runner, such as `-b` to print backtraces, `-v` for verbose output, and `-s` to run a specific seed.


## Pass Arguments to Workarea Test Runners

Workarea test runners accept the same arguments as the Rails test runners, but you must pass the arguments using the `TESTOPTS` environment variable.

Refer to [Display Rails Test Runner Help](#display-rails-test-runner-help) for all available arguments.
Pass arguments using the following boilerplate:

```
TESTOPTS='<arguments>' bin/rails workarea:test:<runner>
```

For example, run all Core tests with verbose output using a specific seed:

```
TESTOPTS='-v -s 51477' bin/rails workarea:test:core
```

Or, run all decorated tests with backtraces enabled for failed tests:

```
TESTOPTS='-b' bin/rails workarea:test:decorated
```
