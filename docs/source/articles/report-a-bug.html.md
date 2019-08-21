---
title: Report a Bug
excerpt: Learn how to report issues you experience on the Workarea Commerce Platform.
created_at: 2019/06/05
---

# Report a Bug

Throughout your career as a Workarea developer, you may encounter bugs within the platform. Since Workarea's core is open-source, this means you are also given the means to contribute your own fixes to the platform and make every other developer's lives a bit easier (including your own). But sometimes you don't know how to best proceed with a given issue, or simply don't have time since you're busy launching a new site. If that's the case, you should **report the bug as an issue** to the Workarea project on GitHub.

## Reporting a New Issue to Workarea

Workarea uses [GitHub Issues][] to track bugs, feature requests, and improvements to the platform. In order to report issues to Workarea, you must sign up for a GitHub account.

### Before We Begin: Is This a Security Issue?

Please **do not** report security vulnerabilities using public GitHub issue reports (even if it's encrypted). The [security policy][] page describes the procedure to follow for reporting security issues.

### Step 1: Determine the Source of the Bug

Workarea is a highly customizable commerce platform. As a result, when issues arise it may be difficult to ascertain their source. For example, let's say you install a plugin and immediately receive an error upon starting your application. You might think this has to do with the installed plugin, but it could in fact be something that you need to configure in your app, or a code change made at some point that conflicts with the plugin's functionality. There's a few ways of determining whether platform code is the cause of your problem...

1. If an exception is thrown, make sure the backtrace points to lines of code in the platform. It's happening in the core platform if you see the error occurring on any file in **workarea-core**, **workarea-admin**, **workarea-testing**, or **workarea-storefront**. Otherwise, it's happening in a plugin (as long as the error doesn't stem from some decorator in your own application). Some plugins are open-source, and if they are, you can report the issue on their GitHub project. Otherwise, you'll need to [request support][] for our proprietary plugins.
2. If you're seeing a visual distortion of some kind, or you're _not_ seeing an appended file, make sure you've **restarted your server** and clobbered assets. A lot of perceived issues with the site only happen randomly in development, and therefore are difficult to track down. It may just be that your HTTP server is moving faster than your assets can recompile. Look at your `log/development.log` file to determine where the partial or template that the error is occurring on comes from. If it's rendered from a Workarea gem, then it's happening in the core components, but otherwise it's probably something that can be fixed at the application level.
3. For all other issues, make sure to add logging or use `require 'debug'` (or `binding.pry` if using Pry) to break into a code path and determine the state of things at that moment.

If you can prove, unequivocally, that platform code is the problem, it's a bug that you should report to the core team!

### Step 2: Create an Executable Test Case

If you can, the best way to ensure your issue gets solved as quickly as possible is to provide a **unit test** or **integration test** that illustrates the problem, and fails in your Workarea application. Although you may write a system test if you feel it can describe the problem well, these are not preferred...instead, include an animated screenshot that goes through the problem and shows the issue in an actual application.

Due to the nature of how Workarea is required in a Ruby on Rails application, a self-executing test case cannot be provided. Instead, create a new test file that just includes the test illustrating your problem, or include a snippet of another test file that you've made changes to.

Here's an example of a test case written around a bug:

```ruby
require 'test_helper'

module Workarea
  class PackagingTest < TestCase
    def test_accurate_total_value
      order = create_order
      product = create_product
      create_pricing_sku(id: 'SKU1', prices: [{ regular: 3.to_m }])
      create_pricing_sku(id: 'SKU2', prices: [{ regular: 2.5.to_m }])
      order.add_item(product_id: product.id, sku: 'SKU1', quantity: 1)
      order.add_item(product_id: product.id, sku: 'SKU2', quantity: 2)
      Pricing.perform(order)

      packaging = Packaging.new(order)
      assert_equal(8.to_m, packaging.total_value)

      create_order_total_discount(amount_type: :flat, amount: 1)
      Pricing.perform(order)

      packaging = Packaging.new(order)
      assert_equal(7.to_m, packaging.total_value)
    end
  end
end
```

The source of this can be pasted into a GitHub issue, which allows any Workarea contributor to copy the test into their own project and run it against a real Workarea app. This allows anyone to contribute the fix if they can figure it out!

### Step 3: Report the issue on GitHub

To report a bug to the Workarea project, create a new issue and give it a label of "bug". When creating a new issue, you'll be prompted by a template describing the various bits of information that the platform team needs in order to help triage and solve the problem you're reporting. Be sure to include as many relevant details as possible, and to scrub sensitive information from screenshots, code examples, and links to your project. When using Workarea Hosting, keep in mind that Workarea engineers (and anyone else in the world willing to contribute to the platform) cannot access the QA/Staging environments of your projects, so screenshots are absolutely necessary if you wish to demonstrate some kind of broken functionality on your project.

Keep in mind that you can use [Markdown][] to paste highlighted code, style your issue so it's easier to read, and add emphasis or inline example images.

[GitHub Issues]: https://github.com/workarea-commerce/workarea/issues
[security policy]: security-policy.html
[request support]: https://support.workarea.com
[Markdown]: http://daringfireball.net/projects/markdown/
