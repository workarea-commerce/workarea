---
title: Workarea 3.0.2
excerpt: Commit
---

# Workarea 3.0.2

## Suppresses Analytics Callbacks for Admins

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6f89f254c384a1eece84901a89c288279c87f972)

Workarea 3.0.2 does not fire analytics callbacks when the current user is an administrator. This change reduces the amount of unwanted non-customer data being sent to 3rd party analytics services. The change affects _workarea/storefront/modules/analytics.js_ in the Storefront, which now looks for an `analytics=false` cookie. This cookie is managed in _controllers/workarea/authentication.rb_ in Workarea Core. If your application is overriding the Storefront analytics JS, you should update your copy to suppress callbacks when the cookie is set.

## Adds Index to Payment Transaction Action

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5d091f991e6cba89926fc1168b9155dca5a63f2e)

Workarea 3.0.2 declares an index on `Workarea::Payment::Transaction#action`.

```
# workarea/core/app/models/workarea/payment/transaction.rb

module Workarea
  class Payment
    class Transaction
      include ApplicationDocument

      # ...

      field :action, type: String

      # ...

      index({ action: 1 })

      # ...
    end
  end
end
```

To benefit from this index, you must create it within each environment. The following command will create the index. Applications using [Workarea OMS](https://stash.tools.weblinc.com/projects/WL/repos/workarea-oms/browse) **must** create this index.

```
bin/rails db:mongoid:create_indexes
```

## Removes Grid Component from Taxonomy Content Blocks

[Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2468/overview)

Workarea 3.0.1 uses the _grid_ component for the layout of taxonomy content blocks in the Storefront. However, these blocks typically require a custom layout, requiring the removal of the grid component. Workarea 3.0.2 removes the grid component from these blocks, replacing `grid __cell` elements with `taxonomy-content-block__ container` elements in the following Storefront partials.

- workarea/storefront/content\_blocks/\_taxonomy.haml
- workarea/storefront/content\_blocks/\_three\_column\_taxonomy.haml
- workarea/storefront/content\_blocks/\_two\_column\_taxonomy.haml

Also affected are the _workarea/storefront/components/\_taxonomy\_content\_block.scss_ Storefront stylesheet and the `Workarea::Storefront::ContentHelper#render_image_with_link` Storefront helper method.

Run [Workarea Upgrade](https://stash.tools.weblinc.com/projects/WL/repos/workarea-upgrade/browse) or review the pull request to determine if your application is affected.

## Reduces Focus Styles in Storefront

[Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2460/overview)

Workarea 3.0.1 highlights almost all focusable elements in the Storefront when those elements are focused (via the _focus-ring_ Sass mixin). This is an oversight and causes unwanted focus rings. Workarea 3.0.2 reduces the affected elements to `input`, `textarea`, and `select`.

This change also removes the _workarea/storefront/generic/\_accessibility.scss_ stylesheet from the Storefront, and removes its inclusion within the Storefront's _workarea/storefront/application.scss.erb_ manifest.

## Fixes Styles for Secondary Nav Component

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/368f9775a183bf3696cb2884ab35b08aaa56ed0a)

Workarea 3.0.2 updates selectors in the _workarea/storefront/components/\_secondary\_nav.scss_ Storefront stylesheet to match the structure of the _secondary-nav_ component, as it is used in the _workarea/storefront/shared/\_left\_navigation.html.haml_ partial. The commit also makes minor changes to the default styles for this component.

## Normalizes Padding in Storefront Page Aside

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0c822dc843282771aac3b2f2bf14166247cadad1)

Workarea 3.0.2 removes padding from the following selectors to apply consistent default spacing within the Storefront page aside.

- `.result-filters__section`
- `.recent-views--aside .recent-views__section`

The following Storefront stylesheets are affected.

- workarea/storefront/components/\_recent\_views.scss
- workarea/storefront/components/\_result\_filters.scss

## Aligns Test Class Names with File Names

[Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2477/overview), [Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2478/overview), [Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6933e8b7b9a3982f696ea0a60dcb00b71060c026)

Workarea 3.0.2 renames several test classes and test file names to bring them into alignment. If your application is decorating any of the affected classes, you will need to update your decorators. Run [Workarea Upgrade](https://stash.tools.weblinc.com/projects/WL/repos/workarea-upgrade/browse) or review the pull requests to see which classes and files are affected.

## Changes Admin Append Points

[Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2469/overview), [Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2476/overview), [Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2472/overview), [Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5d091f991e6cba89926fc1168b9155dca5a63f2e)

Workarea 3.0.2 adds append points to the following Admin views and removes an append point from _workarea/admin/payments/show.html.haml_. If your application is overriding any of these views, you may wish to add these append points so that partials from plugins are rendered appropriately.

- workarea/admin/orders/attributes.html.haml
- workarea/admin/prices/edit.html.haml
- workarea/admin/prices/index.html.haml
- workarea/admin/prices/new.html.haml
- workarea/admin/create\_pricing\_discounts/setup.html.haml
- workarea/admin/catalog\_products/\_aux\_navigation.html.haml
- workarea/admin/fulfillments/show.html.haml
- workarea/admin/orders/show.html.haml
- workarea/admin/payments/show.html.haml

To see the changes, run [Workarea Upgrade](https://stash.tools.weblinc.com/projects/WL/repos/workarea-upgrade/browse) or review the pull requests/commits.

## Allows Decoration of Generator Tests

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e1d69e218a3bcde4727de5f34175ba0811fb6004)

Workarea 3.0.2 adds a new test class, `Workarea::GeneratorTest`. This class inherits from `Rails::Generators::TestCase`, but allows for test decoration by plugins and applications. The commit changes all generator tests to inherit from `Workarea::GeneratorTest` instead of `Rails::Generators::TestCase`.

## Improves Note on Shipping Services Regions Field in Admin

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cf881995746af71b4b2b010c19c45b7b3abeeaa3)

