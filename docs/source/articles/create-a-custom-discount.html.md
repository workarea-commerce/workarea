---
title: Create a Custom Discount
created_at: 2018/07/31
excerpt: The following example creates a "Buy Some Get Shipping" discount that provides a discount on a particular shipping method with the purchase of certain products or from certain categories.
---

# Create a Custom Discount

The following example creates a "Buy Some Get Shipping" discount that provides a discount on a particular shipping method with the purchase of certain products or from certain categories.

## Discount Generator

Version 2.1 introduced a discount generator, which will create the new discount boilerplate for you.

```bash
$ bin/rails g workarea:discount --help
Usage:
  rails generate workarea:discount NAME [options]

Options:
  [--skip-namespace], [--no-skip-namespace] # Skip namespace (affects only isolated applications)

Runtime options:
  -f, [--force] # Overwrite files that already exist
  -p, [--pretend], [--no-pretend] # Run but do not make any changes
  -q, [--quiet], [--no-quiet] # Suppress status output
  -s, [--skip], [--no-skip] # Skip files that already exist

Description:
    Creates a new custom pricing discount that can be applied to order
    totals, shipping totals, products, and other price paths.

    For more information on how to customize this generator, visit:

    http://guides.workarea.com/create-a-custom-discount.html

Example:
    rails generate workarea:discount FreeShipping

    creates:
        app/models/workarea/pricing/discount/free_shipping.rb
        app/view_models/workarea/admin/discounts/free_shipping_view_model.rb
        app/views/workarea/admin/pricing_discounts/properties/_free_shipping.html.haml
        app/views/workarea/admin/create_pricing_discounts/_free_shipping.html.haml
        test/models/workarea/pricing/discount/free_shipping_test.rb
        test/view_models/workarea/admin/discounts/free_shipping_view_model_test.rb
    modifies:
      config/initializers/workarea.rb
```

The generator creates/modifieds all the files necessary to create a new discount. Read on to learn more about those files.

## Creating the Model

Create a new discount model in your app for your discount.

your\_app/app/models/workarea/pricing/discount/buy\_some\_get\_shipping.rb:

```ruby
module Workarea
  module Pricing
    class Discount
      class BuySomeGetShipping < Discount
        include FlatOrPercentOff

        # If needed, you could include other condition types here to get
        # functionality related to those types
        #
        # include Conditions::OrderTotal
        # include Conditions::PromoCodes

        # Add fields specific to your discount type

        field :shipping_method_id, type: String
        field :purchase_quantity, type: Integer

        field :product_ids, type: Array, default: []
        list_field :product_ids

        field :category_ids, type: Array, default: []
        list_field :category_ids

        # Add validations to ensure the data needed for the discount is present

        validates :purchase_quantity, presence: true
        validates :shipping_method_id, presence: true
        validate :product_or_category_ids_present

        # Implement model_name so that Rails can generate routes, mappers, etc.

        def self.model_name
          Discount.model_name
        end

        # Implement apply to fulfill the Workarea::Pricing::Discount contract.
        # This method defines what is to be added to the order to reflect the use
        # of this discount.

        def apply(order)
          order.shipments.each do |shipment|
            next unless shipment_matches_shipping_method?(shipment)
            apply_to_shipment(shipment)
          end
        end

        # Set the level at which price changes apply (shipping, item, order, tax)

        self.price_level = 'shipping'

        # Qualifiers are run to determine whether an order meets the criteria needed
        # to apply this discount. This includes qualifiers from included conditions
        # as well as any defined within the discount itself.

        add_qualifier :matching_shipping_method?
        add_qualifier :product_or_category_quantity?

        def matching_shipping_method?(order)
          order.shipments.any? do |shipment|
            shipment_matches_shipping_method?(shipment)
          end
        end

        def product_or_category_quantity?(order)
          matching_items = order.items.select do |item|
            item.matches_categories?(category_ids) ||
              item.matches_products?(product_ids)
          end
          matching_items.sum(&:quantity) >= purchase_quantity
        end

        private

        def shipment_matches_shipping_method?(shipment)
          shipment.shipping_method.present? &&
            shipment.shipping_method.id.present? &&
            shipment.shipping_method.id.to_s == shipping_method_id
        end

        def apply_to_shipment(shipment)
          shipping_total = shipment.price_adjustments.adjusting('shipping').sum
          value = amount_calculator.calculate(shipping_total)
          return if value < 0

          shipment.adjust_pricing(adjustment_data(value, 1))
        end

        def product_or_category_ids_present
          if product_ids.blank? && category_ids.blank?
            errors.add(
              :base,
              'You need to specify products or categories'
            )
          end
        end
      end
    end
  end
end
```

