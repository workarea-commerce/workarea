---
title: Workarea 3.1.6
excerpt: Adds a MongoDB index to the Workarea::Order model. The new index supports the order reminder email.
---

# Workarea 3.1.6

## Adds MongoDB Index to Support Order Reminder Emails

Adds a MongoDB index to the `Workarea::Order` model. The new index supports the order reminder email.

**To benefit from this change, you must create this index in any existing MongoDB instances.** Mongoid provides several tasks for managing indexes.

```bash
$ bin/rails -T indexes
rails db:mongoid:create_indexes # Create the indexes defined on your mongoid models
rails db:mongoid:remove_indexes # Remove the indexes defined on your mongoid models without questions
rails db:mongoid:remove_undefined_indexes # Remove indexes that exist in the database but aren't specified on the models
```

### Issues

- [ECOMMERCE-5453](https://jira.tools.weblinc.com/browse/ECOMMERCE-5453)

### Commits

- [8eeea18415d0918e130bbef7635ffcf948ea7c59](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8eeea18415d0918e130bbef7635ffcf948ea7c59)
- [eb7eb1d8a7ec3ad806a3f8f23816218a173786c6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eb7eb1d8a7ec3ad806a3f8f23816218a173786c6)

## Fixes Using Canceled Payment Transactions

Excludes canceled transactions from consideration when calculating payment amounts and operations. Canceled transactions were being included in some places due to oversight.

### Issues

- [ECOMMERCE-5402](https://jira.tools.weblinc.com/browse/ECOMMERCE-5402)

### Pull Requests

- [2926](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2926/overview)

### Commits

- [f5fab8cdc9ce5a187c7996af5fb2790a82baabe0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f5fab8cdc9ce5a187c7996af5fb2790a82baabe0)
- [d05532aa82a596952e5cb02b19b603c33d43fd50](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d05532aa82a596952e5cb02b19b603c33d43fd50)
- [eb7eb1d8a7ec3ad806a3f8f23816218a173786c6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eb7eb1d8a7ec3ad806a3f8f23816218a173786c6)

## Fixes Checkout Autocomplete

Fixes the checkout autocomplete feature, which "fast forwards" a customer to the final step of checkout when checkout information can be autocompleted. A regression has prevented this feature from working properly since Workarea 3.0.

### Issues

- [ECOMMERCE-5438](https://jira.tools.weblinc.com/browse/ECOMMERCE-5438)

### Pull Requests

- [2927](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2927/overview)

### Commits

- [a527a1ed89963156535db3dea6467a120a3ce268](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a527a1ed89963156535db3dea6467a120a3ce268)
- [05de84d4c8707ba89f2d3b3291cae1d5d5ce7b3c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/05de84d4c8707ba89f2d3b3291cae1d5d5ce7b3c)
- [eb7eb1d8a7ec3ad806a3f8f23816218a173786c6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eb7eb1d8a7ec3ad806a3f8f23816218a173786c6)

## Fixes Admin Insights Charts Not Rendering

Fixes an issue preventing some insights charts from rendering in the Admin.

### Issues

- [ECOMMERCE-5437](https://jira.tools.weblinc.com/browse/ECOMMERCE-5437)

### Pull Requests

- [2941](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2941/overview)

### Commits

- [ee98d1398644baf7f5431941e9d55d617dbb76a4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ee98d1398644baf7f5431941e9d55d617dbb76a4)
- [d2e0920c9a70fcc2d79289c73abf82591ac55f08](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d2e0920c9a70fcc2d79289c73abf82591ac55f08)

## Fixes Display of Storefront Cart Adjustment Message

Removes brackets from the flash message shown in the Storefront when the cart is adjusted.

### Issues

- [ECOMMERCE-5075](https://jira.tools.weblinc.com/browse/ECOMMERCE-5075)

### Pull Requests

- [2925](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2925/overview)

### Commits

- [5a609745b209838721560b07ad96bc7ac8b44d63](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5a609745b209838721560b07ad96bc7ac8b44d63)
- [8a0c4c780345eb770e6806907b823da0eec92fb6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8a0c4c780345eb770e6806907b823da0eec92fb6)
- [eb7eb1d8a7ec3ad806a3f8f23816218a173786c6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eb7eb1d8a7ec3ad806a3f8f23816218a173786c6)

## Standardizes Category Summary Content Block View Model

Updates the Storefront `CategorySummaryViewModel` to provide a `view_model` local variable to the view. Other content block view models in the Storefront consistently provide this interface.

### Issues

- [ECOMMERCE-5441](https://jira.tools.weblinc.com/browse/ECOMMERCE-5441)

### Pull Requests

- [2931](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2931/overview)

### Commits

- [8d8a9853d860f495a6ccf94d7c5d4389766ac3f6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8d8a9853d860f495a6ccf94d7c5d4389766ac3f6)
- [9598cbdb1fb00b156f5861c303e02e73f7f65910](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9598cbdb1fb00b156f5861c303e02e73f7f65910)
- [eb7eb1d8a7ec3ad806a3f8f23816218a173786c6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eb7eb1d8a7ec3ad806a3f8f23816218a173786c6)
