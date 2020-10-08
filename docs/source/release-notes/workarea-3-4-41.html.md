---
title: Workarea 3.4.41
excerpt: Patch release notes for Workarea 3.4.41.
---

# Workarea 3.4.41

Patch release notes for Workarea 3.4.41

## Redirect back to the previous page after stopping impersonation

Previously we redirected to the user's show page, which can be pretty
disorienting.

### Pull Requests

- [514](https://github.com/workarea-commerce/workarea/pull/514)

## Fix safe navigation method calls in navigation menu partial

This would raise if the menu content is nil.

### Pull Requests

- [528](https://github.com/workarea-commerce/workarea/pull/528)

## Improve clarity of discount verbiage

This hopes to address some recent confusion around how the discount
works.

### Pull Requests

- [518](https://github.com/workarea-commerce/workarea/pull/518)

## Rename Admin::ProductViewModel#options to avoid conflict with normal options method

### Pull Requests

- [530](https://github.com/workarea-commerce/workarea/pull/530)
