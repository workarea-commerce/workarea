---
title: Content
created_at: 2018/07/31
excerpt: The Content namespace is responsible for modeling administrable content.
---

# Content

The `Content` namespace is responsible for modeling administrable content.

## Asset

A <dfn>content asset</dfn> (`Workarea::Content::Asset`) is a [taggable](/articles/taggable.html) [application document](/articles/application-document.html) that represents a file, such as an image or PDF document, that is available for use within administrable content.

```
# Create an asset
asset = Workarea::Content::Asset.create!(file: File.new('foo.png'))

# Inspect its attributes
asset.name
# => "foo"

asset.id.to_s
# => "58af0a74eefbfef6f328470a"

asset.type
# => "image"

asset.pdf?
# => false

asset.image?
# => true

asset.format
# => "png"

asset.height
# => 300

asset.width
# => 300

asset.aspect_ratio
# => 1.0

asset.portrait?
# => true

asset.alt_text
# => "A foo image"
```

## Page

A <dfn>content page</dfn> (`Workarea::Content::Page`) is a [contentable](/articles/contentable.html), [navigable](/articles/navigable.html), [releasable](/articles/releasable.html), and [taggable](/articles/taggable.html) [application document](/articles/application-document.html) that represents a page containing administrable content to which end users may navigate.

A page has few attributes of its own because the actual content is stored on its associated content. However, each page has a name and several attributes to control its presentation in the storefront.

```
page = Workarea::Content::Page.create!(name: 'Shopping Guide')

page.name
# => "Shopping Guide"

page.template
# => "generic"

page.show_navigation
# => false

page.display_h1
# => true
```

## Content

A <dfn>content</dfn> (`Workarea::Content`) is a [releasable](/articles/releasable.html) [application document](/articles/application-document.html) that represents administrable content. A content may belong to a [contentable](/articles/contentable.html). A content embeds many blocks.

### System Content

Contents that do not belong to contentables are identified by name and are referred to as "system content". Pass a string representing the content name to `Content.for` to `find_or_create` a system content. The string will be `titleize`ed before finding or creating the content.

```
# Create a content
content = Workarea::Content.for('foo_bar')

content.name
# => "Foo Bar"

content.id.to_s
# => "58ac7eefeefbfe3e5ac2ae54"

content.system?
# => true

# Find the same content
Workarea::Content.for('foo_bar').name
# => "Foo Bar"

Workarea::Content.for('Foo Bar').id
# => "58ac7eefeefbfe3e5ac2ae54"

Workarea::Content.for('foo bar').system?
# => true
```

### Attributes

In addition to managing its blocks, a content has attributes representing HTML document metadata. The `automate_metadata` boolean specifies if HTML metadata should be generated automatically if none is provided. Explicit values for `browser_title`, `meta_keywords`, and `meta_description` will override any automated values generated.

```
content = Workarea::Content.for('foo_bar')

content.browser_title
# => nil

content.meta_keywords
# => nil

content.meta_description
# => nil

content.automate_metadata
# => true
```

A content also has attributes that store strings of CSS and JavaScript. These strings may be output as inline CSS and JavaScript in the Storefront depending on how the content is used.

```
content.css
# => nil

content.javascript
# => nil
```

## Block

A <dfn>content block</dfn> (`Workarea::Content::Block`) is a [releasable](/articles/releasable.html) [application document](/articles/application-document.html) that represents a unit of administrable content. A block is embedded in a content.

A newly created content has 0 blocks.

```
content.blocks.count
# => 0

content.blocks
# => []
```

Create a block within a content by specifying the type of block to be created.

```
# Create an instance of an 'Image' block
content.blocks.create!(type: 'image')

content.blocks.count
# => 1

# Access the block from the content
block = content.blocks.first
block.name
# => "Image - 960x470 Light"

# Access the content from the block
block.content.class
# => Workarea::Content
```

### Type

Use a block's `type` method to access the corresponding block type instance. Block type instances are kept in memory within `Configuration::ContentBlocks.types`. View that collection to see all available block types.

```
block.type.class
# => Workarea::Content::BlockType

block.type.name
# => "Image"

puts Configuration::ContentBlocks.types.map(&:name)
# Hero
# Image
# Text
# Video
# Button
# Taxonomy
# Two Column Taxonomy
# Three Column Taxonomy
# Quote
# Image Group
# Image and Text
# Video and Text
# Category Summary
# Recommendations
# Product List
# HTML
# Divider
# Social Networks
```

### Data

Use a block's `data` method to get or set its data, which is stored as a `HashWithIndifferentAccess`.

If a block was not initialized with data, it's data will be constructed from the field names and their default values, as defined by the block's type. In the examples below, note the relationship between the persisted data keys on the block and the in-memory field names on the block's type.

```
block.data
# => {
        "image" => "58ac6ad2eefbfe1ebac121ae",
        "alt" => "",
        "link" => "/",
        "align" => "Center"
      }

block.type.fields.map(&:name)
# => [
        "Image",
        "Alt",
        "Link",
        "Align"
      ]
```

