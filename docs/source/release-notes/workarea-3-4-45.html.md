---
title: Workarea 3.4.45
excerpt: Patch release notes for Workarea 3.4.45.
---

# Workarea 3.4.45

Patch release notes for Workarea 3.4.45

## Improve image URL detection for dialog_buttons

This only worked if the URL had only one dot (before the file extension)
and no query parameters. Run it through the URL parser to provide more
robust handling.

Thanks to Jonathan Mast for contributing this.

### Pull Requests

- [580](https://github.com/workarea-commerce/workarea/pull/580)

## Bump redcarpet version to fix security warnings

Redcarpet released a security fix, so ensure using a version with that fix.

Redcarpet is only used to render help pages in the admin, so the vulnerability
in Workarea is minimal.

### Pull Requests

- [584](https://github.com/workarea-commerce/workarea/pull/584)

## Improve password performance when running tests

Lowering the bcrypt cost lowers the time required to encrypt a password, at the
cost of increasing the speed at which an attacker can try to crack the password.
This is an acceptable tradeoff for improving performance of running tests. This
shaves about 5 minutes off of the admin tests.

Hat tip to Jeff Yucis for discovery.

### Pull Requests

- [586](https://github.com/workarea-commerce/workarea/pull/586)
