---
title: Add a Content Block Type
created_at: 2019/01/14
excerpt: In this guide, I outline the steps for creating a content block type and provide an example for each.
---

# Add a Content Block Type

In this guide, I outline the steps for creating a [content block type](/articles/content.html#block-type) and provide an example for each.

## Create Storefront Component

In most cases, a new block type will be represented by a new UI component in the Storefront. I like to create the component first, before implementing the block type. In some cases, a JavaScript module is coupled with the component to provide its behavior.

In the following examples, I create a _Captioned Image Content Block_ component in the Storefront, and I add the boilerplate for a JavaScript module with the same name that hooks onto the component. The image below shows the finished component in the Storefront.

![Captioned image content block Storefront component style guide](/images/captioned-image-content-block-storefront-component-style-guide.png)

### Add Assets

If your component requires assets, add them to your application at any path included in `Rails.configuration.assets.paths`. My example requires an image, which I add at the following path.

_app/assets/images/workarea/storefront/widget.png_

### Add Style Guide Partial

You need a style guide to develop your component abstractly. To add a Storefront style guide, create a partial under _app/views/workarea/storefront/style\_guides/components/_. Copy the style guide boilerplate from an existing Storefront style guide partial. Alternatively, use the _workarea:style\_guide_ Rails generator to create the file and the boilerplate.

Add static content within the partial to represent your component. My example requires an image and a caption. Below is my partial.

```
/ app/views/workarea/storefront/style_guides/components/_captioned_image_content_block.html.haml

#captioned-image-content-block.style-guide__subsection

  %h3= link_to_style_guide('components', 'captioned_image_content_block')

  %p A content block that displays an image with a caption. Used for figures in technical documentation.

  .style-guide__example-block
    .captioned-image-content-block
      %figure.captioned-image-content-block__figure
        = image_tag('workarea/storefront/widget.png', alt: 'An ACME widget in all its glory', class: 'captioned-image-content-block__image')
        %figcaption.captioned-image-content-block__caption An ACME widget in all its glory
```

If your component is stateful, add additional example blocks to document and test each state.

### Add Stylesheet

Next, add a stylesheet to style the component. My stylesheet follows.

```
// app/assets/stylesheets/workarea/storefront/components/_captioned_image_content_block.scss

/*------------------------------------*\
    #CAPTIONED-IMAGE-CONTENT-BLOCK
\*------------------------------------*/

.captioned-image-content-block {
    text-align: center;
}

    .captioned-image-content-block__figure {}

    .captioned-image-content-block__image {}

    .captioned-image-content-block__caption {
        font-style: italic;
        font-size: 0.75em;
    }
```

To include this Stylesheet, you must override or append to the Storefront stylesheet manifest. I create the following initializer to append my stylesheet.

```
# config/initializers/appends.rb

Workarea.append_stylesheets(
  'storefront.components',
  'workarea/storefront/components/_captioned_image_content_block.scss'
)
```

### Add JavaScript Module

If necessary, create a JavaScript module to attach behavior to your component. Create the module file and copy the boilerplate from an existing Storefront JavaScript module. Alternatively, use the _workarea:js\_module_ Rails generator to create the file and boilerplate.

In my example, I add a minimal JavaScript module for demonstration purposes.

```
// app/assets/javascripts/workarea/storefront/modules/captioned_image_content_blocks.js

/**
 * @namespace WORKAREA.captionedImageContentBlocks
 */
WORKAREA.registerModule('captionedImageContentBlocks', (function () {
    'use strict';

    var handleClick = function () {
        // TODO implement click handler
        window.alert('TODO');
    },

    /**
     * @method
     * @name init
     * @memberof WORKAREA.captionedImageContentBlocks
     */
    init = function ($scope) {
        $('.captioned-image-content-block', $scope).on('click', handleClick);
    };

    return {
        init: init
    };
}()));
```

Similarly to the stylesheet, the JavaScript module must be added to the Storefront JavaScript manifest via override or append. I add to my _appends.rb_ initializer.

```
# config/initializers/appends.rb

Workarea.append_stylesheets(
  'storefront.components',
  'workarea/storefront/components/_captioned_image_content_block.scss'
)

Workarea.append_javascripts(
  'storefront.modules',
  'workarea/storefront/modules/captioned_image_content_blocks.js'
)
```

### Test Component

Now start your server and navigate to your component in your browser to test it. For example, my component is available at the following path.

_/style\_guides/components/captioned\_image\_content\_block_

## Create Block Type

Creating the block type requires adding a block type definition via the content block DSL and adding a partial to render blocks of that type in the Storefront. You can optionally run the _workarea:content\_block\_type_ Rails generator to create the boilerplate for these steps.

(
For more detailed coverage of the content block DSL, see [Content: Content Block DSL](/articles/content.html#content-block-dsl).
For examples, refer to the initializer in Workarea Core where the base content blocks are defined.
Run `$(bundle show workarea-core)/config/initializers/14_content_block_types.rb` to find the path to that initializer within your Workarea installation.
)

### Add Block Type Definition

Define your block type in an initializer. I like to start with a static block (no dynamic data) to confirm everything is working. My initializer is below.

```
# config/initializers/content_block_types.rb

Workarea.define_content_block_types do
  block_type 'Captioned Image' do
    description 'An image with a caption, used for figures in technical documentation.'
  end
end
```

### Add Storefront Partial

Create your Storefront partial under the directory _app/views/workarea/storefront/content\_blocks/_. The file name must match the block type name for the partial to be found when rendering blocks of this type. For now, I copy the static example from my component style guide into the partial.

```
/ app/views/workarea/storefront/content_blocks/_captioned_image.html.haml

.captioned-image-content-block
  %figure.captioned-image-content-block__figure
    = image_tag('workarea/storefront/widget.png', alt: 'An ACME widget in all its glory', class: 'captioned-image-content-block__image')
    %figcaption.captioned-image-content-block__caption An ACME widget in all its glory
```

### Test Block Type

Start your server and navigate to a content edit screen to add a new block. Your new block type is listed.

![Adding captioned image block with default icon](/images/adding-captioned-image-block-default-icon.png)

Choosing that type renders your static content in the preview and offers the default display options for editing.

![Editing a static captioned image block with default icon](/images/editing-static-captioned-image-block-default-icon.png)

Saving and navigating to that content in the Storefront renders your static content.

![Captioned image block in the Storefront](/images/captioned-image-block-in-storefront.png)

## Optionally Add Custom Admin Icon

To provide a custom Admin icon for your block type, create an SVG icon file that mimics the presentation and properties of those used by the default block types in the Admin. Save the icon under the directory _app/assets/images/workarea/admin/content\_block\_types/_. The file name must match your block type name.

For my example, I add an icon at the following path.
( I designed my icon to stand out in screenshots. Your icon should more closely match the existing icons. )

_app/assets/images/workarea/admin/content\_block\_types/captioned\_image.svg_

Within the Admin, add a new block to confirm the icon is displaying correctly.

![Adding captioned image block with custom icon](/images/adding-captioned-image-block-custom-icon.png)

![Editing a static captioned image block with custom icon](/images/editing-static-captioned-image-block-custom-icon.png)

## Replace Static Content with Dynamic Data

To finish the block type, you must replace the static content with dynamic data. This requires adding [fields](/articles/content.html#field) to the block type definition, providing default data for those fields, and outputting the field data in the Storefront partial (often using a Storefront view model to manipulate the data first).

My example uses _Image_ and _Caption_ fields, as shown below.

![Editing a dynamic captioned image block](/images/editing-dynamic-captioned-image-block.png)

### Update Block Type Definition

Revisit your initializer to add content [fields](/articles/content.html#field). I add the _Image_ and _Caption_ fields to my example below. To set the default _Image_ value, I copy a useful code block from the Workarea Core content block types initializer.

( Workarea 3.1 adds `Workarea::Content::AssetLookup::find_asset_id_by_file_name`, so if you are targeting Workarea 3.1 or later, you can use `find_asset_id_by_file_name` and avoid the need to implement `find_asset_id` as shown in my examples. )

```
# config/initializers/content_block_types.rb

Workarea.define_content_block_types do
  # copied from workarea-core/config/initializers/14_content_block_types.rb
  find_asset_id = lambda do |name|
    proc do
      asset = Workarea::Content::Asset.where(file_name: name).first ||
                Workarea::Content::Asset.image_placeholder

      asset.try(:id)
    end
  end

  block_type 'Captioned Image' do
    description 'An image with a caption, used for figures in technical documentation.'
    field 'Image', :asset, required: true, file_types: 'image', default: find_asset_id.call('widget.png')
    field 'Caption', :string, default: 'An ACME widget in all its glory'
  end
end
```

### Add Default Data

If the default values for your fields require data (products, assets, etc), add seeds for that data. My example requires a [content asset](/articles/content.html#asset), so I add the following seeds file.

```
# app/seeds/workarea/content_seeds.rb

module Workarea
  class ContentSeeds
    def perform
      puts 'Adding content...'

      image_path = Rails.root.join(
        'app/assets/images/workarea/storefront/widget.png'
      )
      Content::Asset.create!(file: File.new(image_path))
    end
  end
end
```

And I add an initializer to update the list of seeds.

```
# config/initializers/seeds.rb

Workarea.config.seeds << "Workarea::ContentSeeds"
```

### Add Storefront View Model

If you need to manipulate data values before displaying them, add a Storefront view model for your block type. Create the view model under the directory _app/view\_models/workarea/storefront/content\_blocks/_. The file name must match your block type name.

For my example, I need to convert the content asset instance stored in `data[:image]` into an image path. I therefore create the following view model. As a convenience, I also add the `caption` method which simply passes through the value of `data[:caption]`.

```
# app/view_models/workarea/storefront/content_blocks/captioned_image_view_model.rb

module Workarea
  module Storefront
    module ContentBlocks
      class CaptionedImageViewModel < ContentBlockViewModel
        def image
          find_asset(data[:image])
        end

        def caption
          data[:caption]
        end
      end
    end
  end
end
```

### Update Storefront Partial

Finally, update your Storefront partial, replacing static content with data from the view model. My updated partial follows.

```
/ app/views/workarea/storefront/content_blocks/_captioned_image.html.haml

.captioned-image-content-block
  %figure.captioned-image-content-block__figure
    = image_tag(view_model.image.url, alt: view_model.caption, class: 'captioned-image-content-block__image')
    - if view_model.caption.present?
      %figcaption.captioned-image-content-block__caption= view_model.caption
```

If you are not using a Storefront view model, you can access the values of the `data` hash by calling methods that match the names of the hash's keys.
However, in cases where such a value does not exist, an exception will be raised.
You should therefore use the method `local_assigns` when a value may or may not be present.
The follow example demonstrates this, accessing the value of `data[:title]` in three different ways.

```haml
/ you can access a value directly if you're sure it's present
= title

/ use local_assigns if the value could be blank
= local_assigns[:title].presence

/ use local_assigns to conditionally output the value
- if local_assigns[:title].present?
 = title
```

## Test

You can confirm your block type is working by creating a new block of this type in the Admin and viewing the result in the Storefront. I did not write any automated tests for my example because its functionality is covered by existing platform tests. However, you may need to write a view model test and a system test if your block type includes logic or UI features that are more complex than my example.
