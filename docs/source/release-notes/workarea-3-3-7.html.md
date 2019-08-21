---
title: Workarea 3.3.7
excerpt: Patch release notes for Workarea 3.3.7.
---

# Workarea 3.3.7

Patch release notes for Workarea 3.3.7.

## Prevent Creation of Invalid Search Customizations

Block saving of customizations when not valid. Return error message back
to the user.

### Issues

- [ECOMMERCE-6289](https://jira.tools.weblinc.com/browse/ECOMMERCE-6289)

### Pull Requests

- [3545](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3545/overview)

### Commits

- [e813c44888ee4dabc254d2a26122bd7136b7a8da](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e813c44888ee4dabc254d2a26122bd7136b7a8da)


## Load Mailer Previews From Plugins and Applications

New or modified previews were not being automatically included in plugins and
host applications, resulting in custom previews not displaying. To resolve this
issue, Workarea now loads all mailer previews at the same time.

### Issues

- [ECOMMERCE-6299](https://jira.tools.weblinc.com/browse/ECOMMERCE-6299)

### Pull Requests

- [3555](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3555/overview)

### Commits

- [c2e997500922ee7e324b00e7443cb944bf859ff2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c2e997500922ee7e324b00e7443cb944bf859ff2)


## Fix Option Selects When There Isn't A Matching Variant

Prevents a 500 error from occurring when the `option_selects` template
is in use and a variant cannot be found for the given selections.

### Issues

- [ECOMMERCE-6297](https://jira.tools.weblinc.com/browse/ECOMMERCE-6297)

### Pull Requests

- [3553](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3553/overview)

### Commits

- [4eb558eb73272c32b653c8d81edb09fbd3f8bf9e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4eb558eb73272c32b653c8d81edb09fbd3f8bf9e)


## Specify JSON Format in Product List Content Block Partial

Part of a larger issue with Rails template overrides, previously this
could be caused by overriding the
`workarea/admin/catalog_products/index.html.haml` view without
overriding its corresponding `index.json.jbuilder`. The index
HTML template now includes a `format: :json` in the path so that this
cannot happen if one forgets to override a JSON template corresponding
to their HTML template.

### Issues

- [ECOMMERCE-6271](https://jira.tools.weblinc.com/browse/ECOMMERCE-6271)

### Pull Requests

- [3556](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3556/overview)

### Commits

- [3aeeb0536e87950fb3c0c56650bec6ff36744aae](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3aeeb0536e87950fb3c0c56650bec6ff36744aae)


## Collect All Payment Method Choices into ARIA Radiogroup

The ARIA `role="radiogroup"` is meant to encapsulate all radio buttons
that represent a single unit of data, but the "New Credit Card" option
was not included in this radiogroup which violates the WCAG spec. Remove
the extra `<div>` containing this role and apply the role to the
`.checkout-payment__primary-method-group` element.

### Issues

- [ECOMMERCE-6144](https://jira.tools.weblinc.com/browse/ECOMMERCE-6144)

### Pull Requests

- [3547](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3547/overview)

### Commits

- [a097b78ff690ba21660b3b38e8036ed225e08378](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a097b78ff690ba21660b3b38e8036ed225e08378)


## Fix Overriding SVG Icons in Style Guides

SVG icons could not be overridden in the style guides, instead, the icon
would just be appended to the end of the list, leaving the original icon
in place. Update the `#style_guide_icons` helper to ensure only 1 of each
filename exists, so icons will appear to override each other in the
style guide.

### Issues

- [ECOMMERCE-6183](https://jira.tools.weblinc.com/browse/ECOMMERCE-6183)

### Pull Requests

- [3552](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3552/overview)

### Commits

- [b290bf9b9e33f28ea0d8a50b9f1f403a8d5fb817](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b290bf9b9e33f28ea0d8a50b9f1f403a8d5fb817)


## Add Proper Link Class To Facet Partial Links

The facet partial links in the Result Filters UI didn't have the right
class name associated with their elements. Workarea now uses a `.result-filters__link`
class name for these elements.

### Issues

- [ECOMMERCE-6249](https://jira.tools.weblinc.com/browse/ECOMMERCE-6249)

### Pull Requests

- [3539](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3539/overview)

### Commits

- [5f1dd9e43cf6cbfb0d16f058fe05c594468cfaaa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5f1dd9e43cf6cbfb0d16f058fe05c594468cfaaa)


