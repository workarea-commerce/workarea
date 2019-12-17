---
title: Releasable
created_at: 2018/07/31
excerpt: A releasable is an application document that includes the Workarea::Releasable module, and thereby has a boolean active field and many changesets (Workarea::Release::Changeset).
---

# Releasable

A <dfn>releasable</dfn> is an [application document](/articles/application-document.html) that includes the `Workarea::Releasable` module, and thereby has a boolean `active` field and many changesets (`Workarea::Release::Changeset`).

```
# create 'Catalog Update' release
release = Workarea::Release.create!(name: 'Catalog Update')

# create 'Shirt' inactive product (a releasable)
product = Workarea::Catalog::Product.create!(name: 'Shirt', activate_with: release.id)

# product is releasable
product.releasable?
# => true

# product is currently inactive
product.active?
# => false

# product has 1 changeset
product.changesets.count
# => 1

# changeset indicates product will become active when release publishes
product.changesets.first.changeset
=> {"active"=>true}

# corresponding release is 'Catalog Update'
product.changesets.first.release.name
# => "Catalog Update"
```

