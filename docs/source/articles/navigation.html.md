---
title: Navigation
created_at: 2018/07/31
excerpt: Within a Workarea application, navigables and other nodes are organized into a tree of taxons, which is then used to build tree-based navigation, such as breadcrumbs, and content-based navigation, such as menus.
---

# Navigation

Within a Workarea application, [navigables](/articles/navigable.html) and other nodes are organized into a tree of taxons, which is then used to build tree-based navigation, such as breadcrumbs, and content-based navigation, such as menus.

## Taxon

A <dfn>navigation taxon</dfn> (`Workarea::Navigation::Taxon`) is an [application document](/articles/application-document.html) that represents a node of the site's taxonomy tree.

### Tree Structure

A taxon includes the following interfaces for manipulating a tree structure:

- `Mongoid::Tree` ([docs](http://www.rubydoc.info/github/benedikt/mongoid-tree/Mongoid/Tree))
- `Mongoid::Tree::Ordering` ([docs](http://www.rubydoc.info/github/benedikt/mongoid-tree/Mongoid/Tree/Ordering))
- `Mongoid::Tree::Traversal` ([docs](http://www.rubydoc.info/github/benedikt/mongoid-tree/Mongoid/Tree/Traversal))

#### Root

`Taxon.root` returns the root taxon, which represents the site's home page.

```
root_taxon = Workarea::Navigation::Taxon.root

root_taxon.name
# => "Home"

root_taxon.url
# => "/"
```

#### Parent

With the exception of the root taxon, each taxon has a parent.

```
root_taxon.parent
# => nil

clothing_taxon = root_taxon.children.create!(name: 'Clothing')

clothing_taxon.parent.name
# => "Home"

mens_clothing_taxon = clothing_taxon.children.create!(name: 'Men')

mens_clothing_taxon.name
# => "Men"

mens_clothing_taxon.parent.name
# => "Clothing"
```

Taxons created without an explicit parent node are created as children of the root node.

```
sporting_goods_taxon = Workarea::Navigation::Taxon.create!(
  name: 'Sporting Goods'
)
sporting_goods_taxon.parent.name
# => "Home"
```

### URL

A taxon may act as a pointer to an arbitrary URL or path.

```
blog_taxon = Workarea::Navigation::Taxon.create!(
  name: 'Blog',
  url: 'http://blog.example.com'
)

blog_taxon.name
# => "Blog"

blog_taxon.url
# => "http://blog.example.com"

blog_taxon.url?
# => true

blog_taxon.resource_name
# => "url"

blog_taxon.resource_name.url?
# => true
```

The root taxon points to the root path of the site.

```
Workarea::Navigation::Taxon.root.url
# => "/"
```

A taxon is not [releasable](/articles/releasable.html) and does not have an `active` attribute. However, a taxon will respond to the `active?` method. A taxon with a URL is always considered active and will always respond `true`.

```
blog_taxon.active?
# => true
```

### Navigable

Instead of referencing an arbitrary URL or path, a taxon may reference a [navigable](/articles/navigable.html). If not given an explicit name, the taxon will copy the name of the navigable. Taxon navigables are validated for uniqueness, so no two taxons may reference the same navigable.

```
fit_guide_page = Workarea::Content::Page.create!(name: 'Fit Guide')
fit_guide_page_taxon = Workarea::Navigation::Taxon.create!(
  navigable: fit_guide_page
)

fit_guide_page_taxon.name
# => "Fit Guide"

fit_guide_page_taxon.navigable.class
# => Workarea::Content::Page

fit_guide_page.taxon.navigable.name
# => "Fit Guide"

fit_guide_page.taxon.navigable_slug
# => "fit-guide"

fit_guide_page_taxon_2 = Workarea::Navigation::Taxon.create!(
  navigable: fit_guide_page
)
# Mongoid::Errors::Validations:
# message:
# Validation of Workarea::Navigation::Taxon failed.
# summary:
# The following errors were found: Navigable is already taken

fit_guide_page_taxon.url?
# => false

fit_guide_page_taxon.navigable?
# => true

fit_guide_page_taxon.resource_name
# => "page"

fit_guide_page_taxon.resource_name.page?
# => true
```

A taxon with a navigable delegates its `active` status to the navigable.

```
fit_guide_page_taxon.active?
# => true

fit_guide_page.active = false
fit_guide_page.active?
# => false

fit_guide_page_taxon.active?
# => false
```

### Placeholder

A taxon may be created without a URL and a navigable as long as it is given a name. This type of taxon is called a placeholder and may be used to group other taxons (its children) under a text only "heading".

```
sporting_goods_taxon.name
# => "Sporting Goods"

sporting_goods_taxon.url?
# => false

sporting_goods_taxon.navigable?
# => false

sporting_goods_taxon.placeholder?
# => true

sporting_goods_taxon.resource_name
# => "placeholder"

sporting_goods_taxon.resource_name.placeholder?
# => true
```

A placeholder taxon does not have an `active` attribute and does not have a navigable to which it can delegate its active status. Therefore it is always considered active.

```
sporting_goods_taxon.active?
# => true
```

### Menu

`Taxon#menu` returns the first navigation menu that belongs to the taxon. In practice, a taxon and a menu have a 1:1 relationship. `Taxon#in_menu?` returns `true` if a menu belongs to the taxon.

```
clothing_category = Workarea::Catalog::Category.create!(name: 'Clothing')
clothing_category_taxon = Workarea::Navigation::Taxon.create!(
  navigable: clothing_category
)
clothing_menu = Workarea::Navigation::Menu.create!(
  taxon: clothing_category_taxon
)

clothing_category_taxon.menu.class
# => Workarea::Navigation::Menu

clothing_category_taxon.menu.name
# => "Clothing"

clothing_category_taxon.in_menu?
# => true
```

## Breadcrumbs

A <dfn>breadcrumbs</dfn> (`Workarea::Navigation::Breadcrumbs`) is an enumerable representing a collection of taxons. A breadcrumbs instance is initialized with a [navigable](/articles/navigable.html) and represents the breadcrumb nodes for that navigable.

```
clothing_category = Workarea::Catalog::Category.create!(name: 'Clothing')
clothing_category_taxon = Workarea::Navigation::Taxon.root.children.create!(
  navigable: clothing_category
)
mens_clothing_category = Workarea::Catalog::Category.create!(name: 'Men')
mens_clothing_category_taxon = clothing_category_taxon.children.create!(
  navigable: mens_clothing_category
)
mens_clothing_category_breadcrumbs = Workarea::Navigation::Breadcrumbs.new(
  mens_clothing_category
)

mens_clothing_category_breadcrumbs.count
# => 3

mens_clothing_category_breadcrumbs.map(&:class)
# => [
# Workarea::Navigation::Taxon,
# Workarea::Navigation::Taxon,
# Workarea::Navigation::Taxon
# ]

mens_clothing_category_breadcrumbs.map(&:name)
# => ["Home", "Clothing", "Men"]

mens_clothing_category_breadcrumbs.join(' > ')
# => "Home > Clothing > Men"
```

### Last

A `last` may be provided to add a final taxon to the collection. This is useful when the navigable is not directly in the taxonomy, like a product that belongs to a category that is within the taxonomy, rather than being in the taxonomy directly.

```
sweatpants_product = Workarea::Catalog::Product.create!(name: 'Sweatpants')
mens_clothing_category.update_attributes!(product_ids: [sweatpants_product.id])
sweatpants_product_breadcrumbs = Workarea::Navigation::Breadcrumbs.new(
  mens_clothing_category,
  last: sweatpants_product.name
)

sweatpants_product_breadcrumbs.count
# => 4

sweatpants_product_breadcrumbs.join(' > ')
# => "Home > Clothing > Men > Sweatpants"
```

### Global ID

A breadcrumbs collection may also be initialized using the global ID of the navigable, and can return the global ID of the navigable.

```
mens_clothing_category_breadcrumbs.join(' > ')
# => "Home > Clothing > Men"

mens_clothing_category_global_id =
  mens_clothing_category_breadcrumbs.to_global_id
# => "Z2lkOi8vbGVhcm4tdjMvV2VibGluYzo6Q2F0YWxvZzo6Q2F0ZWdvcnkvNThiY2I2M2JlZWZiZmU5YTY0MWEyZGNk"

Workarea::Navigation::Breadcrumbs
  .from_global_id(mens_clothing_category_global_id)
  .join(' > ')
# => "Home > Clothing > Men"
```

## Menu

A <dfn>navigation menu</dfn> (`Workarea::Navigation::Menu`) is a [contentable](/articles/contentable.html) and [releasable](/articles/releasable.html) [application document](/articles/application-document.html) that represents a menu within a navigation.

### Taxon

A menu has a 1:1 relationship with a taxon and generally delegates its name to the taxon.

```
clothing_category = Workarea::Catalog::Category.create!(name: 'Clothing')
clothing_category_taxon = Workarea::Navigation::Taxon.create!(
  navigable: clothing_category
)
clothing_menu = Workarea::Navigation::Menu.create!(
  taxon: clothing_category_taxon
)

clothing_menu.taxon.class
# => Workarea::Navigation::Taxon

clothing_menu.taxon.name
# => "Clothing"

clothing_menu.name
# => "Clothing"
```

### Active

A menu's `active?` status (see [Releasable](/articles/releasable.html)) also depends on the taxon. For a menu to be active, both the menu and the corresponding taxon must be active. Note that a taxon with a navigable delegates its active status to its navigable.

```
clothing_category = Workarea::Catalog::Category.create!(
  name: 'Clothing',
  active: false
)
clothing_category_taxon = Workarea::Navigation::Taxon.create!(
  navigable: clothing_category
)
clothing_menu = Workarea::Navigation::Menu.create!(
  taxon: clothing_category_taxon,
  active: false
)

clothing_category.active?
# => false

clothing_menu.active?
# => false

clothing_menu.active = true

clothing_menu.active?
# => false

clothing_category.active = true
# => true

clothing_menu.active?
# => true
```

### Position

Each menu has a `position` attribute, and menus are returned sorted by position ascending.

```
foo = Workarea::Navigation::Taxon.create!(name: 'Foo')
bar = Workarea::Navigation::Taxon.create!(name: 'Bar')
baz = Workarea::Navigation::Taxon.create!(name: 'Baz')

Workarea::Navigation::Menu.create!(taxon: foo, position: 2)
Workarea::Navigation::Menu.create!(taxon: bar, position: 0)
Workarea::Navigation::Menu.create!(taxon: baz, position: 1)

Workarea::Navigation::Menu.all.map(&:name)
# => ["Bar", "Baz", "Foo"]
```

## Storefront Navigation

The Storefront's application layout outputs a _mobile navigation_, used by most applications for small screens only, and a _primary navigation_, used by most applications for wide screens only.

The mobile navigation uses `Storefront::MenusController#index` and `Storefront::MenusController#show` to display the list of all active menus and the content for a specific menu, respectively.

The primary navigation uses `Storefront::NavigationHelper#navigation_menus` to output all active menus, and the `WORKAREA.primaryNavContent` JavaScript module is responsible for requesting and displaying the content for menus when they are hovered.

### Taxonomy Content Blocks

Taxonomy [content blocks](/articles/content.html#block) allow admins to display a subset of the site's taxonomy tree within a content, such as the content of a navigation menu. Storefront navigation is often implemented as a list of menus, each of which has content that is displayed as a drop down and includes lists of links that are "plucked" from the taxonomy.

Taxonomy content blocks make use of a taxonomy [field](/articles/content.html#field) (`Content::Fields::Taxonomy`), which allows admins to provide the starting position within the taxonomy and output a list of links from that starting position. For example, if the taxon selected as the starting position has children, those children will be output as a list within the content block. Some taxonomy blocks include multiple taxonomy fields to allow for multiple lists of links that can be displayed in columns or another arrangement.

The starting taxon is stored in the block's [data](/articles/content.html#data) as the string id of the taxon, and the view model for the particular [block type](/articles/content.html#block-type) looks up the correct taxon for display.


