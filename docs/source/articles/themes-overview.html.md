---
title: Themes Overview
excerpt: A Workarea theme is a specialized type of Workarea plugin. Themes specifically customize the appearance of the Workarea platform.
---

# Themes Overview

A Workarea theme is a specialized type of Workarea plugin. Themes specifically
customize the appearance of the Workarea platform. Themes allow for re-use of
storefront code, helping to jump-start front-end work for an implementation. A
theme may be used as a starting point for front-end development, or as a
complete storefront UI.

## Installing a theme in a Workarea application

Installing a theme in a Workarea application is like installing any other plugin.
Add the theme's gem to your application's gemfile:

```ruby
  gem 'workarea-your_theme_name'
```

Then run `bundle install` and restart your application.

Some themes may need extra configuration. Check the README.md for the theme you
are using to see if any further configuration is necessary.

## Configuring a theme

All themes include a `config/initializer/theme.rb` file, which provides options
for configuration within the Workarea application.
Typically themes allow configuration for color schemes and font families.

An example of a Workarea theme configuration file:

```ruby
Workarea.configure do |config|
  config.theme = {
    color_schemes: ["one", "workarea", "midnight"],
    color_scheme: "one",
    font_stacks: {
      roboto: '"Roboto", "HelveticaNeue", "Helvetica Neue", sans-serif',
      lora: '"Lora", "Times New Roman", "Georgia", serif',
      hind: '"Hind", Helvetica, Arial, sans-serif',
      source_serif_pro: '"Source Serif Pro", "Times New Roman", Georgia, serif',
      muli: '"Muli", Helvetica, Arial, sans-serif',
      playfair_display: '"Playfair Display", "Times New Roman", Georgia, serif'
    },
    primary_font_family: "roboto",
    secondary_font_family: "lora"
  }
end
```

## Approaches to using a theme

There are 2 ways to use a Workarea theme.

1. Installing the theme as a gem in your application, similar to other plugins.
2. As a development tool by running the `starter_store` generator to import a
    theme's files to your application.

### Gem vs. Development tool approach

Using a Workarea theme as a gem is the quickest way to apply a theme to a Workarea
application. The benefit of running a theme as a gem is getting bug-fixes and upgrades
from the theme in patch releases.

Using a theme as a development tool is an alternative way to use a Workarea theme.
Rather than running the theme as a plugin; all of the theme's files, dependencies,
and configurations are copied in to your application. This is done by running the
`starter_store` generator from your host application. This approach allows greater
flexibility in development, however it removes you from the direct upgrade path
for the theme. This means you will need to use the Workarea upgrade tool to apply
patches and upgrades as they are released for the theme.

The development tool approach is most useful if:

- You plan to customize the application heavily using the theme as a starting point.
- You need to remove a dependency of the theme.
  - For example a theme may depend on workarea-reviews, but your implementation uses
    a 3rd party review system. The only way to use a theme and remove one of its
    dependencies is by installing the theme using the `starter_store` generator.

### Using a theme as a development tool

To prepare for installing a theme as a starter store you must add the theme to
your application gemfile and run `db:seed`. Once you have the theme running in your
application run the `starter_store` generator

```bash
bundle exec rails g workarea:starter_store
```

During the execution of this generator you will be prompted to make decisions
re. overriding existing files in your application. Use the Ynaqdh interface
to make decisions on a per-file basis. I have found that 'n' is typically the
preferable choice, with the exception of locales/en.yml

After the generator is run you should:

1. Run bundle install.
2. Confirm that your application is running and is styled as expected.
3. Remove the now commented-out theme from your gemfile.
4. Run the full test suite and ensure nothing is failing.
5. Commit your changes and open a pull-request.

#### Appended files

Appends, and append removals will still be handled via the imported appends.rb
initializer. It is recommended that you review the contents of this file and
update your host application where appropriate to include these appended files
as normal, removing them from appends.rb. This is especially advisable for Sass
and JS assets which can easily be added to your application manifests.

## Upgrading a themed application

If you have installed your theme using the `starter_store` generator the upgrade
path is the same as any other application. The 
_Workarea Upgrade_ tool
will be very helpful when upgrading your application.

If your application is using a theme as a plugin you should follow these steps:

1. Check whether your theme has already been upgraded for compatibility with the
    version of Workarea you are upgrading to.
    - If the theme is not yet upgraded contact the theme developer and find out
    when that will be complete. It is not recommended to upgrade your application
    until the theme is ready.
2. Upgrade Workarea and all other plugins first, use the Workarea upgrade tool to
    create a diff and make the necessary changes in your application.
3. Update the theme's version in your gemfile to use the latest version that is
    compatible with your new Workarea version.
4. Run the upgrade tool against your theme to see if there are further changes
    that need to be made to files that have been overridden in your application.

Once all necessary changes highlighted in the diff have been made, tests are
passing, and your PR has been accepted, your application is upgraded and should
be sent to QA for testing. Drink a beer, you've earned it!

## Multisite support for themes

Multisite applications are able to use Workarea themes without many changes to
the normal multi-site development workflow.

Configuration options set in theme.rb should be applied to each instance of
`Workarea::Site`, this allows you to easily apply different color schemes and
fonts to each site with minimal effort. Skinning a new site for a themed
multi-site app should be relatively simple!

It is not possible to use more than 1 theme per application. This means you cannot
use different themes for different sites within a multi-site application. All sites
must be based on the same theme, but each can customize away from the theme as necessary.
Users of _Workarea Multi Site_ should refer to its readme
for more information about developing multi-site applications.
