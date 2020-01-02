---
title: View Models
created_at: 2019/03/14
excerpt: Workarea adds a view model layer to the standard controller/model/view/helper architecture provided by Rails. View models are concerned with database reads and logic related to those reads. Each view model instance "wraps" a model instance in order to
---

# View Models

Workarea adds a <dfn>view model</dfn> layer to the standard controller/model/view/helper architecture provided by Rails. View models are concerned with database reads and logic related to those reads. Each view model instance "wraps" a model instance in order to modify and augment it before presenting it within a particular UI, such as the Admin or Store Front.

Review the Storefront's categories controller, shown below in its entirety:

workarea-storefront/app/controllers/workarea/storefront/categories\_controller.rb:

```
module Workarea
  class Storefront::CategoriesController < Storefront::ApplicationController
    before_filter :cache_page

    def show
      model = Catalog::Category.find_by_slug(params[:id])
      @category = Storefront::CategoryViewModel.new(model, view_model_options)
    end
  end
end
```

The `show` method in this controller resembles the simple controller actions shown in beginning Rails tutorials. Controller actions in such tutorials use the params to get a model instance, store it in an instance variable that will be accessible in the view, and finish by implicitly rendering the view based on naming convention. The Workarea controller above is identical, with one exception. The model is "wrapped" with a view model, so `@category` refers to a view model instance rather than a model instance.

In the view, the view model instance provides the single interface for all the data and logic needed to present the model within this context. In the view excerpt below, you can see how the view model instance stored in `@category` provides the data and logic needed to present a category within the Store Front.

workarea-storefront/app/views/workarea/storefront/categories/show.html.haml:

```
/ ...

- cache @category.cache_key, expires_in: 1.hour do
  .view{ data: { analytics: category_view_analytics_data(@category).to_json } }

    %h1= @category.name

    - if @category.content_for(:area_1).present?
      = render_content_blocks(@category.content_for(:area_1))

    - unless @category.products.any?
      %p
        = t('workarea.storefront.products.none_found')
        - if @category.has_filters?
          = link_to t('workarea.storefront.products.reset_filters'), category_path(@category)
    / ...
```

## Philosophy

Before looking more closely at Workarea's view model implementation, I'd like to explain _why_ view models are used within the platform.

Within Workarea, view models are used to:

- read across bounded contexts,
- present a model within a UI,
- keep controllers lean,
- and provide a single interface to the view, reducing view logic.

Let's look at each of these in turn.

### Read Across Bounded Contexts

As explained in the [Domain Modeling](/articles/domain-modeling.html) guide, Workarea's models are organized into bounded contexts. The models within each bounded context address a particular problem set, and they do not cross their boundaries into other contexts.

For example, orders, users, payments, shipments, and fulfullments are sufficiently complicated that each is encapsulated into its own context. However, presenting an order to an end user requires reading from all of these contexts. **View models may read across bounded contexts**.

Take a look at the following excerpt from the Store Front's order view model:

workarea-storefront/app/view\_models/workarea/storefront/order\_view\_model.rb:

```
module Workarea
  module Storefront
    class OrderViewModel < ApplicationViewModel
      # ...

      delegate :tenders, :credit_card, :credit_card?,
        :store_credit?, :store_credit,
        to: :payment

      # ...

      delegate :shipping_method, to: :shipment, allow_nil: true

      def user
        @user ||= User.find(model.user_id) if model.user_id.present?
      end

      # ...

      private

      def payment
        @payment ||= Payment.find_or_initialize_by(id: number)
      end

      def shipment
        @shipment ||= Shipping::Shipment.find_by_number(number)
      end

      def fulfillment
        @fulfillment ||= Fulfillment.find_or_initialize_by(id: number)
      end

      # ...
    end
  end
end
```

The `user`, `payment`, `shipment`, and `fulfillment` methods clearly reach across domain boundaries to retrieve the necessary data from models within other contexts. You can also see other methods being delegated to the payment and the shipment. Data reads that cross domain boundaries in this fashion are unique to view models. In this way, **view models keep models decoupled**.

### Present a Model Within a UI

