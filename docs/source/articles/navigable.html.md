---
title: Navigable
created_at: 2018/07/31
excerpt: A navigable is an application document that includes the Workarea::Navigable module, and thereby has a slug attribute and a 1:1 relationship with a taxon.
---

# Navigable

A <dfn>navigable</dfn> is an [application document](/articles/application-document.html) that includes the `Workarea::Navigable` module, and thereby has a `slug` attribute and a 1:1 relationship with a [taxon](/articles/navigation.html#taxon).

## Slug

A navigable has a `slug` attribute, which is a unique, human- and URL-friendly string used to identify the model, particularly when requesting the model via a URL.

For example, in the Storefront, the path _/pages/foo_ is routed to `Storefront::PagesController#show`, which looks up the requested page by slug:

```
Content::Page.find_by(slug: params[:id])
```

Calling `to_param` on a navigable returns the navigable's slug, allowing idiomatic use of Rail's routing helpers, while maintaining "pretty" URLs.

```
= page_path(@page)
/ evaluates to "/pages/foo"
```

A navigable must have a slug, but one will be generated if not provided explicitly. A generated slug is derived from the navigable's name, including an incrementing suffix if needed to ensure uniqueness.

```
Workarea::Catalog::Category.create!(name: 'Foo').slug
# => "foo"

Workarea::Catalog::Category.create!(name: 'Foo').slug
# => "foo-1"
```

## Taxon

A navigable has a 1:1 relationship with a [taxon](/articles/navigation.html#taxon), which represents the navigable's position within the site's taxonomy tree.

```
navigable = Workarea::Catalog::Product.create!(name: 'Foo')
taxon = Workarea::Navigation::Taxon.create!(navigable: navigable)

navigable.taxon.class
# => Workarea::Navigation::Taxon

navigable.taxon.name
# => "Foo"
```

