---
title: Workarea 3.5.11
excerpt: Patch release notes for Workarea 3.5.11.
---

# Workarea 3.5.11

Patch release notes for Workarea 3.5.11.

## Rename index to avoid conflicts in upgrade

We changed the abandoned orders index so trying to create indexes after
upgrading will cause a conflict due to different indexes with the same
name. This renames the index to fix that.

### Commits

- [cf97e96](https://github.com/workarea-commerce/workarea/commit/cf97e96172aa5e031c6592bfe0d5d46e9b4c78bd)

## Correct/clarify Dragonfly configuration warning

This warning's language was based on outdated functionality, this updates it
to reflect what happens currently.

### Commits

- [16589e9](https://github.com/workarea-commerce/workarea/commit/16589e964f6ac48753172a98288aea4223a525b6)

## Fix comment subscription messaging

The messaging was incorrect. Also improves UI to move the secondary action of
subscribing/unsubscribing out of the main area.

### Pull Requests

- [428](https://github.com/workarea-commerce/workarea/pull/428)

## Remove extra order ID cookie

No need for the extra cookie if the order isn't persisted. Note this
doesn't actually affect functionality.

### Pull Requests

- [425](https://github.com/workarea-commerce/workarea/pull/425)
