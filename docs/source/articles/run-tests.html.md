---
title: Run Tests
created_at: 2020/01/13
excerpt: TODO
---

# Run Tests


## List Test Runners


## Run Application Tests

Note the most useful options for the Rails test runner.


## Run Application System Tests

The default Rails test runner doesn't run system tests, which trips people up.


## Run Workarea Tests (Rails Test Runner)

Use the Rails test runner to run individual/specific Workarea tests.


### Run a Decorated Test

Common mistake is to try to pass a decorator as an argument to the test runner.
Have to find the path to the original test.


### Re-Run a Failed Test

When tests fail, the output includes a command line to re-run each failed test (with the Rails test runner).


## Run Workarea Tests (Workarea Test Runners)

More convenient way to run groups of Workarea tests.
Useful for CI.

Same options as Rails test runner, but using ENV var.


### Run All Workarea Tests


### Run Decorated Workarea Tests


### Run Workarea Tests by Engine
