---
title: Workarea 3.5.16
excerpt: Patch release notes for Workarea 3.5.16.
---

# Workarea 3.5.16

Patch release notes for Workarea 3.5.16.

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

## Changes to support package product kits

This adds some minor improvements like a few extra methods and append points in
order to support our upcoming release of the `workarea-product-bundles`.

### Pull Requests

- [436](https://github.com/workarea-commerce/workarea/pull/436)

## Add JS module to allow inserting remote requests onto the page

Supports new `workarea-product-bundles` plugin.

### Pull Requests

- [472](https://github.com/workarea-commerce/workarea/pull/472)

## Fix race condition when merging user metrics

### Pull Requests

- [465](https://github.com/workarea-commerce/workarea/pull/465)

## Fix `Hash#[]` access on administrable options

Accessing administrable options on `Workarea.config` can produce
unexpected results if you don't use the traditional method accessor
syntax. For example, an admin field like this:

```ruby
Workarea::Configuration.define_fields do
  field :my_admin_setting, type: :string, default: 'default value'
end
```

...will only be available at `Workarea.config.my_admin_setting`:

```ruby
Workarea.config.my_admin_setting # => "default value"
Workarea.config[:my_admin_setting] # => nil
```

To resolve this, the code for fetching a key's value from the database
has been moved out of `#method_missing` and into an override of `#[]`.
Since the OrderedOptions superclass already overrides to call
`#[]`, we can safely move this code and still maintain all functionality.

- [467](https://github.com/workarea-commerce/workarea/pull/467)

