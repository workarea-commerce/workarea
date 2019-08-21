---
title: Workarea 3.3.5
excerpt: Patch release notes for Workarea 3.3.5.
---

# Workarea 3.3.5

Patch release notes for Workarea 3.3.5.

## Fix Error in Image Collection When Missing Product Image Option

When a product image's option is explicitly set to `nil`, an error
occurred in the `Workarea::ImageCollection` when trying to determine
whether the option was selected. Ensure that `image.option` is a String
prior to making this comparison to prevent a cryptic `NoMethodError`
from occurring.

### Issues

- [ECOMMERCE-6231](https://jira.tools.weblinc.com/browse/ECOMMERCE-6231)

### Pull Requests

- [3518](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3518/overview)

### Commits

- [d7cb1ceb5c8d892661f41460c51164c7eba8066f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d7cb1ceb5c8d892661f41460c51164c7eba8066f)


## Fix Error on Display of Email Content Updates in Activity Feed

When email content updates were displayed in the activity feed, a syntax
error was thrown due to a lack of parenthesis at the `else` end of a ternary
statement in Haml. Once this error was resolved, however, a new error
would be thrown stating that `Content::Email#name` was not a method.
Workarea now defines this method on `Content::Email` as the titleized version of
`#type`, in order to view the activity feed for email content properly in admin.

### Issues

- [ECOMMERCE-6190](https://jira.tools.weblinc.com/browse/ECOMMERCE-6190)

### Pull Requests

- [3502](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3502/overview)

### Commits

- [b3eb03d8016a2322e7ec9591a786d17ef28701b9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b3eb03d8016a2322e7ec9591a786d17ef28701b9)


## Add IDs to all Text Heading Tags in Documentation

Add custom renderer for including `id=""` attributes in heading text for
linking purposes.

### Issues

- [ECOMMERCE-6200](https://jira.tools.weblinc.com/browse/ECOMMERCE-6200)

### Pull Requests

- [3505](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3505/overview)

### Commits

- [c10acf88333b5b52cc4dbc8f3cbc5df9037387c2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c10acf88333b5b52cc4dbc8f3cbc5df9037387c2)


## Don't Send Status Email To Non Admins

If admin permissions are only partially removed from a user, status
emails can still be sent to email addresses which are no longer admins.
Check `:admin` status in addition to `:status_email_recipient` when
finding emails to send status emails to.

### Issues

- [ECOMMERCE-6230](https://jira.tools.weblinc.com/browse/ECOMMERCE-6230)

### Pull Requests

- [3517](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3517/overview)

### Commits

- [99be7bff9ac31202f547b1b236da5f00efd277b9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/99be7bff9ac31202f547b1b236da5f00efd277b9)


## Don't Send Refund Emails When Amount is Zero

When an order for $0.00 is refunded, a transactional email was sent
indicating that the order had been refunded. The core system no
longer does this, instead refraining to deliver the email if the refund
amount is $0.00.

### Issues

- [ECOMMERCE-6196](https://jira.tools.weblinc.com/browse/ECOMMERCE-6196)

### Pull Requests

- [3503](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3503/overview)

### Commits

- [141871a0cb096079b00b69befeddefbccb78b87f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/141871a0cb096079b00b69befeddefbccb78b87f)


## Autocomplete Product by ID and Variant SKUs in Admin Jump To Search

This regression was introduced in v3.2.0 when the product's ID from the
`#search_text` was removed in order to improve matching. That field is
full-text analyzed, and was causing incorrect matches to occur when
performing an admin search, but as a result of its removal, the "jump
to" autocomplete would no longer match on product ID or SKUs. These data
points have been added into the `#jump_to_search_text` field, which is
*not* analyzed as fulltext, so that products can be matched by ID or
SKUs in the jump-to autocomplete.

### Issues

- [ECOMMERCE-6187](https://jira.tools.weblinc.com/browse/ECOMMERCE-6187)

### Pull Requests

- [3509](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3509)

### Commits

- [b0e3d7db906dcfc89487d1856c2d31c78a1b2b7f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b0e3d7db906dcfc89487d1856c2d31c78a1b2b7f)


## Assign Dragonfly Attributes in Data File Imports

When importing catalog products with embedded image URLs, e.g. with the
header `images_image_url`, the image could not be added because the
attribute was not being sensed as a field on the model.  Now, attributes
that start with any `dragonfly_accessor` field names (such as "image")
are assigned to the model explicitly, in order to go through the right
procedures that Dragonfly (and the rest of our app) expects.

### Issues

- [ECOMMERCE-6164](https://jira.tools.weblinc.com/browse/ECOMMERCE-6164)

### Pull Requests

- [3496](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3496/overview)

### Commits

- [9cd90783fdd6ffe21a0146fc085ec042976a0b6b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9cd90783fdd6ffe21a0146fc085ec042976a0b6b)
- [6b59747fbb50ab33a61c61d98efbc98d52701df9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6b59747fbb50ab33a61c61d98efbc98d52701df9)


## Use Asset Host From ENV Variable

To ease configuring an application when it is hosted in production,
Workarea now reads the `Rails.configuration.asset_host` configuration
from a `$WORKAREA_ASSET_HOST` environment variable if it's present. This
allows the infrastructure/hosting team to define a CDN URL without
needing intervention by an implementation team.

### Issues

- [ECOMMERCE-6188](https://jira.tools.weblinc.com/browse/ECOMMERCE-6188)

### Pull Requests

- [3493](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3493/overview)

### Commits

- [15b7a2ad6e0d01ca6bc98facb87ac323f81c275b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/15b7a2ad6e0d01ca6bc98facb87ac323f81c275b)


## Fix target="_blank" Omission from Links When Content is Edited

Adjusts **wysihtml5** to use the correct method for preserving link
targets. This was previously called `preserve:`, but the reference was
never adjusted when upgrading the library in v3. It has been adjusted to
`any`, which is the new syntax for doing the same thing.

Solved by **Kristin Henson**.

### Issues

- [ECOMMERCE-6198](https://jira.tools.weblinc.com/browse/ECOMMERCE-6198)

### Pull Requests

- [3507](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3507/overview)

### Commits

- [57bb3478d52154fe784193c73f9dcd4dcd6c447c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/57bb3478d52154fe784193c73f9dcd4dcd6c447c)


## Fix Issue with Rack::Attack Throttle on Forgot Password Attempts 

Requests to the Forgot Password page, now protected with `Rack::Attack`,
were being blocked on the first try for everyone. This was due to
inconsistent names for the block argument request handler, `req` and
`request`. The out-of-box `Rack::Attack` configuration now uses
`request` for the block argument every time, improving consistency and
readability.

### Issues

- [ECOMMERCE-6229](https://jira.tools.weblinc.com/browse/ECOMMERCE-6229)

### Pull Requests

- [3516](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3516/overview)

### Commits

- [0b65053e8c920f65fb36fd49d8d30da84569c459](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0b65053e8c920f65fb36fd49d8d30da84569c459)


## Prevent Unexpected Behavior in Drawers Caused By Optional Fields

Event propagation was causing unexpected behaviour with optional fields
within drawers, causing the drawer to close when the prompt is removed.
Preventing propagation allows the `optionalFields` module to work in the
context of a drawer.

### Issues

- [ECOMMERCE-6228](https://jira.tools.weblinc.com/browse/ECOMMERCE-6228)

### Pull Requests

- [3515](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3515/overview)

### Commits

- [e9b32282aba01c7c9dc6869c5501cee2ffbac616](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e9b32282aba01c7c9dc6869c5501cee2ffbac616)


