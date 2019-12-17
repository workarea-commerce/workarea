---
title: Add System Content
created_at: 2018/07/31
excerpt: In this guide, I outline the steps required to add administrable content to a system page in the Storefront. I use the example of adding content to the cart, as shown below.
---

# Add System Content

In this guide, I outline the steps required to add administrable content to a system page in the Storefront. I use the example of adding content to the cart, as shown below.

![Cart system content in the Storefront](/images/cart-system-content-in-storefront.png)

## Create System Content

Start by creating a content instance with one or more blocks within your seeds. I use the following decorator to add a _Cart_ content instance.

```
# app/seeds/workarea/system_content_seeds.decorator

module Workarea
  decorate SystemContentSeeds do
    def perform
      super
      add_cart
    end

    def add_cart
      styles = 'background: yellow; text-align: center; padding: 1em;'
      html = "<p style='#{styles}'>Cart System Content</p>"

      content = Content.for('Cart')
      content.blocks.create!(type: 'html', data: { html: html })
    end
  end
end
```

## Test Admin

You can search for this system page in the Admin.

![Searching for cart system content in the Admin](/images/searching-for-cart-system-content-in-admin.png)

And view the content to confirm your content and blocks exist.

![Cart system content in the Admin](/images/cart-system-content-in-admin.png)

## Extend or Create View Model

To display this content in the Storefront, find (or create) the view model used for the particular Storefront page. Include `Workarea::Storefront::DisplayContent` in the view model and then implement `content_lookup`, returning the `name` of the content to be displayed.

For my example, I decorate the cart view model, associating it with the _Cart_ content.

```
# app/view_models/workarea/storefront/cart_view_model.decorator

module Workarea
  module Storefront
    decorate CartViewModel do
      decorated do
        include DisplayContent
      end

      def content_lookup
        'Cart'
      end
    end
  end
end
```

## Render Blocks in Storefront

Now you can call `content_blocks` on the view model to retrieve the blocks to render in the Storefront. Override or append to the view to render the blocks.

The Storefront's cart view includes the following append point.

```
= append_partials('storefront.cart_additional_information', cart: @cart)
```

So I can append a partial here and access the cart view model using the local variable `cart` within my partial. I use the following partial.

```
/ app/views/workarea/storefront/carts/_content.html.haml

= render_content_blocks(cart.content_blocks)
```

And I use the following initializer to append the partial.

```
# config/initializers/appends.rb

Workarea.append_partials(
  'storefront.cart_additional_information',
  'workarea/storefront/carts/content'
)
```

## Test Storefront

You can now test the feature end-to-end in your browser to confirm it is working as expected.

![Cart system content in the Storefront](/images/cart-system-content-in-storefront.png)

To catch regressions, write a system test confirming the correct blocks are rendered in the Storefront. I use the following test.

```
# test/system/workarea/storefront/cart_system_test.decorator

module Workarea
  module Storefront
    decorate CartSystemTest do
      def test_cart_content
        styles = 'background: yellow; text-align: center; padding: 1em;'
        html = "<p style='#{styles}'>Cart System Content</p>"
        create_content(
          name: 'cart',
          blocks: [
            {
              type: 'html',
              data: { html: html }
            }
          ]
        )

        visit storefront.product_path(@product)
        select @product.skus.first, from: 'sku'
        click_button t('workarea.storefront.products.add_to_cart')
        click_link t('workarea.storefront.carts.view_cart')

        assert(page.has_content?('Cart System Content'))
      end
    end
  end
end
```

