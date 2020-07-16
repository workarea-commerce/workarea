---
title: Change Product Placeholder Image
created_at: 2018/08/14
excerpt: Learn how to change the default placeholder image for catalog products.
---

# Change Product Placeholder Image

Products can be associated with images, but this is by no means required. In the event that a product has no images associated with it, a default placeholder image is rendered. This may not be suitable for your Workarea application's look-and-feel, and this article explains how to change that default image. Placeholder images can be configured either from a Workarea application, or from a plugin (such as a theme). Plugins and themes typically change the placeholder image when the existing one does not match the proper dimensions for a PDP image.

## Override the Image File

Save your new placeholder image file as `app/assets/images/workarea/core/product_placeholder.jpg`. This is, by default, the first file path that is looked up and cached into the database for use as a product image when no images have been uploaded for that product. File paths within the main Workarea component engines (Storefront, Admin, Core, etc.) are checked, as well as any plugins that you have installed. This gives plugins, especially themes, a chance to override the image as well. Workarea applications have the "final word", as always, and can override this path even if plugins have it overridden already.

To see the new placeholder image, you must first clear out the existing cached image. Run the following in `rails console` to do that:

```ruby
Workarea::Catalog::ProductPlaceholderImage.cached.destroy!
```

To generate a new placeholder image (and verify that your change succeeded), you can then run `rails console`:

```ruby
Workarea::Catalog::ProductPlaceholderImage.cached
```

If your new placeholder image was uploaded, the aformentioned method call will return a new record (as evidenced by a different `:_id` attribute), thus confirming that a new image has been uploaded. You can also visit a product detail page for a product that has no images and view the placeholder through the browser. Note: You may need to restart the application as `Workarea::Catalog::ProductPlaceholderImage.cached` is a class variable.

## Configure Placeholder Image Filename

Although this is not common, it is possible to change the filename of the placeholder image that Workarea looks up in the asset pipeline. To do this, configure the `product_placeholder_image_name` setting like so:

```ruby
# config/initializers/workarea.rb
Workarea.configure do |config|
  config.product_placeholder_image_name = 'no_product_image.jpg'
end
```

Your placeholder image will now be looked up at `app/assets/workarea/core/no_product_image.jpg`.
