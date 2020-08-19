---
title: Workarea 3.4.38
excerpt: Patch release notes for Workarea 3.4.38.
---

# Workarea 3.4.38

Patch release notes for Workarea 3.4.38

## Allow inquiry subjects to be localized

Locale keys at `workarea.inquiry.subjects` can be used to localize the subjects
for inquiries.

### Pull Requests

- [479](https://github.com/workarea-commerce/workarea/pull/479)

## Bump Chartkick to fix bundler audit warning

The vulnerability won't affect Workarea in use, but it'll be easier to fix
builds doing this.

### Pull Requests

- [483](https://github.com/workarea-commerce/workarea/pull/483)

## Update `Checkout#update` to return successfulness

For APIs and other consumers of the Checkout model, return a boolean
response from the `#update` method to signify whether the operation
succeeded or failed. This response is used directly in the API to return
an `:unprocessable_entity` response code when an update operation fails.

### Pull Requests

- [481](https://github.com/workarea-commerce/workarea/pull/481)

## Remove port from host configuration in installer

Ports aren't part of hosts, this causes problems when the value is used
like a true host.

This also fixes mailer links with missing ports as a result of this change.

### Pull Requests

- [484](https://github.com/workarea-commerce/workarea/pull/484)