## Creating the View Model

Each discount type is assumed to have a corresponding view model. The view model will be loaded dynamically in the Admin when a user chooses to create or edit a discount of this type. Use the view model to define methods that gather the data needed to render the discount options and conditions.

In this example, all that is needed is formatting a collection of shipping method options to select from when setting the discount rules.

your\_app/app/view\_models/workarea/admin/discounts/buy\_some\_get\_shipping\_view\_model.rb:

```ruby
module Workarea
  module Admin
    module Discounts
      class BuySomeGetShippingViewModel < DiscountViewModel
        include Products
        include Categories

        def shipping_method_options
          @shipping_method_options ||= Shipping::Method.all.map do |method|
                                          [method.name, method.id]
                                        end
        end
      end
    end
  end
end
```

## Creating the Discount Properties Partial

Create a partial matching the class name of your discount. This partial is loaded under the 'Discount Rules' section of the Admin edit form.

For this example, the partial includes the id of the shipping method to discount, the required purchase quantity, and the product or category ids that need to be included in the items in the cart for the discount to apply.

your\_app/app/views/workarea/admin/pricing\_discounts/properties/\_buy\_some\_get\_shipping.html.haml:

```ruby
%p.discount__node-group
  %span.discount__node Take
  %span.discount__node= select_tag 'discount[amount_type]', options_for_select(@discount.amount_type_options, @discount.amount_type), title: 'Type of Amount'
created_at: 2018/07/31
  %span.discount__node= text_field_tag 'discount[amount]', @discount.amount, class: 'text-box text-box--mini', title: 'Amount of Discount', placeholder: '10', required: true
created_at: 2018/07/31
  %span.discount__node off
  %span.discount__node= select_tag 'discount[shipping_method_id]', options_for_select(@discount.shipping_method_options, @discount.shipping_method_id), title: 'Shipping Method'
created_at: 2018/07/31
  %span.discount__node when
  %span.discount__node= number_field_tag 'discount[purchase_quantity]', @discount.purchase_quantity || 1, min: '1', class: 'text-box text-box--mini', title: 'Quantity to Qualify', required: true
created_at: 2018/07/31
  %span.discount__node of the following
  %span.discount__node= select_tag 'discount[product_ids]', options_from_collection_for_select(@discount.products, 'id', 'name', @discount.product_ids), multiple: true, data: { remote_select: { source: catalog_products_path(format: :json), options: { placeholder: 'Product A, Product B' } }.to_json }
  %span.discount__node or
  %span.discount__node= select_tag 'discount[category_ids]', options_from_collection_for_select(@discount.categories, 'id', 'name', @discount.category_ids), multiple: true, data: { remote_select: { source: catalog_categories_path(format: :json), options: { placeholder: 'Category A, Category B' } }.to_json }
  %span.discount__node is purchased.
```

## Adding the Discount to the Discount Types View

When an administrator chooses to create a new discount, they are next prompted to choose the discount type. You must override this view into your application and add to it your custom discount. The relevant parts of the file are shown below.

your\_app/app/views/workarea/admin/pricing\_discounts/select\_type.html.haml:

```ruby
/ ...
= form_tag new_pricing_discount_path, method: 'get', id: 'discount_form' do

  /...

  %tr
    %td
      %label
        = radio_button_tag 'type', 'buy_some_get_shipping'
        Buy Some Get Shipping
    %td 50% off ground shipping when any of these products are purchased

  .form-actions
    .action-group
      %p.action-group__item= link_to 'Cancel', :back, class: 'text-button text-button--muted'
      %p.action-group__item= button_tag 'Continue', value: 'continue', class: 'button'
```