#### Typecasting

Before validation, the block's data is mutated. Each value is typecast by the corresponding field in the block type. Each field may provide its own implementation of `typecast`. In the following example a data value specified as an integer is cast as a string.

```
block = content.blocks.create!(type: 'html', data: { html: 42 })
block.data[:html]
# => "42"
```

#### Validation

A data value may not be blank if the corresponding field on the block type is required.

```
content.blocks.create!(type: 'image', data: { asset: '' })
# Mongoid::Errors::Validations:
# message:
# Validation of Workarea::Content::Block failed.
# summary:
# The following errors were found: Image can't be blank
```

### Attributes

Content blocks have several other attributes that are used to manage their display in the Storefront. Be aware that `name` is derived from the block's type and data and is not an attribute on the model.

```
block.area
# => "default"

block.position
# => 0

block.breakpoints
# => [:small, :medium, :wide, :x_wide]
```

## Block Type

A <dfn>block type</dfn> (`Workarea::Content::BlockType`) defines a type of content block using fieldsets and fields.

The default block types are defined using the content block DSL in an initializer that ships with the platform. Modify these block types or create your own using the content block DSL in an initializer within your application.

Block types exist in memory only (they aren't persisted). Access all block types via the `Configuration::ContentBlocks.types` collection or look up a specific block type using `BlockType.find`.

```
puts Configuration::ContentBlocks.types.map(&:id)
# hero
# image
# text
# video
# button
# taxonomy
# two_column_taxonomy
# three_column_taxonomy
# quote
# image_group
# image_and_text
# video_and_text
# category_summary
# recommendations
# product_list
# html
# divider
# social_networks

Workarea::Content::BlockType.find(:image_and_text).name
# => "Image and Text"
```

A block type has a name and an id (also called a slug) that is derived from the name. Beyond that, a block type is primarily a collection of fieldsets. The `fields` method returns a flattened list of all fields across all fieldsets on a given block type.

```
image_and_text_type = Workarea::Content::BlockType.find(:image_and_text)

image_and_text_type.name
# => "Image and Text"

image_and_text_type.id
# => :image_and_text

image_and_text_type.slug
# => :image_and_text

image_and_text_type.fieldsets.count
# => 2

image_and_text_type.fieldsets.map(&:name)
# => ["Image", "Text"]

image_and_text_type.fields.count
# => 6

image_and_text_type.fields.map(&:name)
# => ["Image", "Image Alt", "Image Link", "Image Position", "Text", "Text Alignment"]
```

## Fieldset

A <dfn>fieldset</dfn> (`Workarea::Content::Fieldset`) groups fields within a block type to improve the experience of administrating a content block.

A fieldset has a name, which will be used as a label in the admin, and a group a fields that will appear under that label.

```
fieldset = image_and_text_type.fieldsets.first

fieldset.name
# => "Image"

fieldset.fields.count
# => 4

fieldset.fields.map(&:name)
# => ["Image", "Image Alt", "Image Link", "Image Position"]
```

## Field

A <dfn>field</dfn> (subclasses of `Workarea::Content::Field`) represents a field to be displayed for a block type in the Admin UI. It defines how the field's value should be typecast before being persisted, and it optionally provides a default value.

### Type

When adding a field to a block type using the content block DSL, you provide name, type, and options. The type corresponds to a subclass of `Workarea::Content::Field` and determines the partial that will be rendered in the Admin to capture the value for that field and also how the value will be typecast before being persisted.

```
product_list_blocktype = Workarea::Content::BlockType.find(:product_list)

product_list_blocktype.fields.count
# => 2

field_1 = product_list_blocktype.fields[0]
field_2 = product_list_blocktype.fields[1]

field_1.type
# => :string

field_1.partial
# => "string"

# string fields cast to string
field_1.typecast(1)
# => "1"

field_2.type
# => :products

field_2.partial
# => "products"

# products fields cast to array of strings
field_2.typecast(1)
# => ["1"]
```

The following table summarizes the default field types.

| Field Type | Data Type | UI Control | Unique Options |
| --- | --- | --- | --- |
| asset | string (id of the selected content asset) | `asset-picker-field` component | `file_types` (array): asset types to be included in the asset picker |
| boolean | boolean | `toggle-button` component | - |
| category | string (id of the selected category) | remote select (an HTML `select` enhanced by `WORKAREA.remoteSelects`) | - |
| color | string | HTML `input[type=color]` | - |
| integer | integer | HTML `input[type=number]` | - |
| options | string | HTML `select` | `values` (array): options for the select |
| products | array of strings (ids of the selected products) | remote select (an HTML `select` enhanced by `WORKAREA.remoteSelects`) | `single` (boolean), allows enforcing only a single product selection (since v3.3.3) |
| range | float | HTML `input[type=range]` and `input[type=number]` | `min`, `max`, and `step` (all floats) are passed through to the `input[type=range]` control; `note` displays within a `.property__note` |
| string | string | HTML `input[type=text]` or `textarea` | `multi_line` (boolean), determines type of UI control |
| taxonomy | string (id of the selected taxon) | `taxon-select` component | - |
| text | string | `wysiwyg` component | - |
| url | string | HTML `input[type=text]` | - |
| breakpoints&nbsp;\* | array | HTML `input[type=checkbox]`s, one for each key in `Workarea.config.storefront_break_points` | - |

\* Each block type includes a breakpoints field automatically. You should not specify this type of field when defining a block type using the content block DSL.

### Attributes

The name of a field is used as the field label in the Admin UI, while the options are used to determine the default value, whether the field is required, and other details that are specific to the field type. The `default` option can provide a value or a callable object that returns the value. The `default` method will return the value, calling the object if present. The `required?` method returns `true` if the `required` option is set to `true`.

```
field_1.name
# => "Title"

field_1.options
# => { :default => "Featured" }

field_1.default
# => "Featured"

field_1.required?
# => false

field_2.name
# => "Products"

# default value is a
field_2.options
# => { :default => #<Proc> }

field_2.default
# => ["E5F83359BC", "8AC32E3757", "2B3D02499A"]

field_2.required?
# => false
```

## Content Block DSL

The <dfn>content block DSL</dfn> allows you to extend and augment the content block types available to your application. Use the DSL within an initializer in your app.

The entry point for the DSL is `Workarea.define_content_block_types`. Pass this method a block in which you define the block types you want to add (or extend). Give each block type a name and use a block to set its attributes. Each new block type is pushed onto the collection of block types stored in `Configuration::ContentBlocks.types`.

```
Workarea.define_content_block_types do
  block_type 'Foo' do
    # ...
  end

  block_type 'Bar' do
    # ...
  end
end
```

### Meta Data

Use the `description` setter to set a description for the block type that will be shown to administrators when browsing block types in the Admin UI. Use `tags` to set tags which can be used to filter block types in the Admin. Use `icon` to specify the path to an SVG icon to represent the block in the admin. Use this only if you do not want to use the default icon path.

```
Workarea.define_content_block_types do
  block_type 'Foo' do
    icon 'path/to/icon.svg'
    description 'Foo description'
    tags %w(foo bar baz)
  end
end
```

### Fields & Fieldsets

Use the `field`, `fieldset`, and `series` setters to declare the fields and fieldsets for each block type.

Use `field` to add a field to the default "Settings" fieldset. Provide name, type, and options for the field. Refer to the field documentation, above, for the list of available field types and options.

```
Workarea.define_content_block_types do
  block_type 'Foo' do
    # ...
    field 'Message', :text, required: true, default: 'Your text here'
  end
end
```

Use `fieldset` to create a new fieldset. Provide a name for the fieldset and a block defining the fields for that fieldset.

```
Workarea.define_content_block_types do
  block_type 'Foo' do
    # ...
    fieldset 'Message' do
      field 'Type', :options, values: %w(info warning), default: 'info'
      field 'Message', :text, required: true, default: 'Your text here'
    end
  end
end
```

Use `series` to create a series of fieldsets that share the same fields. The example below creates 4 fieldsets, each with a 'Image' and 'Alt' field.

```
Workarea.define_content_block_types do
  block_type 'Image Slideshow' do
    # ...
    series 4 do
      field 'Image', :asset
      field 'Alt', :string
    end
  end
end
```

Persisted block data contains only fields, not fieldsets, so the fields of a series will have a suffix to differentiate themselves. Data for the block type shown above will look something like the example below.

```
{
  'image_1' => '...',
  'alt_1' => '...',
  'image_2' => '...',
  'alt_2' => '...',
  'image_3' => '...',
  'alt_3' => '...',
  'image_4' => '...',
  'alt_4' => '...'
}
```

Asset fields, as showcased in the examples above, can pass a special option when being defined that will associate the field with another for the purposes of supplying a default value for the image's <code>alt</code> attribute:

```
Workarea.define_content_block_types do
  block_type 'Image' do
    field 'Image', :asset, alt_field: 'Image Alt Text'
    field 'Image Alt Text', :string
  end
end
```

Once associated, when outputting the `image_alt_text` field in the Storefront view if no value is supplied for the field the Asset's `alt_text` attribute will be used instead, as a default value.

## Preset

A <dfn>content preset</dfn> (`Workarea::Content::Preset`) is an [application document](/articles/application-document.html) that represents preset data for a new content block instance. Admins can create presets from existing blocks and then create new blocks from those presets rather than using the default data for a block.

```
content = Workarea::Content.for('foo')

new_block = content.blocks.create!(type: 'text', data: {
  text: 'Not the default, something re-usable'
})

Workarea::Content::Preset.create_from_block({}, new_block)
# => true

preset = Workarea::Content::Preset.first

block_from_preset = content.blocks.create!(preset.block_attributes)

new_block.type_id
# => :text

preset.type_id
# => :text

block_from_preset.type_id
# => :text

new_block.data
# => {"text"=>"Not the default, something re-usable"}

preset.data
# => {"text"=>"Not the default, something re-usable"}

block_from_preset.data
# => {"text"=>"Not the default, something re-usable"}
```
