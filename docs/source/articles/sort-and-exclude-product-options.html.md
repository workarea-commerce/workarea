---
name: Sort and Exclude Product Options
excerpt: Product Options are an abstraction over Product Variants, grouping common details together in the product detail page for aesthetic purposes. In this guide, learn how to sort and exclude these options programatically.
---

# Sort and Exclude Product Options

Product Options can be sorted and excluded based on pre-defined rules in [configuration](/articles/configuration.html). For more information on the concepts behind these options, visit [the "Products" architecture guide](/articles/products.html#product-options).

## Sorting Product Options

Product options can be sorted differently depending on the product template. For example, options within the **generic** template are not sorted according to the configuration. Instead, the order of the variants in the `<select>` dropdown is dictated by the order the variants appear in the admin. In other templates, such as **option_selects**, a configuration setting is provided for sorting product variants on the detail page. Here's how one might configure size order for the built-in **option_selects** or **option_thumbnails** templates:

```ruby
config.option_selections_sort = lambda do |product, options|
  size_order = ['Small', 'Medium', 'Large', 'Extra Large', '2X Large']

  options.sort_by do |last_option, next_option|
    last_index = size_order.find_index(last_option.name).to_i
    next_index = size_order.find_index(next_option.name).to_i

    last_index <=> next_index
  end
end
```

Let's examine what each of these parameters passed into the lambda represents:

- **product** is the `Workarea::Storefront::ProductViewModel` (or a subclass thereof) representing the current product, and is made available in case data from this product is needed to determine the order of options.
- **options** is a collection of `Workarea::Storefront::ProductViewModel::Option` instances, each representing a detail name from a given variant. In the above example, you can see usage of the `.name` method, this is the titleized name of the option and is used on the storefront to display the given option in the dropdown or thumbnail view.

## Excluding Product Options

In some cases, a Workarea application may exclude certain details from a product. This can be done in one of two ways:

1. Deactivate the `Catalog::Variant` representing this option, or...
2. Excluding the option when `config.option_selections_sort` is called

For example, here's how you would exclude an option called "Blue" from the product detail page for the **option_selects** or **option_thumbnails** templates:

```ruby
config.option_selections_sort = lambda do |product, options|
  options.sort_by(&:name).reject { |name| name == 'Blue' }
end
```

To exclude product options from the **generic** template, deactivate the variants representing those variants in the admin. Only active variants are shown on the product detail page.
