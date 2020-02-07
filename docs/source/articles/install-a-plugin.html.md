---
title: Install a Plugin
created_at: 2020/02/04
excerpt: A quick overview of how to install both open-source and proprietary Workarea plugins.
---

# Install a Plugin

Workarea plugins are distributed using [RubyGems](https://rubygems.org), the Ruby package management system. They are packaged as `.gem` files, and are managed using the [Bundler](https://bundler.io) utility. This guide is a quick overview of how to install a Workarea plugin.

Most of the time, Workarea plugins can be installed just like any other gem, either by running this command in your shell:

```bash
$ bundle add workarea-gift_cards
```

Or, by adding a new line to Gemfile:

```ruby
gem 'workarea-gift_cards'
```

However, if you're using a plugin included in [Workarea Commerce Cloud](https://www.workarea.com/pages/commerce-cloud), you'll need to configure Bundler to pull from the private gem server. To do this, obtain credentials from Workarea using [the support form](https://support.workarea.com), then configure it in your shell by setting the `BUNDLE_GEMS__WORKAREA__COM` environment variable:

```bash
$ export BUNDLE_GEMS__WORKAREA__COM="yourusername:yourpassword"
```

It's probably best to set this in your **~/.bash_profile** or **~/.zshrc** so it's always configured in your shell.

Then, in your `Gemfile`, make sure to surround private plugins in the `source` block for the private gemserver:

```ruby
source 'https://gems.workarea.com' do
  gem 'workarea-multi_site'
end
```

Make sure to read about our plugins at https://plugins.workarea.com, the README documentation for each plugin contains a wealth of information on how to install, configure, and use many of our integrations and proprietary features.