The view model above is responsible for presenting an order in the Store Front. In order to do this, the view model modifies and augments the state and behavior of the order model instance that it wraps. It does so to format the data for display within the Store Front.

For example, when presenting an order in the Store Front, the store credit amount must always be available as a non-`nil` value. The `store_credit_amount` method in the Store Front order view model takes care of this:

workarea-storefront/app/view\_models/workarea/storefront/order\_view\_model.rb:

```
module Workarea
  module Storefront
    class OrderViewModel < ApplicationViewModel
      # ...

      def store_credit_amount
        if store_credit.present?
          store_credit.amount
        else
          0.to_m
        end
      end

      # ...
    end
  end
end
```

Additionally, to display a full name, the Storefront _and_ Admin order view models both implement `full_name`:

workarea-admin/app/view\_models/workarea/admin/order\_view\_model.rb:

```
module Workarea
  module Admin
    class OrderViewModel < ApplicationViewModel
      # ...

      def full_name
        if billing_address.present?
          "#{billing_address.first_name} #{billing_address.last_name}"
        elsif shipping_address.present?
          "#{shipping_address.first_name} #{shipping_address.last_name}"
        end
      end

      # ...
    end
  end
end
```

The store credit and full name examples demonstrate methods that are concerned with the _presentation_ of data. **View models keep presentation logic out of models** , which are concerned with business logic rather than presentation.

### Keep Controllers Lean

As with presenting an order, presenting a product requires complex data reads across several contexts. Despite this, the Store Front's products controller is lean and easy to read:

workarea-storefront/app/controllers/workarea/storefront/products\_controller.rb:

```
module Workarea
  class Storefront::ProductsController < Storefront::ApplicationController
    before_filter :cache_page

    def show
      model = Catalog::Product.find_for_display!(params[:id])

      @product = Storefront::ProductViewModel.wrap(
        model,
        view_model_options
      )

      if request.xhr?
        render 'quickview'
      else
        render 'show'
      end
    end
  end
end
```

The read logic exists in the view model that wraps the model instance. **View models keep complicated read logic out of controllers**.

### Provide a Single Interface to the View

The products controller above contains a familiar pattern: find the relevant model instance, wrap it in a view model, assign it to an instance variable, then render the view. The `@product` instance variable encapsulates all the data and logic needed to present the model, all wrapped up nicely for the view.

By providing this single interface to the view, **view models reduce logic in views**. Keeping this logic out the view makes the logic easier to test and makes the view easier to read.

Having explained the philosophy of view models, let's move on to the most important implementation details, starting with initialization.

## Initialization/Wrapping

View model instances are initialized with a model instance and an optional hash of additional data. Each view model instance therefore "wraps" a model instance.

The Store Front pages controller, for example, includes an instance of `PageViewModel` wrapping an instance of `Page` and an instance of `ContentViewModel` wrapping an instance of `Content`.

workarea-storefront/app/controllers/workarea/storefront/pages\_controller.rb:

```
module Workarea
  class Storefront::PagesController < Storefront::ApplicationController
    before_filter :cache_page

    def show
      model = Content::Page.find_by_slug(params[:id])
      @page = Storefront::PageViewModel.new(model, view_model_options)
    end

    def home_page
      @page = Storefront::ContentViewModel.new(
        Content.for('home_page'),
        view_model_options
      )
    end

    def robots; end
    def accessibility; end
  end
end
```

In both cases, `view_model_options` is passed as the additional data hash. This method is mixed into all Store Front controllers and returns the params from the controller with the current user merged in.

### Model Types

The model being wrapped does not need to be a formal model (a Mongoid document), as demonstrated by the Admin searches controller:

workarea-admin/app/controllers/workarea/admin/searches\_controller.rb:

```
module Workarea
  module Admin
    class SearchesController < Admin::ApplicationController
      def show
        search = Search::Queries::AdminSearch.new(params)
        @search = SearchViewModel.new(search, params)
      end
    end
  end
end
```

In this example, the model is a search query object, and the params are passed as options.

### New vs Wrap

