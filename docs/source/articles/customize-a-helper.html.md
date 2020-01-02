---
title: Customize a Helper
created_at: 2019/03/14
excerpt: Workarea developers can use the following two-step procedure to add or change helper methods
---

Customize a Helper
======================================================================

[Rails helpers](https://api.rubyonrails.org/v6.0.0/classes/ActionView/Helpers.html) are modules that define methods for use in views and controllers (helper methods).
Occasionally, you may encounter the following use cases involving helper methods:

* From a plugin, you need to define a new helper method
* From a plugin or application, you need to re-define a helper method originally defined by Workarea

The Rails engine architecture does not provide an extension mechanism to enable these use cases.
However, Workarea developers can use the following two-step procedure to satisfy these requirements:

1. Define or re-define the helper method (depending on use case)
2. Add the helper module to the ancestors of either the Admin or Storefront application controller


1\. (Re)Define the Helper Method
----------------------------------------------------------------------

For a new helper method (from a plugin), define a new helper and method.
The following example defines a new helper method within the _Blogs_ plugin:

```ruby
# workarea-blog/app/helpers/workarea/storefront/blogs_helper.rb
module Workarea
  module Storefront
    module BlogsHelper
      def blog_posting_schema(entry)
        # implementation of new helper method
      end
    end
  end
end
```

To redefine an existing method (from an app or a plugin), define a method with the same name within a new module.
The following example re-defines a method from the _Blogs_ plugin from the _Boardgamez_ app:

```ruby
# boardgamez/app/helpers/workarea/storefront/blogs_helper.rb
module Workarea
  module Storefront
    module BoardgamezBlogsHelper
      def blog_posting_schema(entry)
        # re-implementation of helper method
      end
    end
  end
end
```


2\. Add the Helper to an Application Controller
----------------------------------------------------------------------

In both cases above, a new module is defined.
Add that module to the ancestors of either the Storefront or Admin application controller, depending on where you intend to use the helper method.
Do this using the `.helper` class method on the controller.

The following examples accomplish this in different ways, and both techniques are applicable to applications and plugins.

The first [decorates](/articles/decoration.html) the chosen controller:

```ruby
# workarea-blog/app/controllers/workarea/storefront/application_controller.decorator
module Workarea
  decorate Storefront::ApplicationController, with: :blog do
    decorated { helper Storefront::BlogsHelper }
  end
end
```

While the following example does the work in a configuration file:

```ruby
# boardgamez/config/application.rb
module Boardgamez
  class Application < Rails::Application
    config.to_prepare do
      Workarea::Storefront::ApplicationController.helper(
        Workarea::Storefront::BoardgamezBlogsHelper
      )
    end
  end
end
```
