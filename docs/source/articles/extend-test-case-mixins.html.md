---
title: Extend Test Case Mixins
created_at: 2020/01/23
excerpt: How to change existing test case mixins and add your own test case mixins
---

# Extend Test Case Mixins

Workarea provides several [test case mixins](/articles/testing-concepts.html#test-case-mixins), which you can extend.

This document provides procedures for the following:

* [Change an Existing Test Case Mixin](#change-an-existing-test-case-mixin)
* [Add a New Test Case Mixin](#add-a-new-test-case-mixin)


## Change an Existing Test Case Mixin

You may want to change a method within an existing test case mixin so that the change is reflected in all tests (rather than decorating specific tests).

For example, say you want to change the email address filled in by [`Storefront::SystemTest#fill_in_email`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/testing/lib/workarea/storefront/system_test.rb#L90-L92) from `bcrouse-new-account@workarea.com` to `robert-clams@workarea.com`.

Create a new file in `/test/support/` and re-open the previously defined module and method, applying the email address change:

```
# <application_root>/test/support/storefront_system_test_extensions.rb

module Workarea
  module Storefront
    module SystemTest

      def fill_in_email
        fill_in 'email', match: :first, with: 'robert-clams@workarea.com'
      end
    end
  end
end
```

Then, require the module definition from your test helper:

(This step isn't required if you're developing a plugin, because the files in the `/test/support/` directory are required automatically in that case.)

```
# <application_root>/test/test_helper.rb

ENV['RAILS_ENV'] ||= 'test'

# ...

require 'support/storefront_system_test_extensions'
```

Your changes will now be reflected in all test cases that use this method.


## Add a New Test Case Mixin

To add a new test case mixin, e.g. to define your own test "macros", follow the steps above for changing a test case mixin.
However, define a new module instead of re-opening an existing module.

After requiring the module from your test helper, the new methods will be available to all test cases that include the module.
Follow the steps for changing a test case mixin, but define a new module and methods instead of re-opening an existing module and methods.
