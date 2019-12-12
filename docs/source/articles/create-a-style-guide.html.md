---
title: Create a Style Guide
created_at: 2018/07/31
excerpt: To add a style guide, use the style guide generator.
---

# Create a Style Guide

To add a [style guide](/articles/style-guides.html), use the style guide generator.

Run the generator without arguments to view help:

```
cd path/to/your_app
bin/rails g workarea:style_guide
```

Your results will look something like this:

```
Usage:
  rails generate workarea:style_guide ENGINE SECTION NAME [options]

Runtime options:
  -f, [--force] # Overwrite files that already exist
  -p, [--pretend], [--no-pretend] # Run but do not make any changes
  -q, [--quiet], [--no-quiet] # Suppress status output
  -s, [--skip], [--no-skip] # Skip files that already exist

Options:
  ENGINE is either:
    - admin
    - storefront

  SECTION is an existing section, the workarea gem offers these sections out of the box:
    - settings
    - base
    - typography
    - objects
    - components
    - trumps

  NAME is the name of your partial, separated with dashes:
    - button
    - button--large
    - table--prices

Description:
  Creates a new Style Guide entry for your application.

Examples:
  rails g workarea:style_guide storefront components button
  rails g workarea:style_guide admin components button--large
```

## Style Guide Partial Paths

The style guide generator creates a new style guide partial at the correct path in your app (corresponding to the arguments you pass it).

For example, the partial for an Admin component goes here:

```
your_app/views/workarea/admin/style_guides/components/_foo.html.haml
```

The contents of that partial are viewable in the browser at the following paths:

```
/admin/style_guides
/admin/style_guides/components/foo
```

