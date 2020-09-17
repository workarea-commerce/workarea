---
title: Configuration Fields
created_at: 2019/07/02
excerpt: Define custom configuration fields that can be managed by admin users.
---

# Configuration Fields

As of Workarea v3.5, the admin provides a number of configuration options that can be managed by an admin user. Configuration fields allow for greater control over an application without relying on developer intervention, reducing the reliance on code changes to update easily changed behaviors.

## Setup

Workarea provides a number of configuration fields out of the box for an admin to control, but it's likely that integrations with third-party services or customizations may benefit from adding new fields. To add fields, create an initializer in your application or plugin like the following:

```ruby
Workarea::Configuration.define_fields do
  field 'Payment Processor Retry Count',
    type: :integer,
    default: 3

  field 'Payment Authorization Prefix',
    type: :string,
    default: 'MYSITE.COM'
end
```

Fields defined this way will automatically become available within the admin to change. The value of that field will be available through its `id`, which is a systemized version of the field name.

```ruby
Workarea.config.payment_processor_retry_count
Workarea.config.payment_authorization_prefix
```

If you need the field ID to be something specific, you can define the ID explicity in the field definition.

```ruby
Workarea::Configuration.define_fields do
  field 'Payment Processor Retry Count',
    id: :my_specific_retry_count,
    type: :integer,
    default: 3
end
```

Fields can also be grouped into `fieldsets`. Which, by default, will prefix the ID of each field within it and group the fields visually in the admin. This can be useful if you are developing a plugin and want to minimize the chance of field conflicts with other plugins, or just want visually separate the fields within the UI.

```ruby
Workarea::Configuration.define_fields do
  fieldset 'Awesome Payments' do
    field 'Retry Count',
      type: :integer,
      default: 3

    field 'Authorization Prefix',
      type: :string,
      default: 'MYSITE.COM'
  end
end

Workarea.config.awesome_payments_retry_count #=> 3
Workarea.config.awesome_payments_authorization_prefix #=> 'MYSITE.COM'
```

If you want to group your fields without the prefix, you can set the `namespace` option of the fieldset.

```ruby
Workarea::Configuration.define_fields do
  fieldset 'Awesome Payments', namespace: false do
    # ...
  end
end
```

## Overriding and Modification

A project may want to override or modify an existing field or fielset. Workarea provides flexibility for defining how you want to change the configuration fields.

For fieldsets, you can optionally provide an `override: true` option, which will completely replace the fieldset and all fields defined within it. If the override option is not defined, any new fields defined within it will be added to the collection of fields already defined elsewhere for that fieldset.

For fields, any redefining of a field will merge all options defined into the existing field. Notably, this excludes `type`, as changing the type of an existing field is likely to cause problems for existing code expecting the configuration value to be of a certain type.

## Types

Configuration fields can be any of the following types:

- `:string`
- `:symbol`
- `:integer`
- `:float`
- `:boolean`
- `:array`
- `:hash`
- `:duration`

Of note, `duration` allows you to define a field for periods of time like `3.days`.

## Options

When defining a configuration field, there are a number of options you can provide.

- `required`

  Whether or not the field is required, defaults to `false`. The admin UI will prevent user's from submitting blank field values for required fields. If values are submitted in some other way, blank values for a required field will be set to the field's default value.

- `default`

  The value that will be returned when there isn't a specified value or it is blank. Must match the type defined for the field.

- `description` (`String`)

  A brief summary of what the field is used for. This is displayed in the admin to help a user better understand how the field affects the application.

- `encrypted` (`Boolean`)

  This allows you to encrypt fields that may contain sensitive information. Workarea will seamlessly encrypt the value before saving it to the database, and decrypt the value after reading it back out. Workarea uses the [mongoid-encrypted](https://github.com/workarea-commerce/mongoid-encrypted) gem to encrypt data through built-in Rails encryption.

- `id` (`Symbol`)

  Allows you to define a custom ID rather than letting Workarea infer an ID from the name provided for the field.

- `type` (`Symbol`, required)

  The value's type. See available types above.

- `values` (`Array`)

  Provide a strict set of values that a field can contain. When `values` are provided, the admin UI will present them as a dropdown for that field, passing `values` directly into `options_for_select`

- `values_type` (`Symbol`)

  For fields of type `hash` only, this allows you to define the type for values stored within the hash. Allowed values are the same as `type`. By default all values are stored as string.

## Static config priority

It is important to note that any configuration field that shares an ID with an existing configuration option defined via `Workarea.configure` will not override the static value. To use the defined field's value, the static configuration should be removed.

Within the admin configuration page, there is a red `!` indicator along with a tooltip next to any field that is being overidden by a static configuration value.

![Static configuration override warning](/images/static-config-indicator.png)
