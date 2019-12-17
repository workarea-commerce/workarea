---
title: Create a Theme
excerpt: Developing your own Workarea theme is similar in many ways to developing a plugin.
---

# Create a theme

Developing your own Workarea theme is similar in many ways to developing a plugin.
Some additional tools are provided to expedite theme development and make it easy
to customize the storefront.

## Create a new theme

To create a Workarea theme use the _rails plugin new_ command with the Workarea
theme template which is part of the workarea-theme engine.

``` bash
rails plugin new /path/to/new-theme --full -m /path/to/theme-template.rb --skip-spring --skip-active-record --skip-action-cable
```

This template can be found in the [workarea-theme repository](https://github.com/workarea-commerce/workarea-theme) at [https://github.com/workarea-commerce/workarea-theme/docs/guides/source/theme_template.rb](https://github.com/workarea-commerce/workarea-theme/docs/guides/source/theme_template.rb).

After creating the theme, edit the gemspec file to set relevant metadata.

### Theme development workflow

Once you've created your theme engine and edited the gemspec you can start
developing your theme. Theme development relies heavily on overriding views,
stylesheets, and javascripts from Workarea Storefront. To jump-start your theme
development run the theme override generator to override all of the files you're
likely to need in your theme.

To use the theme override generator run

```bash
bin/rails generate workarea:theme_override
```

This will override every view file, along with most Sass and JS files from
workarea-storefront. The generator also commits these overrides and stores the
commit SHA in `lib/workarea/theme/override_commit`. This file is used by the
Workarea `theme_cleanup` rake task and should not be deleted.

Having overridden most of the files you will need to develop your theme, you are
now ready to start implementing your designs. Should you need to override other
files from Storefront, or another plugin, you should use the [Workarea override
generator](/articles/overriding.html).

Once you have implemented your theme you should run the Workarea `theme_cleanup` rake
task. This will remove any files in `/app` that have not changed since you ran the
theme_override generator. To execute `theme_cleanup` run:

```bash
bin/rails workarea:theme_cleanup
```

Be sure to check the files that have been removed, and test that your theme runs
and looks correct before committing this change.

Once your theme is cleaned up you're done, congratulations! Now head over to the
[Workarea plugin documentation](/articles/plugins-overview.html)
to learn how to release your theme for use!

### Theme requirements

In order for your theme to be registered correctly within the host application it
must depend on workarea-theme and have the following include in your plugin's
engine.rb file:

```ruby
  include Workarea::Theme
```

This is necessary for the `starter_store` generator to work.

In addition your theme must:

- Include a theme.rb initializer.
- Allow the host application to configure the color scheme.
- Allow the host application to configure fonts.

The theme_template will take care of setting these things up for you, be sure to
follow the instructions for creating a new Workarea theme to ensure your theme is
configured properly.

It is recommended that your theme's README include the following information:

- Optimal image sizes.
- Compatible Workarea plugins and dependencies.
- Browser support, preferably supplemented with a browserlist file in the theme's
    root directory.
- Instructions for any additional configuration or features specific to your theme.

### Theme plugin dependencies

Your theme may include dependencies on other Workarea plugins. This allows you to
ship a theme with support for popular functionality out of the box, and to benefit
from pluginized UI components and functionality.

To add support for another plugin, first add it to your theme's gemspec like this:

```ruby
s.add_dependency 'workarea-swatches', '1.0.0'
```

Next you will need to override the relevant files from the plugin to your theme.
You should use the [workarea override generator](/articles/overriding.html) to do this.
Once you have overridden all of the necessary files you can adjust styles, markup,
and functionality as required to meet your requirements.

_Note:_ dependencies of a theme cannot be removed when using
the theme as a gem, so it is best to keep dependencies to a minimum. The only way
to remove a theme's dependencies within a host application is to use the `starter_store`
generator, then remove the unwanted dependency from the application gemfile along
with any related app files (views, styles etc.).

### Maintaining your theme

A theme is like a baby, you spend a while making one, then you have a lifetime
of taking care of it.

Maintaining your theme means fixing bugs as they come in, and keeping your theme
up to date with the latest versions of Workarea. If your theme is not kept up to
date you will cause great pain and sadness for developers that have used your theme
in their applications. You might prevent them from being able to take upgrades.

#### Upgrading for minor-version compatibility

Upgrading your theme for compatibility with Workarea is important. At a minimum
all themes should be upgraded with the latest changes in each new minor version
of Workarea.

The Workarea upgrade tool will be very useful and allow you to
upgrade your theme in the same way you upgrade a Workarea application.