Workarea 3.0.2 improves the note for the _Regions_ field within the shipping services _new_ and _edit_ screens in the Admin. The change modifies _workarea/admin/shipping\_services/new.html.haml_ and _workarea/admin/shipping\_services/edit.html.haml_ to use a new translation key: `workarea.admin.shipping_services.regions_note`. If your application is overriding either of these views, you may want to update your copies.

## Fixes Invalid HTML for the Social Networks Content Block Type

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dbc22fe084cf596226a1fb6f5794a5e443a53a58)

Workarea 3.0.2 fixes invalid HTML in the _workarea/storefront/content\_blocks/\_social\_networks.html.haml_ Storefront partial by wrapping the `li` elements in a `ul`. If your application is overriding this partial, you should make the same change in your copy.

## Adds Test Case Methods to Determine Mount Point

[Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2461/overview)

Workarea 3.0.2 adds the `Workarea::TestCase.running_in_gem?` and `Workarea::TestCase#running_in_gem?` predicate methods to all test case classes. These methods return `true` when a test is run within the engine's embedded dummy app rather than a Workarea application. These methods allow for code branching, such as when configuring the location of [vcr](https://github.com/vcr/vcr) cassettes.

```
# workarea-testing/lib/workarea/test_case.rb

module Workarea
  class TestCase < ActiveSupport::TestCase
    # ...

    delegate :running_in_gem?, to: :class

    def self.running_in_gem?
      Rails.root.to_s.include?('test/dummy')
    end
  end
end
```

## Enumerates Configured Card Types in Payment Icon Style Guide

[Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2454/overview)

The Storefront's _payment icon_ component provides a modifier for each configured credit card type. The style guide for this component displays each modifier, an excerpt of which is shown below.

![payment-icon storefront style guide](images/payment-icon-storefront-style-guide.png)

While Workarea 3.0.0 employs static code examples for these modifiers, Workarea 3.0.2 enumerates `Workarea.config.credit_card_issuers`, producing a code example for each member of that collection. This change ensures each accepted card type is represented on the style guide. It also allows plugins and applications to extend the style guide without overriding the partial.

If your application is overriding this view, you may want to update the copy in your application to ensure your style guide stays in sync with the configured card types.

## Adds Admin Helper Method for Content Block Icons

[Pull Request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2471/overview)

Workarea 3.0.2 adds the `Workarea::Admin::ContentBlockIconHelper#content_block_icon` helper method to render content block icons in the Admin. The helper mimics the signature of `InlineSvg::ActionView::Helpers#inline_svg`, and uses that method in its implementation. The new helper method is needed to allow for a default icon for custom block types that do not provide their own icon. The default icon file is _workarea/admin/content\_block\_types/custom\_block.svg_.

Within the following Admin views, `content_block_icon` replaces `inline_svg`.

- workarea/admin/content/\_form.html.haml
- workarea/admin/content\_blocks/index.html.haml

The change also adds a `type` method to `Workarea::Content::Preset`. The method returns an instance of `Workarea::Content::BlockType` and is needed to provide access to `Workarea::Content::BlockType#icon`, which returns the path to the block type's icon file.

```
# workarea-core/app/models/workarea/content/preset.rb

module Workarea
  class Content
    class Preset
      include ApplicationDocument

      # ...

      # The {Workarea::Content::BlockType} that this block is. See documentation
      # for {Content.define_block_types} for info how to define block types.
      #
      # @return [Workarea::Content::BlockType]
      #
      def type
        Workarea.config.content_block_types.detect { |bt| bt.id == type_id }
      end
    end
  end
end
```

The pull request also updates Workarea's dependency on [inline\_svg](https://rubygems.org/gems/inline_svg) to `'~> 1.2.1'`.

## Adds Helper Method to Test for Partials to Append

[Commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5d091f991e6cba89926fc1168b9155dca5a63f2e)

Workarea 3.0.2 adds the `Workarea::PluginsHelper#partials_to_append?` helper method, which returns `true` if any partials are registered to append to a given append point. The example below tests if there are any partials to append to `'admin.fulfillment_show_workflow_bar'` before appending the partials, allowing for conditional markup.

```
/ workarea-admin/app/views/workarea/admin/fulfillments/show.html.haml

/ ...

- if partials_to_append?('admin.fulfillment_show_workflow_bar')
  .workflow-bar
    .grid
      .grid __cell.grid__ cell--50
      .grid __cell.grid__ cell--50.align-right
        = append_partials('admin.fulfillment_show_workflow_bar', order: @order, fulfillment: @fulfillment)
```