You may have noticed that a few of the examples above create a view model instance using the `wrap` method rather than `new`. In fact, **`wrap` is the preferred API to create a view model and should be used when creating new view model instances**. The next major version of Workarea will use `wrap` exclusively. Beyond improved semantics, `wrap` differs technically from `new` in that (1) it can create an array of view models from an enumerable and (2) it may return a specialized view model type.

### Wrapping an Enumerable

Passing an enumerable to `wrap` returns an array of view model instances. One such example is the `Storefront::DisplayContent` mixin:

workarea-storefront/app/view\_models/workarea/storefront/display\_content.rb:

```
module Workarea
  module Storefront
    module DisplayContent
      # ...

      def content_for(area)
        return [] unless content.present?
        blocks = content.blocks_for(area).select(&:active?)
        ContentBlockViewModel.wrap(blocks, options)
      end

      # ...
    end
  end
end
```

In this example, `blocks` is an array of `Content::Block` models. The `content_for` method returns an array of `ContentBlockViewModel` instances.

### Specialization

Unlike `new`, `wrap` may return a view model instance of a different type. This occurs when `wrap` identifies a specialized view model type that is more appropriate. For example, `ContentBlockViewModel.wrap` will try to find a view model matching the specific block type, and `ProductViewModel.wrap` will try to find a view model matching the product's template type.

While most view models inherit directly from `ApplicationViewModel`, "specialized" view models inherit from another view model that in turn inherits from `ApplicationViewModel`, giving them the properties of both view models.

The excerpt below shows the Store Front's content block view model. Notice how the `locals` method returns a hash created from the model's data:

workarea-storefront/app/view\_models/workarea/storefront/content\_block\_view\_model.rb:

```
module Workarea
  module Storefront
    class ContentBlockViewModel < ApplicationViewModel
      def self.wrap(model, options = {})
        # ...
      end

      def partial
        # ...
      end

      def locals
        model.data.try(:symbolize_keys) || {}
      end
    end
  end
end
```

The category summary view model "specializes" the content block view model, overwriting the `locals` method and adding additional methods needed to present a category summary content block within the Store Front:

workarea-storefront/app/view\_models/workarea/storefront/content\_blocks/category\_summary\_view\_model.rb:

```
module Workarea
  module Storefront
    module ContentBlocks
      class CategorySummaryViewModel < ContentBlockViewModel
        include ProductBrowsing

        def locals
          { category: category, products: products }
        end

        def category
          # ...
        end

        def products
          # ...
        end

        # ...
      end
    end
  end
end
```

### Wrap Example

In a newly created Workarea application, the home page content is composed of a variety of content blocks. The following example console session uses those blocks to demonstrate (1) wrapping an enumerable and (2) specialized view model types:

```
# Create an array of content block models
irb(main):001:0> home_page_blocks = Workarea::Content.for('home_page').blocks

# Wrap the array with ContentBlockViewModel
irb(main):002:0> view_models = Workarea::Storefront::ContentBlockViewModel.wrap(home_page_blocks)

# Confirm the return value is an array
irb(main):003:0> view_models.class
=> Array

# Print the type of each value in the array
# Some are ContentBlockViewModel
# Others are specialized types
irb(main):004:0> puts view_models.map(&:class)
Workarea::Storefront::ContentBlocks::HeroViewModel
Workarea::Storefront::ContentBlocks::BannerViewModel
Workarea::Storefront::ContentBlockViewModel
Workarea::Storefront::ContentBlocks::VideoViewModel
Workarea::Storefront::ContentBlocks::CategorySummaryViewModel
Workarea::Storefront::ContentBlockViewModel
Workarea::Storefront::ContentBlockViewModel
```

## Method Delegation

It's important to understand the method delegation that occurs within view models. View models may replace existing methods on the models they wrap, as well as add additional methods to those models. **View model instances delegate to the model for all methods they have not replaced or added**.

View models also provide a `model` method to access the wrapped model (and its methods) directly.

The following example console session demonstrates these concepts:

