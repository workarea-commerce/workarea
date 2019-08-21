---
title: Workarea 3.4.0
excerpt: Release notes for Workarea 3.4.0
---

# Workarea 3.4.0

This document curates the 540 commits unique to Workarea 3.4 into 60 changes, for easier consumption. The changes are ordered roughly by "impact" to developers.

For more information about upgrading, see the [Workarea 3.4 upgrade guide](/upgrade-guides/workarea-3-4-0.html).

## Changes Admin Dashboards, Insights, and Reports; Adds Metrics; Removes Analytics

* Overhauls Admin dashboards
* Adds many new insights (accessible from dashboards, reports, and show pages)
* Improves insights content block (many new insights available)
* Adds insight icons to index pages
* Adds many new reports (some filterable, all exportable)
* Adds reports dashboard
* Adds reports reference
* Adds metrics engine (data stored by day and aggregated each week)
* Removes analytics (replaced by metrics)
* Requires Mongo 4

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3531/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3551/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3611/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3649/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3672/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3678/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3682/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3690/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3697/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3701/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3731/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3750/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3747/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3767/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3748/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3785/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3786/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3791/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3802/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3804/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3803/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3811/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3806/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3816/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3812/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3824/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3815/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3827/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3830/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3831/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3819/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3842/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3845/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3847/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3850/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3856/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3855/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3882/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3876/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3877/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3859/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3893/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3896/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3884/overview>


## Changes Product Image and Content Asset Uploads

* Adds drag and drop uploads for product images
* Improves drag and drop upload performance for content assets
* Uploads directly to S3
* Deprecates usage of Dropzones.js

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3634/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3656/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3684/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3708/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3720/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3718/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3776/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3775/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3778/overview>


## Changes Product Rules to Allow Excluding Products; Adds Product Rules to Search Customizations

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3544/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3814/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3897/overview>


## Adds Category and Product Exclusions to Discounts

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3506/overview>


## Adds Support for Progressive Web Apps

