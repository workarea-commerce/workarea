---
title: Workarea 3.0.8
excerpt: #2615
---

# Workarea 3.0.8

## Explicitly Loads EXIF Reader JPEG Library

[#2615](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2615/overview)

Workarea depends on the `EXIFR::JPEG` library. [Version 1.3.0 of the exifr gem](https://rubygems.org/gems/exifr/versions/1.3.0) no longer loads `EXIFR::JPEG` implicitly, so applications using that version of the gem are seeing <samp>NameError: uninitialized constant EXIFR::JPEG</samp> prior to Workarea 3.0.8.

Workarea 3.0.8 explicitly requires `EXIFR::JPEG` within the _lib/workarea/core.rb_ Core library file to resolve this issue.

## Randomizes the Default Admin's Password in Non-Development Environments

[9f448f7a2f4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9f448f7a2f4eacb6f6eadd768ada223ba0c1cb41)

Workarea 3.0.8 modifies the implementation of `Workarea::AdminsSeeds#perform` in _workarea-core/app/seeds/workarea/admins\_seeds.rb_ to randomize the password of the _user@workarea.com_ user in Rails environments other than _development_. The change also adds `Workarea::AdminsSeeds#password` within the same file.

Be aware of this change if you run seeds in environments other than development and use the default Admin user. Decorate `AdminsSeeds#perform` to provide your own password, or manually reset the password for this user after running seeds.

## Renames Test Cases to Match File Names

[f120cb67ccd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f120cb67ccdc9c8ff9604377a453caddb1bcd4f9)

Workarea 3.0.8 renames the following test cases to match their file names.

- Renames `CommentingSystemTest` to `CommentsSystemTest` in _workarea-admin/test/system/workarea/admin/comments\_system\_test.rb_
- Renames `DiscountSystemTest` to `DiscountsSystemTest` in _workarea-admin/test/system/workarea/admin/discounts\_system\_test.rb_
- Renames `LoginInIntegrationTest` to `LoginIntegrationTest` in _workarea-storefront/test/integration/workarea/storefront/login\_integration\_test.rb_

## Fixes Display of Radio Buttons in iOS

[#2596](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2596/overview)

Workarea 3.0.8 fixes the display of radio button in iOS, which were displaying with square corners.

The following stylesheets and rules are affected.

- 

_workarea-admin/app/assets/stylesheets/workarea/admin/generic/\_reset.scss_

  - Adds `[type=radio] {}`
- 

_workarea-storefront/app/assets/stylesheets/workarea/storefront/generic/\_reset.scss_

  - Removes `input:not([type=radio]) {}`
  - Adds `textarea, input {}`
  - Adds `[type=radio] {}`

## Improves Display of jQuery UI Datepicker in Admin

[e43d15ad581](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e43d15ad581ad25db547ca5124923bbc479fd4ec), [da42dd1c891](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/da42dd1c89167455e815780837f30d07acd2c01d)

Workarea 3.0.8 improves the display of the "today" indicator for the Admin's jQuery UI _datepicker_ widget and aligns the datepicker left when inside an Admin workflow UI.

The change affects the following within _jquery\_ui/admin/\_ui\_datepicker.scss_.

- Removes `$datepicker-today-indicator-offset`
- Modifies `$datepicker-today-indicator-size`
- Adds `$datepicker-today-border-size`
- Adds `$datepicker-today-border-color`
- Modifies `.ui-datepicker-today a:after {}`
- Modifies `.publish-create-release .ui-datepicker-inline {}`

## Fixes Icon Size for Release Select Component in Admin

[637081e009e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/637081e009ecac59dadc5f38bcf9fb19f309de04)

Workarea 3.0.8 fixes the icon size for the _release-select_ component in the Admin.

The following changes are applied in the _workarea/admin/components/\_release\_select.scss_ Admin component stylesheet.

- Adds `$release-select-icon-size`
- Modifies `.release-select__icon {}`

The following changes are also applied in that file to correct a typo.

- Renames `$release-select--emphasize-border-color` to `$release-select-emphasize-border-color`
- Modifies `.release-select--emphasize .release-select__container {}`

## Removes Superfluous Link Color Definition in Storefront

[#2588](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2588/overview)

Workarea 3.0.8 removes a superfluous `$link-color` definition from the _typography_ stylesheets layer, since this variable is already defined (and applies more broadly) within the _settings_ stylesheets layer.

The change removes `$link-color` from the _workarea/storefront/typography/\_links.scss_ Storefront typography stylesheet.

## Adds Tag List Field Notes to Bulk Product Edit

[#2579](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2579/overview)

Workarea 3.0.8 adds help text notes to tag list fields in the bulk product edit Admin view.

The change modifies the _workarea/admin/bulk\_action\_product\_edits/edit.html.haml_ Admin view and adds the `workarea.admin.bulk_action_product_edits.tags.tags_note` translation to the Admin's _en.yml_ locale.

The PR also renames the `workarea.admin.create_catalog_products.setup.comma_separated_just_like_this` translation to `workarea.admin.create_catalog_products.setup.tags_note` and updates the _workarea/admin/create\_catalog\_products/setup.html.haml_ Admin view accordingly.

## Fixes Storefront Secondary Nav Displaying Inactive Taxons

[08726ed803c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/08726ed803c6af8e1f1332734027b00331072eaa)

Workarea 3.0.8 modifies the _workarea/storefront/shared/\_left\_navigation.html.haml_ Storefront partial to fix the _secondary-nav_ component. The fix ensures each _secondary-nav\_\_item_ displays only if the corresponding [taxon](navigation.html#taxon) is active.

The change also adds a Storefront system test, `Workarea::Storefront::NavigationSystemTest#test_left_navigation` to _workarea/storefront/navigation\_system\_test.rb_.

## Fixes Releases Activity Log Exception

[#2574](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2574/overview)

Workarea 3.0.8 modifies the Admin partial for releases activity, _workarea/admin/activities/\_release\_update.html.haml_, to guard against `Mongoid::AuditLog::Entry#audited` returning `nil`, which results in a raised exception in the Admin UI.

The change also modifies the value of the `workarea.admin.activities.release_published_html` translation for the Admin's _en.yml_ locale, improving the activity log message. The PR also adds an Admin system test, `Workarea::Admin::ActivitySystemTest#test_activity_log_for_releases`, to _workarea/admin/activity\_system\_test.rb_.

## Fixes Product List Markup in Storefront Cart Views

[#2578](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2578/overview)

Workarea 3.0.8 modifies the following Storefront views, renaming the `.customization` element to `.product-list__customization` to correctly scope the element to the _product list_ component. The views are updated to match the style guide and stylesheet for the component.

- _workarea/storefront/cart\_items/create.html.haml_
- _workarea/storefront/carts/show.html.haml_

## Fixes Display of Inventory Backordered Date in Admin

[#2590](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2590/overview)

Workarea 3.0.8 fixes the display of the `backordered_until` field within the inventory sku Admin screens.

The following admin views are modified.

- _workarea/admin/inventory\_skus/edit.html.haml_
- _workarea/admin/inventory\_skus/\_cards.html.haml_

## Fixes Display of Active Field in Product Admin

[#2601](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2601/overview)

Workarea 3.0.8 fixes the display of the _active_ field within product Admin screens. The following Admin views are affected.

- _workarea/admin/catalog\_products/edit.html.haml_
- _workarea/admin/catalog\_products/\_cards.html.haml_

This change also adds the following translations to the Admin's _en.yml_ locale.

- `workarea.admin.catalog_products.edit.active_info`
- `workarea.admin.catalog_products.edit.active_info_title`

## Reduces Font Size of Workflow Bar Steps in Admin

[#2608](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2608/overview)

Workarea 3.0.8 reduces the font size of the steps that appear in the Admin's workflow bar.

The change affects the following within _workarea/admin/components/\_workflow\_bar.scss_.

- Removes `$workflow-bar-steps-font-size`
- Modifies `.workflow-bar__steps {}`

## Truncates Long Breadcrumbs in Admin Menu Editor

[#2607](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2607/overview)

Workarea 3.0.8 truncates long breadcrumbs within the Admin's _menu editor_ component.

The change modifies the following rules within _workarea/admin/components/\_menu\_editor.scss_.

- `.menu-editor__head-label {}`
- `.menu-editor__breadcrumbs {}`
- `.menu-editor__breadcrumbs-node {}`

## Increases Clickable Area During Bulk Action Selection

[#2598](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2598/overview)

Workarea 3.0.8 increases the clickable area of each summary on Admin index pages while selecting summaries for a bulk action. The entire summary is clickable rather than only a checkbox within the summary.

The change modifies the _summary_ component stylesheet in the Admin, _workarea/admin/components/\_summary.scss_. The following rules are modified.

- `.summary__checkbox {}`
- `.summary__checkbox-label {}`
- `.summary__checkbox-input {}`

Additionally, the _Workarea::Admin::BulkActionsSystemTest_ Admin system test is strengthened. The change modifies the test _test\_session\_reset_.

## Adds Disabled Option to Admin Toggle Buttons

[#2604](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2604/overview)

Workarea 3.0.8 adds a _disabled_ option to Admin toggle buttons.

The change affects the Admin helper `Workarea::Admin::ApplicationHelper`, modifying `toggle_button_for`, and the _workarea/admin/shared/\_toggle\_button.html.haml_ partial in the Admin.

The PR also changes the _workarea/admin/bulk\_action\_product\_edits/edit.html.haml_ Admin view, applying the new toggle button option to fix a toggle button within the view.

## Fixes the HTML Structure of the Generic Product Template in the Storefront

[#2603](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2603/overview)

Workarea 3.0.8 corrects code indentation within the Storefront generic product template, _workarea/storefront/products/templates/\_generic.html.haml_, which was incorrectly nesting much of the template's content within `.product-details__name`.

## Fixes Tests that Require Auto Capture Disabled

[9c226a06116](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9c226a06116843523a09469c115bc3ead8a7091d)

Workarea 3.0.8 fixes the following Admin system tests, which require `Weblinc.config.auto_capture` to be set to `false`.

- `Workarea::Admin::OrdersSystemTest#test_payment` in _workarea/admin/orders\_system\_test.rb_
- `Workarea::Admin::PaymentTransactionsSystemTest#test_viewing_transactions` in _workarea/admin/payment\_transactions\_system\_test.rb_

## Fixes Seeds Exception for Missing Fulfillment

[#2589](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2589/overview)

Workarea 3.0.8 modifies the following seeds to help avoid a `Mongoid::Errors::DocumentNotFound` exception (missing `Workarea::Fulfillment`) when running seeds.

- `Workarea::OrdersSeeds#find_purchasable_sku` in _workarea-core/app/seeds/workarea/orders\_seeds.rb_
- `Workarea::ProductsSeeds#perform` in _workarea-core/app/seeds/workarea/products\_seeds.rb_

## Adds Pointer Cursor to Buttons & Text Buttons in Storefront

[#2595](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2595/overview)

Workarea 3.0.8 applies a pointer cursor to the _button_ and _text-button_ components in the Storefront.

The change modifies the following style rules in the Storefront.

- `.button {}` in _workarea/storefront/components/\_button.scss_
- `.text-button {}` in _workarea/storefront/components/\_text\_button.scss_

## Improves Reliability of Content Editing UI Tests

[72fc6ee4153](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/72fc6ee4153e823f1f12d2eb0d2c40e89ced4053)

Workarea 3.0.8 "unsticks" the Admin's _content-editor\_\_aside_ UI element in the _test_ environment to improve reliability of automated tests.

The change affects Workarea Testing's feature spec helper stylesheet for the Admin UI, _workarea/admin/feature\_spec\_helper.scss_, adding a `.content-editor__aside {}` style rule.

## Strengthens Content System Test in Admin

[802eae41c75](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/802eae41c75a3c00b6231158f7abbc2c73bcaa1f)

Workarea 3.0.8 strengthens the `Workarea::Admin::ContentSystemTest` Admin system test case.

The change modifies `test_reordering_content_blocks` within _workarea/admin/content\_system\_test.rb_.

## Fixes Content Block Generator Partial Path

[#2594](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2594/overview)

Workarea 3.0.8 fixes the path of Storefront partials generated by the _content block type_ generator.

The change modifies the following.

- `Workarea::ContentBlockTypeGenerator#view_path` in the Core generator file _workarea/content\_block\_type/content\_block\_type\_generator.rb_
- `Workarea::ContentBlockTypeGeneratorTest#test_create_storefront_view` in the Core generator test case _workarea/content\_block\_type\_generator\_test_

## Adds Boilerplate for CSS Web Fonts

[#2587](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2587/overview)

Workarea 3.0.8 adds boilerplate for [@font-face CSS statements](https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face) in the Storefront.

The change adds the _workarea/storefront/generic/\_fonts.scss_ Storefront stylesheet, modifying the _workarea/storefront/application.scss.erb_ stylesheet manifest accordingly.

Applications should override this stylesheet to add custom _@font-face_ CSS statements, placing the corresponding font files under _app/assets/fonts/_, which is where the `font-url()` helper looks for font files. For example: _app/assets/fonts/workarea/storefront/font\_file.ext_

## Adds Append Point to Current User JSON Response

[#2614](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2614/overview)

Workarea 3.0.8 adds an append point to the _current\_user_ JSON view in the Storefront, allowing plugins and applications to add data to the current user JSON response.

The change adds a Core extension to `JbuilderTemplate` in _lib/workarea/ext/jbuilder/jbuilder\_append\_partials.rb_ and requires it within _lib/workarea/core.rb_.

The new append point, `storefront.current_user`, is added to the Storefront JSON view _workarea/storefront/users/current\_user.json.jbuilder_.

## Adds Feature Spec Helpers Append Points to Stylesheet Manifests

[#2593](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2593/overview)

Workarea 3.0.8 adds new append points to the Admin and Storefront _application_ stylesheet manifests to allow plugins and applications to provide their own feature spec helper stylesheets.

The following append points are added.

- `admin.feature_spec_helpers` in _workarea-admin/app/assets/stylesheets/workarea/admin/application.scss.erb_
- `storefront.feature_spec_helpers` in _workarea-storefront/app/assets/stylesheets/workarea/storefront/application.scss.erb_

## Fixes Link within Admin Text Box Style Guide

[#2592](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2592/overview)

Workarea 3.0.8 fixes a link within the Admin's _text-box_ style guide partial.

The change affects _workarea/admin/style\_guides/components/\_text\_box.html.haml_ in the Admin.

## Adds Workarea Logo to Admin Toolbar Takeover

[#2584](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2584/overview)

Workarea 3.0.8 modifies the _workarea/admin/toolbar/show.html.haml_ Admin view, which is used to render the Admin toolbar takeover in the Storefront. The change adds the Workarea logo, which was unintentionally omitted from the original implementation.

## Modifies JavaScript Linter Rules

[#2591](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2591/overview)

Workarea 3.0.8 changes the following JavaScript modules and functions to align with updated JavaScript linter rules. These changes are stylistic only and should not affect the behavior of the code.

- 

Core

  - `WORKAREA.url.parse()` in _workarea/core/modules/url.js_
- 

Admin

  - `WORKAREA.contentPreview.initActions()` in _workarea/admin/modules/content\_preview.js_
  - `WORKAREA.taxonInsert.updateSelectMenu()` in _workarea/admin/modules/taxon\_insert.js_
- 

Storefront

  - `WORKAREA.searchFields.openSelected()` in _workarea/storefront/modules/search\_fields.js_

## Optimizes SVG Files in Admin

[#2597](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2597/overview)

Workarea 3.0.8 modifies all Admin SVG files under _app/assets/images/workarea/admin/_ to ensure that each file has an `xmlns` attribute and does not have an `id` attribute (to avoid duplicate IDs in the DOM).


