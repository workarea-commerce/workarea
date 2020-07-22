---
title: Workarea 3.4.37
excerpt: Patch release notes for Workarea 3.4.37.
---

# Workarea 3.4.37

Patch release notes for Workarea 3.4.37

## Improve content area select UX

Remove the current content name and replace it with a static label
indicating what the `<select>` menu to the right of it is selecting,
which is the current content area. This UI only displays when there are
multiple areas for a given `Content`.

### Pull Requests

- [463](https://github.com/workarea-commerce/workarea/pull/463)

## Setup PlaceOrderIntegrationTest in a method

Currently, decorating the PlaceOrderIntegrationTest to edit the way its
set up (such as when adding an additional step) is impossible, you have
to basically copy everything out of the `setup` block and duplicate it
in your tests. Setup blocks should be methods anyway, so convert this to
a method and allow it to be decorated in host apps.

### Pull Requests

- [466](https://github.com/workarea-commerce/workarea/pull/466)

## Configure sliced credit card attributes

To prevent an unnecessary decoration of the `Workarea::Payment` class,
the attributes sliced out of the Hash given to `Workarea::Payment#set_credit_card`
is now configurable in initializers. This same set of attributes is also
used in the `Users::CreditCardsController`, so the configuration will be
reused when users are attempting to add a new credit card to their
account.

### Pull Requests

- [464](https://github.com/workarea-commerce/workarea/pull/464)