See [Progressive Web Apps](https://developers.google.com/web/progressive-web-apps/).

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3644/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3677/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3709/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3763/overview>


## Adds Admin to Debug and Analyze Search Behavior

* For the advanced retailer or developer
* Communicates what Workarea is doing to create search results

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3624/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3637/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3773/overview>


## Adds Configuration to Skip Appends

* Skip appends by regex, string or proc
* Allows per-site configuration

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3688/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3761/overview>


## Changes Platform Dependencies

* Changes Ruby compatibility to support up to Ruby 2.6
* Changes tests and initializers to support Rails 5.2
* Changes Active Shipping dependency to use vendored copy
* Changes callbacks workers to support Sidekiq Unique Jobs 6
* Removes Worker to clean unique jobs
* Changes mongoid-simple-tags dependency to use vendored copy
* Changes CI configuration to use Docker for testing dependencies (won't affect your builds unless you're using the platform CI scripts)
* Changes jQuery Validation dependency to 1.19.0

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3508/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3601/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3612/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3731/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3795/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3833/overview>


## Changes Platform & Dependency Configurations

* Updates app and plugin templates
* Moves some configuration from app template to platform
* Changes plugin template to enable generators within plugins

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3498/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3571/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3610/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3628/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3665/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3769/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3800/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3836/overview>


## Changes Test Factories to Move Default Attributes into Configuration

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3618/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3789/overview>


## Changes Favicons to Improve Administration and Defaults

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3703/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3790/overview>


## Changes Storefront to Use Administrable Open Graph Images

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3659/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3764/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3772/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3790/overview>


## Adds Option to Defer Publishing within Admin Workflows

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3825/overview>


## Changes Discount Code List Admin to Allow Editing

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3536/overview>


## Adds Optional Note and Tooltip Attributes to all Content Field Types

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3606/overview>


## Changes "On Sale" to Optionally Apply Per Price

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3521/overview>


## Adds Jumping to Variant by Name in Admin

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3527/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3538/overview>


## Changes Admin Search Models to Allow Searching by Tag

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3849/overview>


## Changes Storefront Meta Data to Provide Default Meta Descriptions

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3650/overview>


## Changes Storefront Mobile Filters UI to Include Aside

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3540/overview>


## Adds Breadcrumbs to Remote Selects in Admin

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3889/overview>


## Changes Storefront Autocomplete to Improve Experience on Touch Devices

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3713/overview>


## Changes Storefront Navigation to Support Touch Events

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3491/overview>


## Adds Sorting to Admin Remote Selects

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3734/overview>


## Adds Product Linking to Taxons

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3733/overview>


## Changes Taxonomy Content Blocks to Provide Option to Show Starting Taxon

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3743/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3805/overview>


## Adds Per-User Viewed Status to Admin Comments

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3489/overview>


## Changes Checkout Confirmation to Hide "Create Account" Form for Existing Account Emails

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3818/overview>


## Changes Status Report Email to Send to Multiple Recipients

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3719/overview>


## Changes Configuration for Sending Email to Allow Limiting Recipients

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3595/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3738/overview>


## Changes Test Case (Unit Tests) to Not Send Email

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3887/overview>


## Adds "Inactive" Indicator to Admin Toolbar

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3485/overview>


## Adds Conditional "Link To" Helpers

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3468/overview>


## Adds Order Price Overriding from Workarea OMS

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3737/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3777/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3879/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3895/overview>


## Adds Rails Generator for Web Analytics Adapters

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3643/overview>


## Changes Web Analytics to Fire for Admins

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3643/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3888/overview>


## Changes JavaScript Breakpoints API to be More Predictable

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3654/overview>


## Changes Shipping SKU Dimensions to Match ActiveShippping

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3646/overview>


## Adds `each_by` for Elasticsearch Queries

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3694/overview>


## Adds Service Class for Adding Items to a Cart

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3852/overview>


## Adds User Agent to Order Model

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3869/overview>


## Changes Country Lookups to Additionally Support Unofficial Names

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3861/overview>


## Adds Before Action to all Admin Controllers to Ensure Auth Cookie is Touched

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3846/overview>


## Changes Admin for Orders & Fulfillment to Support B2B Plugin

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3838/overview>


## Changes HTTP Caching to Fix Issues

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3658/overview>


## Changes Ruby Dynamic Method Definitions to Follow Best Practices

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3676/overview>


## Changes Sorting of Product Images Default Scope to Handle Edge Cases

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3774/overview>


## Adds ActionView Patch to Improve View Path Resolution Performance

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3554/overview>


## Changes "Clean Orders" Worker to Improve Performance

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3726/overview>


## Changes String Representation of Pricing Cache Key to Improve Readability

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3837/overview>


## Changes Admin & Storefront UIs to Ensure W3C Validation Compliance

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3840/overview>


## Changes Storefront UI in Accordance with Accessibility Audit

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3568/overview>


## Changes Admin UI to Clean Up Minor Issues

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3506/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3537/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3546/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3620/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3624/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3746/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3759/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3751/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3758/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3752/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3753/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3754/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3823/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3822/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3839/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3819/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3855/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3864/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3878/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3870/overview>


## Changes Storefront UI to Clean Up Minor Issues

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3541/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3573/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3674/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3722/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3779/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3820/overview>


## Changes Login Test to Additionally Test Logout Link

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3565/overview>


## Adds Capybara Configuration to System Tests to Reduce Noise in Output

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3766/overview>


## Adds Inline Reference Docs for Fulfillment

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3542/overview>


## Adds Deterministic Sort for Icons in Style Guides

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3562/overview>


## Adds Append Points

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3695/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3777/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3800/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3821/overview>


## Merges & Other Release Management

This change consolidates small continual changes required to manage the software, such as merging in changes from patch releases, updating the version number, and updating the changelog.

### Pull Requests

- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3807/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3871/overview>
- <https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3890/overview>
