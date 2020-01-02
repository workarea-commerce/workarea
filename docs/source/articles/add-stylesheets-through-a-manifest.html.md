---
title: Add Stylesheets through a Manifest
created_at: 2018/07/31
excerpt: Stylesheet manifests are the preferred solution for adding stylesheets to and removing stylesheets from a Workarea application. The Workarea Admin and Storefront each include a single manifest named 'application', which is introduced in the Stylesheet
---

# Add Stylesheets through a Manifest

Stylesheet manifests are the preferred solution for adding stylesheets to and removing stylesheets from a Workarea application. The Workarea Admin and Storefront each include a single manifest named 'application', which is introduced in the [Stylesheets overview](/articles/stylesheets-overview.html). This guide covers the manifest in detail.

If you're new to Ruby on Rails and the concept of asset manifests, check out the following guides to get you started.

- [Rails Asset Manifests](/articles/rails-asset-manifests.html)
- [Rails Asset View Helpers](/articles/rails-asset-view-helpers.html)

## Customizing a Manifest

To add and remove stylesheets through a manifest, you need to have a copy of the manifest in your app. If you're working in a new application, start by [overriding](/articles/overriding.html) the manifest file you want to customize. You can override a manifest in the same way as any other stylesheet. When overriding, note that the manifest file ends with the extensions `.scss.erb`. I'll explain the reason for that in the following sections which look at the application manifest in detail.

Now that you have a copy of the manifest in your app, edit it to taste. The follow sections explain how Workarea manifests differ from default Rails manifests and what is included out of the box.

## Application Manifest

The application manifest contains a mixture of Sass `@import` statements and ERB blocks, hence the need for the `.erb` file extension mentioned above. The manifest is designed as as such to support the Workarea plugin system and to load some assets conditionally, as you'll see shortly. "Zoomed out", it looks something like this:

workarea-storefront/app/assets/stylesheets/workarea/storefront/application.scss.erb:

```
<%= "@import 'workarea/core/feature_test_helper';" if Rails.env.test? %>
<%= append_stylesheets('storefront.feature_test_helpers') %>

<%= append_stylesheets('storefront.theme_config') %>

@import // settings
<%= append_stylesheets('storefront.settings') %>

@import // tools
<%= append_stylesheets('storefront.tools') %>

@import // generic
<%= append_stylesheets('storefront.generic') %>

@import // base
<%= append_stylesheets('storefront.base') %>

@import // objects
<%= append_stylesheets('storefront.objects') %>

@import // typography
<%= append_stylesheets('storefront.typography') %>

@import // dependencies
<%= append_stylesheets('storefront.dependencies') %>

@import // components
<%= append_stylesheets('storefront.components') %>

<%= append_stylesheets('storefront.theme') %>

@import // trumps
<%= append_stylesheets('storefront.trumps') %>
```

Now let's zoom in on each of the manifest sections.

### Feature Test Helper

```
<%= "@import 'workarea/core/feature_test_helper';" if Rails.env.test? %>
<%= append_stylesheets('storefront.feature_test_helpers') %>
```

The [feature test helper](/articles/feature-spec-helper-stylesheet.html) includes styles that make automated testing easier. Plugins are also able to add their own feature test helpers as needed.

### Theme Config

