---
title: Add, Remove, or Change a Product Template
created_at: 2019/03/14
excerpt: Product Templates are useful to change how the product is displayed on its detail page. This guide will show you how to manipulate these templates both within a plugin and in an application.
---

# Add, Remove, or Change a Product Template

Product Templates are useful for changing how products are displayed on their detail pages. They allow the same site to serve several "editions" of a product detail page, for clients with very diverse offerings of products. Workarea provides full control over how the product detail page is displayed, allowing developers to make both logical and cosmetic customizations to different classes of products. Product Templates can originate in the core Workarea platform, a Workarea plugin you install, or customized specifically for your application. This guide will show you how to manipulate those templates both within a plugin and in an application.

## Creating a Product Template

To create a new product template, you can run the `workarea:product_template` generator that comes bundled with Workarea. This generator is responsible for doing three things:

1. Add the template's **slug** (a human-readable unique identifier used to select the template) to `Workarea.config.product_templates`
2. Create the **partial template** from Workarea's generic template
3. Define a **view model** that inherits from `Storefront::ProductViewModel` for encapsulating view-level logic concerns. This step is optional, and the `Storefront::ProductViewModel` will be used if your template's view model is not defined.

To learn more about the various options of this generator, run the generator without arguments:

```
cd path/to/your_app
bin/rails g workarea:product_template
```

This should result in the following:

```
Usage:
  rails generate workarea:product_template NAME [options]

Options:
  [--skip-namespace], [--no-skip-namespace]    # Skip namespace (affects only isolated applications)
  [--skip-view-model], [--no-skip-view-model]  # Indicates when to generate skip-view-model

Runtime options:
  -f, [--force]                    # Overwrite files that already exist
  -p, [--pretend], [--no-pretend]  # Run but do not make any changes
  -q, [--quiet], [--no-quiet]      # Suppress status output
  -s, [--skip], [--no-skip]        # Skip files that already exist

Description:
  Boilerplate set up for a custom product template.

Example:
    rails generate workarea:product_template TemplateName

    modifies:
      config/initializers/workarea.rb
    creates:
      app/views/workarea/storefront/products/templates/_template_name.html.haml
      app/view_models/workarea/storefront/template_name_view_model.rb
```

You also have the option of implementing each step of this yourself. Below is an overview of each step in the creation process.

### Create Partial Template

The partial template you create must be placed in `app/views/workarea/storefront/products/templates`, and must be named matching the configuration. For instance, if your template's name is `your_template_name`, your partial filename would be `_your_template_name.html.haml`. The example below is the minimum viable implementation of a product detail template (the form that adds the SKU to the cart):

```haml
= form_tag cart_items_path, method: 'post' do
  = hidden_field_tag :product_id, product.id, id: dom_id(product, 'product_id')
  = hidden_field_tag :sku, product.sku_options.first.second
  = number_field_tag :quantity, 1, required: true, min: 1
  = button_tag t('workarea.storefront.products.add_to_cart'), value: 'add_to_cart'
```

The template includes a `product` local variable, passed in via the `storefront/products#show` template. This local is set to the `Workarea::Storefront::ProductViewModel` (or a child class of `ProductViewModel`, as explained below) representing the `Workarea::Catalog::Product` being rendered on the current page.

### Create View Model (Optional)

Often times, a different product template will require different presentation logic for how to display attributes/images/variants for the product. This can be done by defining a class in the `Workarea::Storefront::ProductTemplates` module, which inherits from `Workarea::Storefront::ProductViewModel`. When wrapping the `Workarea::Catalog::Product`, the system will use the name of the template to determine whether a view model is defined for this template, and wrap the `Workarea::Catalog::Product` accordingly. Otherwise, `Workarea::Storefront::ProductViewModel` will be used as the default product view model.

In `app/view_models/workarea/storefront/product_templates/your_template_view_model.rb`:

```ruby
module Workarea
  module Storefront
    module ProductTemplates
      class YourTemplateViewModel < ProductViewModel
        def your_special_logic
          # ...
        end
      end
    end
  end
end
```

### Add Configuration

In order to make the template usable, an identifier to it must be added to the `Workarea.config.product_templates` collection. In a plugin, this is typically a file like **config/initializers/configuration.rb**, but it can be named anything you want. In an application, this configuration typically lives in **config/initializers/workarea.rb**. The configuration for adding a product template is as follows:

```ruby
Workarea.configure do |config|
  config.product_templates << :your_template_name
end
```

## Remove a Product Template

To prevent products from taking on a given product template, you can remove the template from the `config.product_templates`. Prior to doing this, however, you might want to make sure that `Catalog::Product` records which already exist in the database do not have this product template set, otherwise an error will occur when someone tries to visit the product's detail page. Make sure products for your omitted template are set to something that will display on the PDP, like `generic`, using the following line of code in the `rails console`:

```ruby
Workarea::Catalog::Product.where(template: :omitted).update_all(template: :generic)
```

If you're in a Workarea application, you can use the following code in an initializer to omit a given product template from being usable:

```ruby
Workarea.configure do |config|
  config.product_templates.reject! { |template| template == :omitted }
end
```

## Changing a Product Template

Product templates from base or acquired through a plugin may still require some changes in order for products to display according to your specifications. To accomplish this, you can decorate the view model provided by the template or override its product template to accomplish your goals. Note that most templates, as well as the `workarea/storefront/products#show` view, include append points so you don't have to override the entire template, as full view overrides tend to cause problems when upgrading between minor versions of either a plugin or the core platform.

To add logic to a plugin's product template, for example `Swatches`, decorate its product template by running the generator:

```
./bin/rails generate workarea:decorator storefront/product_templates/swatches_view_model
```

Then, edit the generated `.decorator` file to add custom attributes to `#browse_link_options`:

```ruby
module Workarea
  decorate Storefront::ProductTemplates::SwatchesViewModel do
    def browse_link_options
      super.merge(foo: 'bar')
    end
  end
end
```

You can also override an entire product template with the `workarea:override` generator:

```
./bin/rails generate workarea:override views workarea/storefront/products/templates/_swatches
```