```
# Get a product model instance
irb(main):027:0> product = Workarea::Catalog::Product.first

# Create a view model instance from that model
irb(main):028:0> product_view_model = Workarea::Storefront::ProductViewModel.wrap(product)

# Access the original model's `images` method from the view model
# It returns an array
irb(main):031:0> product_view_model.model.images.class
=> Array

# Now call the same method directly on the view model instance
# The view model redefines that method, returning an `ImageCollection`
irb(main):030:0> product_view_model.images.class
=> Workarea::Storefront::ProductViewModel::ImageCollection

# Try to call `primary_image` on the original model
# The method doesn't exist
irb(main):034:0> product.primary_image
=> # NoMethodError: undefined method `primary_image' for #<Workarea::Catalog::Product:0x007f729c69a738>

# However, it does exist on the view model
# The view model has augmented the original model
irb(main):035:0> product_view_model.primary_image
=> #<Workarea::Catalog::ProductPlaceholderImage _id: 575b276d7765623aca000091, created_at: 2016-06-10 20:47:41 UTC, updated_at: 2016-06-10 20:47:41 UTC, image_uid: "2016/06/10/5eggsd9wcc_product_placeholder.jpg">

# The view model does not define a `categories` method
irb(main):037:0> product_view_model.methods.include?(:categories)
=> false

# However, calling the method on the view model returns a `Mongoid::Criteria`
# The view model delegates to the model, which defines this method
irb(main):038:0> product_view_model.categories
=> #<Mongoid::Criteria
  selector: {"deleted_at"=>nil, "product_ids"=>{"$in"=>["2F2DA168D8"]}}
  options: {}
  class: Workarea::Catalog::Category
  embedded: false>
```

## View Model Interface Diagram

The diagram that follows brings together many of the ideas from above:

* As needed, the view model initializes and queries a variety of objects to extend the interface of the original "wrapped" model
* The view model instance, which provides this extended interface, is bound to an instance variable
* The view "receives" this instance variable, from which it can query all data necessary to render the page or fragment

![View Model Interface](/images/view-model-interface.png)


## View Models vs Helpers

Rails includes the concept of <dfn>helpers</dfn>—classes whose methods are accessible in views—for the purpose of extracting view logic into testable classes. Helpers overlap conceptually with view models, and Workarea makes use of both object types. In general, Workarea applications prefer view models over helpers, largely because view models are easier to decorate and test. However, Workarea does make use of helper methods, primarily for the following use cases:

- Methods concerned with constructing HTML strings, such as a list of class values for an HTML element.
- Methods that return re-usable snippets of HTML, such as `datetime_picker_tag`.
- Methods that depend on or compose Rails' own view helpers, such as `render_content_block`, shown below.
- Methods that depend on arguments received from the view.

The following examples demonstrate the typical usage of helper methods within a Workarea application. Notice that each method is concerned with constructing an HTML string, and some methods depend on helpers provided by Rails.

workarea-storefront/app/helpers/workarea/storefront/content\_helper.rb:

```
module Workarea
  module Storefront
    module ContentHelper
      def render_content_block(block)
        render(partial: block.partial, locals: block.locals)
      end

      def render_content_blocks(blocks)
        blocks.inject('') do |result, block|
          result << render_content_block(block)
          result
        end.html_safe
      end

      def hero_link_class(hero_link_style)
        style = hero_link_style.parameterize

        if style == 'button'
          'button'
        else
          "hero-content-block __action-text hero-content-block__ action-text--#{style}"
        end
      end
    end
  end
end
```

workarea-storefront/app/helpers/workarea/storefront/credit\_cards\_helper.rb:

```
module Workarea
  module Storefront
    module CreditCardsHelper
      def credit_card_issuer_icon(issuer)
        content_tag(
          :span,
          issuer,
          class: credit_card_issuer_icon_class(issuer),
          title: issuer
created_at: 2019/03/14
        )
      end

      def credit_card_issuer_icon_class(issuer)
        if Workarea.config.credit_card_issuers.values.include?(issuer)
          "payment-icon payment-icon--#{issuer.parameterize}"
        else
          'payment-icon'
        end
      end
    end
  end
end
```
