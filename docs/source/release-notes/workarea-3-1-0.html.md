---
title: Workarea 3.1.0
excerpt: 46967c84a5a, b7592d3925f, b37d2159a80
---

# Workarea 3.1.0

## Adds Order Copying

[46967c84a5a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/46967c84a5a169439a43b1dc5ede7cf2665a2b54), [b7592d3925f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b7592d3925f5a127f6c87d4f8e697ffeff29f2f7), [b37d2159a80](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b37d2159a80240a7c6079ba3bdc2ffe57759701e)

Workarea 3.1 adds a Ruby API for order copying.

- Adds `Workarea::CopyOrder` service
- Does not copy fields specified in `Workarea.config.copy_order_ignored_fields`
- Modifies _workarea/admin/orders/show.html.haml_, but most UI work is completed in the [Workarea OMS plugin](https://stash.tools.weblinc.com/projects/WL/repos/workarea-oms/browse)

## Adds Fulfillment & Payment Statuses

[#2726](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2726/overview), [#2743](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2743/overview), [#2727](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2727/overview), [#2721](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2721/overview), [#2706](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2706/overview), [2f052fedd5d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2f052fedd5de72564d05ce12f8533ba102689758), [#2671](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2671/overview)

Workarea 3.1 adds the concept of payment status and decouples fulfillment status from order status. Fulfillment and payment statuses are displayed in the Admin.

- Adds _state_ component to Admin UI
- `Workarea.config.status_state_indicators` stores a mapping of fulfillment and payment statuses to state component modifiers
- Displays fulfillment and payment status within the order cards
- Fulfillment and payment statuses are each a facet on the order and a filter in the Admin UI
- `OrderFulfillmentStatus` is deprecated and no longer used to implement `Workarea::Search::Admin::Order#order_status`
- Adds `Workarea::Payment::Status` module with various status calculator status classes
- `Workarea.config.payment_status_calculators` contains the list of calculators used to determine payment status
- Converts orders and payment transactions index pages to use tables instead of summaries
- Abstracts a _checkbox_ component from the _summary_ component to allow its use in the new index tables

## Adds Orders Timeline

[#2635](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2635/overview), [00480af01a4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/00480af01a4960f955e1ea9e69b9b7944f882bc1), [2b33c68a666](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2b33c68a6664b9b7306748a0eb91b064858448da)

Workarea 3.1 adds an Admin order timeline, which is similar in function to other Admin activity.

- Adds Admin route, controller action, view model, helper, views, and partials for orders timeline
- Adds factory method `create_transaction` for creating payment transactions in tests
- Changes fulfillment logic so that all items shipped or canceled together have the same values for both `created_at` and `updated_at`
- Adds MongoDB index for `Workarea::Payment::Transaction#payment`

## Adds User Creation Admin Workflow

[#2558](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2558/overview), [18c052bc7bb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/18c052bc7bb478b92bf31525cc4a35b88c108528), [29fff0c372e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/29fff0c372e028a82a9af77216dac734a60f2988), [#2744](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2744/overview), [#2755](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2755/overview)

Workarea 3.1 allows for the creation of new users through the Admin.

- Adds Admin route, controller, and views for create users workflow
- The current user must be a permissions manager to create a new user
- The workflow optionally delivers an account creation email
- Extracts Admin `UserParams` into its own module

## Adds User Avatars

[#2619](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2619/overview), [#2646](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2646/overview), [#2675](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2675/overview)

Workarea 3.1 adds user avatars and displays them in the Admin. Avatars may be user-provided but fall back to Gravatar.

- Adds `Workarea::User::Avatar` module, which is included in `Workarea::User`
- `avatar_image_url` defaults to [Gravatar](https://en.gravatar.com/)
- `Workarea.config.gravatar_options` sets Gravatar options
- Adds avatar fields, including file upload, to _workarea/admin/users/edit.html.haml_
- Adds `:avatar` image processor to Dragonfly initializer
- Adds `Workarea::Factories::User` module for user-related test factories

## Adds "Publish Now" Permission

[#2576](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2576/overview), [#2628](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2628/overview), [#2678](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2678/overview), [#2759](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2759/overview), [#2652](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2652/overview), [#2745](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2745/overview), [#2750](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2750/overview)

Workarea 3.1 adds a "can publish now" permission and modifies the Admin UI to honor this permission. Users without this permission must select a release in order to make changes.

- Adds `can_publish_now` permission to `User::Authorization`
- Extracts Admin publish controls to _workarea/admin/releases/\_publish.html.haml_
- Adds `check_publishing_authorization` method to `Workarea::Admin::Publishing` controller module
- Adds `check_publishing_authorization` before action to various Admin controllers
- Add `WORKAREA.disablePublishNow` JavaScript module to disable publishing controls as needed
- Displays disabled buttons in a "disabled" state with tooltip explaining why the button is disabled

## Adds Sequential Product Editing

[#2571](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2571/overview), [2cfeed0a4b5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2cfeed0a4b5bac72cb6a0e9e77975388a02122c7), [6d640e3a7b9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6d640e3a7b9b52cd8827f093f5ab2fe29102a243), [#2575](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2575/overview), [#2747](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2747/overview)

Workarea 3.1 adds sequential product editing, which allows an admin user to select products in bulk and edit them sequentially (in an editing loop).

- Adds model `Workarea::BulkAction::SequentialProductEdit`
- Adds Admin route, controller, view model, and views for sequential product editing
- Extracts `Workarea::Admin::BulkVariantSaving` from `Workarea::Admin::CreateCatalogProductsController`
- Modifies `Workarea::BulkAction` to convert a query-based bulk action to an ID-based bulk action when possible

## Adds Bulk Product Editing with a Release

[#2539](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2539/overview), [#2565](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2565/overview), [#2564](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2564/overview), [c91a2d2f8b5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c91a2d2f8b5d97bd0f1fb9835f9666837c7f9ffc)

Workarea 3.1 modifies `Workarea::BulkAction::ProductEdit` and its associated Admin controller and views to allow bulk product editing with a release.

## Adds Product Copying

[#2538](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2538/overview), [#2542](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2542/overview), [#2541](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2541/overview), [#2557](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2557/overview)

Workarea 3.1 adds a Ruby API for copying a product and provides an Admin workflow for this process.

- Adds the `Workarea::CopyProduct` service
- `Workarea.config.product_copy_default_attributes` sets default values to be used for particular fields on the copied product (for example, sets `active` to `false`
- Adds Admin route, controller, and views for copying a product
- Adds Admin JavaScript module `WORKAREA.productCopyIDs`

## Adds Variant Ordering

[#2521](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2521/overview), [#2532](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2532/overview)

Workarea 3.1 allows admins to re-order variants in the Admin UI. The order is honored when displaying variants in the Storefront.

- Modifies `Workarea::Catalog::Variant` to include `Workarea::Ordering`
- Adds Admin route and controller action for sorting variants
- Modifies variants Admin index page, allowing variants to be sorted with mouse/pointer
- Adds Admin JavaScript module `WORKAREA.sortVariants` to handle sorting

## Adds Storefront Preview Links to Admin Creation Workflows

[#2692](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2692/overview)

Workarea 3.1 adds "preview in Storefront" links within several Admin creation workflows. The change modifies many Admin views to create a consistently positioned auxiliary navigation, within which the preview links appear.

## Adds Automatic Navigation Redirects

[#2669](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2669/overview)

Workarea 3.1 adds the callbacks worker `Workarea::RedirectNavigableSlugs`, which enqueues on `Navigable#update` if the `Navigable#slug` has changed. The worker creates a `Navigation::Redirect` within each locale based on the changed slug. This worker is disabled by default, but is enabled for Admin UI requests by the `Workarea::Admin::ApplicationController`.

## Adds Restore Functionality (and "Trash" View) to Admin

[5dd586d5aa4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5dd586d5aa412a83ffd875697711410ee803114c), [#2632](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2632/overview), [6038b5434a0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6038b5434a04823c95e5199d951bb3dbe9322177), [89212ff576c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/89212ff576cfda972a128877297d2dab2d051168), [#2640](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2640/overview), [35b70445561](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/35b70445561158cb883c2d393f0c764ff182ac77)

Workarea 3.1 allows admins to restore deleted model instances and provides a "Trash" screen for viewing models that can be restored.

- Adds "restore" links for deleted items within various Admin activity partials
- Adds route, controller, and view for "Trash" view of activity, which is activity which can be restored
- Adds `can_restore` user permission, which is required for a user to restore a model
- Restoring a model re-creates it from a cache in the Mongoid audit log
- Changes 'mongoid-audit\_log' dependency to `'>= 0.5.0'`
- Removes `dependent: :destroy` behavior from `Commentable#comments`, `Contentable#content`, and `Releasable#changesets`
- Extends Dragonfly to not delete assets from the data store

## Adds HTML Sitemap to Storefront

[#2507](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2507/overview), [#2525](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2525/overview), [#2543](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2543/overview), [1c8fa2175fb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1c8fa2175fb8985ea5f0f387690977d64552b902), [c3cea6b8835](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c3cea6b88350a9e72195bcc10721d49ae9a41fe8), [7744f1c9daf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7744f1c9daf4b94ae4bab839599fa61a7e77bf13)

Workarea 3.1 adds an HTML sitemap to the Storefront in response to requests from retailers and SEO companies.

- Adds MongoDB indexes to `Workarea::Navigation::Taxon` for `navigable_id` and `url`
- Adds `Workarea::TaxonomySitemap` query for retrieving taxons
- Adds Storefront route, controller, and views for rendering Storefront sitemap
- Modifies _robots.txt_ file to allow the sitemap path
- Adds _sitemap_ and _sitemap-pagination_ Storefront components
- Adds system page links, including the sitemap, to the application footer
- Adds append point to the application footer to allow plugins to append additional system pages

## Adds Prompt for Unsaved Changes in Admin

[#2625](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2625/overview), [#2636](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2636/overview), [#2649](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2649/overview), [#2665](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2665/overview), [#2725](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2725/overview)

Workarea 3.1 adds the Admin JavaScript module `WORKAREA.unsavedChanges`, which prompts Admin users when navigating away from unsaved changes in the Admin UI. The functionality applies only to forms with a `data-unsaved-changes` attribute and ignores fields with a `data-unsaved-changes-ignore` attribute.

## Adds "Spacing" Options to Divider Content Block Type

[#2697](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2697/overview)

Workarea 3.1 modifies the _Divider_ content block type, allowing for "spacer" content blocks that create visual separation, with or without a visible border.

- Adds _Height_ and _Show line_ fields to the _Divider_ content block type
- Adds _small_, _medium_, and _large_ modifiers to the Storefront _divider-content-block_ component
- Modifies the `Workarea::Content::BlockDraft` model to typecast data before save

## Adds Boolean Content Field Type

[#2626](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2626/overview)

Workarea 3.1 adds the `Workarea::Content::Fields::Boolean` content field type and the associated Admin partial, _workarea/admin/content\_blocks/\_boolean.html.haml_.

## Disables Checkout Buttons on First Click

[#2716](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2716/overview), [#2704](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2704/overview)

Workarea 3.1 disables checkout "continue" buttons on first click to prevent multiple submissions.

- Requires the jQuery UJS JavaScript library in the Storefront
- Uses `data-disable-with` on each of the "continue" buttons in checkout to disable the button on first click
- Modifies the Storefront _loading_ component and adds the _inline_ and _light_ modifiers for use within disabled buttons

## Changes Storefront Primary Image Logic

[#2616](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2616/overview)

Workarea 3.1 adds the Storefront enumerable `Workarea::Storefront::ProductViewModel::ImageCollection` and returns an instance of this collection as the product view model `images`. This change ensures the current product image matches the facets selected by the user when available.

## Changes Fulfillment Logic

[#2760](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2760/overview), [#2762](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2762/overview), [c47f10e35b5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c47f10e35b5e295507d49592bee4557d90733c02), [#2653](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2653/overview)

Workarea 3.1 makes the following minor changes to fulfillment logic.

- Modifies the `CreateFulfillment` service to prevent creating duplicate fulfillment items under certain circumstances
- Modifies the `Fulfillment` model, extracting `mark_item_shipped` from `ship_items`, allowing items to be marked shipped without triggering a transactional email (useful in the case of digital items)
- Opens tracking links within the fulfillment Admin screen within a new window

## Applies Admin UI Changes to Support OMS Plugin

[#2740](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2740/overview)

Workarea 3.1 applies the following changes to support upcoming changes in the [Workarea OMS](https://stash.tools.weblinc.com/projects/WL/repos/workarea-oms/browse) plugin.

- Modifies margin styles on the Admin _property_ component
- Modifies the styles of the Admin _text-button_ component to support icons
- Adds "Trash" link to "Settings" dashboard navigation
- Adds append point to "Settings" dashboard navigation

## Improves Usability of Storefront Form Fields

[#2670](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2670/overview), [#2676](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2676/overview), [#2535](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2535/overview)

Workarea 3.1 modifies attributes on various form fields in the Storefront to improve usability.

## Deprecates Auto Filter Middleware for Storefront Search

[6f0c0e51ae0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6f0c0e51ae051b3c04e84a7de8fc3ddb8d616344)

Workarea 3.1 removes `Workarea::Search::StorefrontSearch::AutoFilter` from the configured Storefront search middleware (`Workarea.config.storefront_search_middleware`) and prints a deprecation warning when this middleware is included in that configuration. This middleware is marked for removal in Workarea 3.2.

## Upgrades to Rails 5.1

[#2660](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2660/overview), [#2715](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2715/overview), [03e5c58ac89](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/03e5c58ac899ad97fc32ad29f6aef0065f7a5b97)

Workarea updates its Rails dependency to Rails 5.1.

- Changes various Ruby dependencies in _workarea-core.gemspec_ for compatibility with Rails 5.1
- Changes minor implementation details in various files for compatibility with the Ruby dependency changes
- Modifies `Workarea::SystemTest` to inherit from `ActionDispatch::SystemTestCase`, the Rails system test case introduced in Rails 5.1
- Extracts `Workarea::IntegrationTest::Configuration` to share behavior between `IntegrationTest` and `SystemTest` (since `SystemTest` no longer inherits from `IntegrationTest`)
- Extends the Mongoid Simple Tags library for compatibility with Mongoid 6.2

## Adds Tests Converted from RSpec

[#2724](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2724/overview), [#2650](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2650/overview)

Workarea 3.1 adds more tests which were converted from the remaining RSpec test suite. The converted tests include all Admin specs and credit card operation specs.

## Adds Factory Method to Complete a Checkout

[aa9d7dd5e13](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/aa9d7dd5e1318c9b7dcc7dfa10569e5a10abb29d), [990df54af0a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/990df54af0abe7eaf2d5050d6841cc9bfa929597)

Workarea 3.1 adds the `complete_checkout` factory method for use in tests.

## Adds Test Runner for Each Installed Plugin

[f1c78465a38](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f1c78465a380dd73c38a48ddf01ce9b6a575ce09)

Workarea 3.1 adds a test runner task for each installed plugin, allowing an application to run tests per-plugin.

## Disables Text Transforms in Tests

[#2681](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2681/overview)

Workarea 3.1 disables CSS text transforms while running tests to reduce failures caused by case sensitivity when tests are extended by applications.

## Adds Asset Lookup for Use in Content Block DSL

[#2710](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2710/overview)

Workarea 3.1 adds the `find_asset_id_by_file_name` method for use in the content block DSL, avoiding the need for applications to provide this functionality on their own.

## Adds "Details" API to Product (Extracted from Variant)

[#2657](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2657/overview)

Workarea 3.1 extracts `Workarea::Details` from `Workarea::Catalog::Variant` and includes the new module in `Workarea::Catalog::Product` (and `Workarea::Catalog::Variant`) for a consistent details API for products and variants.

## Adds "Only If" Option for Enqueuing Callbacks Workers

[#2728](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2728/overview)

Workarea 3.1 adds the `enqueue_on: { only_if: -> { ... } }` Sidekiq option for use by callbacks workers. This option complements the previously available `ignore_if` option.

## Adds "Add to Cart Confirmation" Analytics Event

[#2758](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2758/overview)

Workarea 3.1 announces an _addToCartConfirmation_ analytics event when items are added to the cart in the Storefront. Analytics adapters may report this event as appropriate for each analytics service.

## Adds Detection for Duplicate DOM IDs in Storefront

[#2684](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2684/overview)

Workarea 3.1 adds the Core JavaScript module `WORKAREA.duplicateId`, which throws an error when duplicate _id_ attribute values exist in the DOM. The module is required only in the Storefront, and only for the _Development_ and _Test_ Rails environments. The change also fixes several instances of duplicate IDs.

## Adds Detection for Duplicate JS Module Scopes in Storefront

[#2686](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2686/overview)

Workarea 3.1 updates the Workarea JavaScript library, `workarea/core/workarea.js`, to throw an error when modules are re-initialized on the same scope. This change is limited to the _Development_ and _Test_ Rails environments.

## Adds Additional Permissions to Admins Seeds

[#2638](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2638/overview)

Workarea 3.1 adds additional permissions to the admin users created by `Workarea::AdminsSeeds`. The permissions added were previously omitted due to oversight or are new in Workarea 3.1.

## Raises When Discount Application Order is Not Configured

[#2677](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2677/overview)

Workarea 3.1 raises a `MissingConfigurationError` if `Workarea.config.discount_application_order` is missing a discount class. The raised error provides info on how to resolve the problem and is more helpful than the error raised in previous Workarea versions.

## Automatically Configures Amazon S3 Dragonfly Data Store from Environment

[#2573](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2573/overview)

Workarea 3.1 automatically configures Dragonfly to use S3 as its data store when `WORKAREA_S3_REGION` and `WORKAREA_S3_BUCKET_NAME` are present in the environment. The values of `WORKAREA_S3_ACCESS_KEY_ID` and `WORKAREA_S3_SECRET_ACCESS_KEY` are also included in the configuration when present.

Prior Workarea versions required manual configuration via `Workarea.config.asset_store`.

## Changes Search Synonyms Sanitization to Remove Hyphens

[#2663](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2663/overview)

Workarea 3.1 changes `Workarea::Search::Settings#sanitized_synonyms` to split hyphenated synonyms into multiple words.

## Persists Backorder Dates to Inventory Transaction Items When Capturing Inventory

[da04a304851](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/da04a304851bdbc68e668744fbc4d5a349ac44ea)

Workarea 3.1 saves the backorder date on the inventory transaction item when placing the order. This change will help in future OMS related features that require a decision on when orders should ship.

## Internationalizes Name Field on Order

[#2618](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2618/overview)

Workarea 3.1 internationalizes `Workarea::Order#name`, which previously returned an English string due to oversight.

## Changes "Finished Checkout" Destination for Admins

[b703608e719](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b703608e719a3f9932344f60ca8d67f45c6b1725), [3effec9185b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3effec9185b20163c559db30cc9c065caaff5e8c)

Workarea 3.1 redirects to the order Admin screen after placing an order when the order is placed by an admin user with order access.

## Moves Storefront Search Response Message from Flash to View

[#2763](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2763/overview)

Workarea 3.1 moves the Storefront search response message (e.g. a message indicating the search query was rewritten) from the flash to the view so that the message persists until the user manually dismisses it or reloads the page.

## Removes Explicit Line Height from Admin Toggle Buttons

[5556247a948](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5556247a948949df60039c8273e786441706c34e)

Workarea 3.1 removes explicit line height styles from the _toggle-button_ Admin component to improve alignment with other controls.

## Adds Workarea Favicon to Admin

[#2756](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2756/overview)

Workarea 3.1 adds a Workarea favicon to the Admin.

## Adds Discount Redemption Data to Admin UI

[#2569](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2569/overview)

Workarea 3.1 displays the discount redemption amount in pricing discounts Admin screens.

## Adds Sale Price to Pricing Skus Cards

[#2581](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2581/overview)

Workarea 3.1 displays the sale price (when available) in the pricing skus Admin screens.

## Adds Template to Product Summaries in Admin

[#2707](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2707/overview)

Workarea 3.1 displays the product template within Admin product summaries.

## Adds "Type" Title Attributes to Admin Summaries

[#2718](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2718/overview)

Workarea 3.1 adds _title_ attributes to the display of _type_ values in Admin summaries since this text sometimes overflows the container.

## Re-Orders Cards in Orders Admin

[ccd22dfc6dd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ccd22dfc6dd08f558ad8d70d2b48310a177d90ad)

Workarea 3.1 re-orders the cards within the order Admin screens to group read-only and actionable cards together.

## Improves Display of Empty Admin Activities

[#2679](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2679/overview)

Workarea 3.1 moves the display of empty activities to a more appropriate location within Admin activity.

## Fixes Display of "Active/Inactive" in Prices Admin

[#2582](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2582/overview)

Workarea 3.1 fixes the display of the values "Active" and "Inactive" within prices Admin screens.

## Removes Link to Nonexistent Shipping Service Admin Screen

[#2622](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2622/overview)

Workarea 3.1 changes the shipping services Admin screen, removing a link to a nonexistent location.


