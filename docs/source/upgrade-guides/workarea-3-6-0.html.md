---
title: Workarea 3.6.0 Upgrade Guide
excerpt: Changes requiring attention when upgrading to Workarea 3.6.0
---

# Workarea 3.6.0 Upgrade Guide

---

__Upgrading to Workarea 3.6?__ &mdash; Check out the [Workarea 3.6 Release Notes](/release-notes/workarea-3-6-0.html)

---

Before upgrading to Workarea 3.6.0, review the following changes.

## Upgrade to Rails 6 and other dependencies

### What's Changing?

Workarea is a technology forward platform, and we want to be as up-to-date as possible with our dependencies. As such, v3.6 updates Workarea's Rails dependency to Rails 6. You can read [the Rails release notes](https://edgeguides.rubyonrails.org/6_0_release_notes.html) if you're curious about the changes.

Many other dependencies, like Mongoid and Sidekiq, have been updated as well.


### What Do You Need to Do?

Similar to a Workarea upgrade in general, here are additional steps to take to upgrade your app to Rails 6. There aren't many big API changes that affect Workarea, so this probably won't impact your code too much.

1. Update `workarea` in your Gemfile, and adjust other gems/dependencies as needed to get Bundler resolving (as usual).
2. Run `rails app:update`, this is the script Rails provides to make updates to your app.
3. Check `config/initializers/new_framework_defaults_6_0.rb` and comment/uncomment as needed
4. Get tests passing


## Localized Image Option Fields

### What's Changing?

To enable matching images based on localized variant details, the `option` field on the `Catalog::ProductImage` needs to be localized. Because this data is serialized into Elasticsearch, a simple Mongo migration doesn't suffice to update the way the data is stored.

### What Do You Need to Do?

The default value for `Workarea.config.localized_image_options` will be `true`. If you're upgrading and don't want to migrate your Mongo data and reindex Elasticsearch (unlikely), you'll want to set this to `false` in an initializer to preserve the former behavior.

```ruby
Workarea.configure do |config|
  config.localized_image_options = false
end
```

## libvips for Image Processing

### What's Changing?

[libvips](https://libvips.github.io/libvips/) is a modern, threaded image processing library that processes images faster and using less memory than ImageMagick. Image processing has long been a performance bottleneck on Workarea, so we're adopting this newer tool to achieve better performance in that area.

To do this, Workarea is adding the `dragonfly_libvips`(https://github.com/tomasc/dragonfly_libvips) gem dependency, which will allow configuring Dragonfly for libvips.

### What Do You Need to Do?

If you don't do anything, Workarea will fallback to using ImageMagick processing exclusively. But you don't really want to be that lame do you?

Here are the steps to upgrading to libvips:
* [Install libvips on relevant environments](https://libvips.github.io/libvips/install.html)

* Update any custom Dragonfly Processors

While we've updated the out-of-the-box Dragonfly processors for libvips, you may have some custom ones setup in your app that need to be updated for libvips. This will depend on the type of image processing. For example in base we changed

  ```ruby
  content.process!(:thumb, "#{size}#")
  ```

  to

  ```ruby
  content.process!(:thumb, size, gravity: 'center')
  ```

  You can read more about options on the [dragonfly_libvips](https://github.com/tomasc/dragonfly_libvips) documentation.

* Update tests for image paths

  libvips and Dragonfly use the file's extension to determine file type, so any tests relying on passing the image binary content directly will need to be updated. For example, change

  ```ruby
  product.images.create(image: product_image_file)
  ```

  to

  ```ruby
  product.images.create(image: product_image_file_path)
  ```

## Removal of Configuration DSL Allowing Blank

### What's Changing?

To create functionality more inline with developer expectations, the `allow_blank` option has been removed from the [configuration DSL](/articles/configuration-fields.html). It has been replaced with the `required` option, which defaults to `false`. The default value for the field will be used when the specified value is blank and the `default` option is present.

### What Do You Need to Do?

Replace the `allow_blank` option with the corresponding desired combination of the `required` option and the `default` option.
