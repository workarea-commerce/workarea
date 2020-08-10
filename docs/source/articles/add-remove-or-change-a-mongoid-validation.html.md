---
title: Add, Remove, or Change a Mongoid Validation
created_at: 2019/03/06
excerpt: Sometimes with validations, less is more. Learn how to manipulate the out-of-box validations that don't jive with your application's data.
---

# Add, Remove, or Change a Mongoid Validation

In the Workarea codebase, you may encounter **model validations** in
Mongoid model classes, since they are responsible for persisting data
that can be handled by the application into the database. Validations
are commonly used to clean user-generated data (for example, data that
is entered on a website, such as a user's email address or password),
and ensure that the kind of data that's going into the database is valid
and can be "handled" by the application at a later date. To accomplish
this, Workarea uses `ActiveModel::Validations`, which is the same engine
powering [ActiveRecord Validations][], and indeed most of Workarea's
validation logic works exactly like its out-of-box Rails counterpart.

Validations are typically used for data entered by the user on a public
interface. For example, an `Order::Item` has validations on the quantity
and SKU of the item, but `Fulfillment::Item` will not, because `Fulfillment`
records are typically created automatically in the backend when an Order
is being sent over to the OMS or Fulfillment system. As a result, you may
see less validations in a Workarea application than you would in a
conventional Rails application. This is intentional, as the Workarea platform
(and, by proxy, the web application running Workarea) is designed to handle
missing or invalid/incorrect data at the UI level, meaning that less-than-perfect
data can be inserted into MongoDB, and the application won't throw fatal
errors when attempting to render or deal with that data. For this reason, when adding
new fields to Workarea models, it's best to [configure default values][]
instead of validating data and producing an error when it's not valid. You
should only validate data if it's meant for storefront-facing user input,
and even then, your code should be written defensively to deal with the data
when it's not 100% valid.

## Change an Existing Validation

The most common case is to change (or override) an existing validation based on a
special case wherein your data doesn't necessarily match up with the
validation rules imposed by base.

Validations are loaded from dependencies first, then read from
top-to-bottom in the class definition. What this means for you is that
a validation defined in the core platform can be modified by adding a
decorator with a new `validates` or `validate` entry in the `decorated
{ }` block, since this will be processed after the validations on the
base class have been defined. For example, if you want to prevent
validating a user's password if they are signed in with OAuth, you
might decorate the `User` model like so:

```ruby
module Workarea
  decorate User do
    decorated do
      validates :password, password: { strength: :required_password_strength }, unless: :is_omniauthed?
    end
  end
end
```

When decorating validations, always remember to copy the whole
validation line from Workarea (or one of its plugins), as `validates` /
`validate` lines for the same key will completely overwrite the original
validation. This is evidenced by the fact that the line...

```ruby
validates :password, unless: :is_omniauthed?
```

...will not do anything, the condition must be expressed as part of the
rewritten validation.

## Add a New Validation

Adding new validations is rare for model data. As described above, validating
data and producing an error for the user to deal with is a less desirable
experience than allowing any user data to be entered, and cleaning said data
in the background, without the need for involvement by a customer or admin.

That said, Mongoid already includes the `ActiveModel::Validations` module, which
means you have the same capabilities as you would have access to in Rails'
out-of-box [ActiveRecord Validations][]. If you're looking for detailed
information on the various out-of-box validations you might need, check out the
aforementioned Rails guide.

For example, if your payment provider requires phone numbers on the billing
address, you might write a decoration to add a validation for `:phone_number`
on the `Payment::Address` model:

```ruby
module Workarea
  decorate Payment::Address do
    decorated do
      validates :phone_number, presence: true
    end
  end
end
```

## Remove an Existing Validation

Removing validations is a bit trickier. You essentially have to remove
_all_ validations, then add back the ones that you need in the object.
Fortunately, Workarea makes that a lot easier for you with our
handy-dandy [ActiveModel::Unvalidate][] gem!

This library can be added into your project in Gemfile:

```ruby
gem 'active_model-unvalidate'
```

After running `bundle` to install it, you can use the `unvalidates` and
`unvalidate` macro methods in the models for which you wish to remove
validations. For example, if you no longer want to validate the existence
of a `:country` because you don't sell to other countries, you could
decorate `Workarea::Address` like so:

```ruby
module Workarea
  decorate Payment::Address do
    decorated do
      unvalidates :country, :presence
    end
  end
end
```

The `unvalidates` macro takes two arguments, the name of the field being
unvalidated, and the "type" of validation(s) to remove validation for
(in this case, `:presence`). Use `unvalidates` for removing validations
created with the Rails macro `validates`. For custom method-based validations
that are configured using `validate`, use the `unvalidate` macro, like so:

```ruby
module Workarea
  decorate Payment::Address do
    decorated do
      unvalidate :postal_code_presence
    end
  end
end
```

[ActiveRecord Validations]: https://guides.rubyonrails.org/active_record_validations.html
[ActiveModel::Unvalidate]: https://github.com/weblinc/active_model-unvalidate
[configure default values]: https://docs.mongodb.com/mongoid/master/tutorials/mongoid-documents/#defaults
