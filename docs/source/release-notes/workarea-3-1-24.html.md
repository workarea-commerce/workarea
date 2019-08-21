---
title: Workarea 3.1.24
excerpt: Patch release notes for Workarea 3.1.24.
---

# Workarea 3.1.24

Patch release notes for Workarea 3.1.24.

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