The [Theme Config Layer](/articles/css-architectural-overview.html#the-theme-config-layer) is used by Theme Plugins to reset any Sass variable declared within the Storefront.

```
<%= append_stylesheets('storefront.theme_config') %>
```

### Settings

The [Settings Layer](/articles/css-architectural-overview.html#the-settings-layer) contains globally available Sass variables that any other layer may make use of.

```
@import 'workarea/storefront/settings/colors';
@import 'workarea/storefront/settings/typography';
@import 'workarea/storefront/settings/breakpoints';
@import 'workarea/storefront/settings/global';
@import 'workarea/storefront/settings/grid';
@import 'workarea/storefront/settings/z_indexes';
<%= append_stylesheets('storefront.settings') %>
```

### Tools

The [Tools Layer](/articles/css-architectural-overview.html#the-tools-layer) contains globally available, configurable Sass functions and mixins that any of the following layers may make use of.

```
@import 'workarea/storefront/tools/center';
@import 'workarea/storefront/tools/focus_ring';
@import 'workarea/storefront/tools/respond_to';
@import 'workarea/storefront/tools/svg';
<%= append_stylesheets('storefront.tools') %>
```

### Generic

The [Generic Layer](/articles/css-architectural-overview.html#the-generic-layer) contains the Normalize library, a Workarea-focused global Normalize reset file, and other top-level stylings.

```
@import 'normalize-rails';
@import 'workarea/storefront/generic/reset';
@import 'workarea/storefront/generic/box_sizing';
@import 'workarea/storefront/generic/fonts';
<%= append_stylesheets('storefront.generic') %>
```

### Base

The [Base Layer](/articles/css-architectural-overview.html#the-base-layer) contains basic element styling.

```
@import 'workarea/storefront/base/page';
@import 'workarea/storefront/base/images';
@import 'workarea/storefront/base/forms';
@import 'workarea/storefront/base/tables';
@import 'workarea/storefront/base/lists';
<%= append_stylesheets('storefront.base') %>
```

### Objects

The [Objects Layer](/articles/css-architectural-overview.html#the-objects-layer) contains reusable, design-free abstractions that help DRY up code found in the Components layer. There are a few specific reset-like abstractions here. They're used to reset specific element styling on an as-needed basis.

```
@import 'workarea/storefront/objects/inline_list';
@import 'workarea/storefront/objects/list_reset';
@import 'workarea/storefront/objects/text_field_reset';
@import 'workarea/storefront/objects/button_reset';
@import 'workarea/storefront/objects/content_wrapper';
@import 'workarea/storefront/objects/content_preview_visibility';
<%= append_stylesheets('storefront.objects') %>
```

### Typography

The [Typography Layer](/articles/css-architectural-overview.html#the-typography-layer) focuses on global typography throughout the application.

```
@import 'workarea/storefront/typography/align';
@import 'workarea/storefront/typography/headings';
@import 'workarea/storefront/typography/links';
@import 'workarea/storefront/typography/text';
<%= append_stylesheets('storefront.typography') %>
```

### Dependencies

The [Dependencies Layer](/articles/css-architectural-overview.html#the-dependenices-layer) allows Plugins to inject 3rd Party Library CSS into the application, if necessary.

```
@import 'avalanche';
@import 'jquery_ui/storefront/ui_autocomplete';
@import 'jquery_ui/storefront/ui_dialog';
@import 'jquery_ui/storefront/ui_helper_hidden_accessible';
@import 'jquery_ui/storefront/ui_menu';
@import 'jquery_ui/storefront/ui_state_focus';
@import 'jquery_ui/storefront/ui_widget_overlay';
<%= append_stylesheets('storefront.dependencies') %>
```

### Components

The [Components Layer](/articles/css-architectural-overview.html#the-components-layer) contains all of the main UI building block styling for the application.

```
@import 'workarea/storefront/components/button';
@import 'workarea/storefront/components/hero_content_block';
@import 'workarea/storefront/components/loading';
@import 'workarea/storefront/components/message';
@import 'workarea/storefront/components/mobile_nav';
@import 'workarea/storefront/components/primary_nav';
@import 'workarea/storefront/components/product_details';
@import 'workarea/storefront/components/page_header';
@import 'workarea/storefront/components/product_list';
@import 'workarea/storefront/components/product_summary';
@import 'workarea/storefront/components/button_property';
@import 'workarea/storefront/components/inline_form';
@import 'workarea/storefront/components/property';
@import 'workarea/storefront/components/value';
@import 'workarea/storefront/components/payment_icon';
@import 'workarea/storefront/components/table';
@import 'workarea/storefront/components/data_card';
@import 'workarea/storefront/components/style_guide';
@import 'workarea/storefront/components/breadcrumbs';
@import 'workarea/storefront/components/cart';
@import 'workarea/storefront/components/category_summary_content_block';
@import 'workarea/storefront/components/checkout_addresses';
@import 'workarea/storefront/components/checkout_payment';
@import 'workarea/storefront/components/checkout_shipping';
@import 'workarea/storefront/components/checkout_step_summary';
@import 'workarea/storefront/components/email_signup';
@import 'workarea/storefront/components/html_content_block';
@import 'workarea/storefront/components/order_help_menu';
@import 'workarea/storefront/components/order_summary';
@import 'workarea/storefront/components/page_content';
@import 'workarea/storefront/components/page_footer';
@import 'workarea/storefront/components/page_container';
@import 'workarea/storefront/components/page_messages';
@import 'workarea/storefront/components/personalized_recommendations_content_block';
@import 'workarea/storefront/components/product_detail_container';
@import 'workarea/storefront/components/product_prices';
@import 'workarea/storefront/components/recent_views';
@import 'workarea/storefront/components/result_filters';
@import 'workarea/storefront/components/text_content_block';
@import 'workarea/storefront/components/search_no_results';
@import 'workarea/storefront/components/secondary_nav';
@import 'workarea/storefront/components/text_box';
@import 'workarea/storefront/components/text_button';
@import 'workarea/storefront/components/video_content_block';
@import 'workarea/storefront/components/view';
@import 'workarea/storefront/components/checkout_progress';
@import 'workarea/storefront/components/search_results';
@import 'workarea/storefront/components/taxonomy_content_block';
@import 'workarea/storefront/components/image_group_content_block';
@import 'workarea/storefront/components/image_and_text_content_block';
@import 'workarea/storefront/components/video_and_text_content_block';
@import 'workarea/storefront/components/product_list_content_block';
@import 'workarea/storefront/components/image_content_block';
@import 'workarea/storefront/components/button_content_block';
@import 'workarea/storefront/components/quote_content_block';
@import 'workarea/storefront/components/divider_content_block';
@import 'workarea/storefront/components/social_networks_content_block';
@import 'workarea/storefront/components/mobile_filters';
@import 'workarea/storefront/components/admin_toolbar';
@import 'workarea/storefront/components/content_block';
@import 'workarea/storefront/components/pagination';
@import 'workarea/storefront/components/svg_icon';
<%= append_stylesheets('storefront.components') %>
```

### Theme

The [Theme Layer](/articles/css-architectural-overview.html#the-theme-layer) contains is used by Theme Plugins to override the CSS declared within the Components layer.

```
<%= append_stylesheets('storefront.theme') %>
```

### Trumps

The [Trumps Layer](/articles/css-architectural-overview.html#the-trumps-layer) contains code that is considered definitive. The values of the properties found in these files should override any previously declared property in any other layer.

```
@import 'workarea/storefront/trumps/break_word';
@import 'workarea/storefront/trumps/clearfix';
@import 'workarea/storefront/trumps/hidden';
@import 'workarea/storefront/trumps/hidden_if_js_enabled';
@import 'workarea/storefront/trumps/image_replacement';
@import 'workarea/storefront/trumps/truncate';
@import 'workarea/storefront/trumps/visually_hidden';
@import 'workarea/storefront/trumps/visible';
<%= append_stylesheets('storefront.trumps') %>
```

## Adding and Removing stylesheets

Oh yeah, I guess this guide was supposed to be about adding and removing stylesheets through a manifest. Well, now that you know how the manifests are structured, adding and removing files is as easy as adding and removing the relevant `@import` statements.

If the asset you want to include has been packaged as a gem, first add the gem to your Gemfile and then `@import` the asset in your manifest using the path to the asset within the gem. If the asset is not available as a gem, simply download the asset and copy it to your application's `vendor/assets/stylesheets` directory and reference it from there.

Refer to [Appending](/articles/appending.html) for advice on managing plugin stylesheets in your manifests.


