Workarea 3.5.25 (2020-12-23)
--------------------------------------------------------------------------------

*   Fix admin indexing for embedded model changes

    When embedded models are changed, their root documents weren't being
    reindexed for admin search. This PR ensures admin indexing happens
    correctly.

    Ben Crouse

*   Index search customizations, handle missing search models for changeset releasables

    WORKAREA-322

    Matt Duffy

*   Move release undo changeset building to sidekiq for large changesets

    WORKAREA-316

    Matt Duffy

*   Fix undo releases not causing models to reindex

    Because the changeset is the only getting saved when building an undo,
    admin reindexing for the affected models isn't happening. This change
    triggers callbacks to ensure any related side-effects happen.

    Ben Crouse

*   Use inline_svg fallback for missing releasable icons

    WORKAREA-310

    Matt Duffy

*   Simplify undo releases, allow multiple undo releases from a single release

    WORKAREA-316

    Matt Duffy

*   Update display of release changeset to handle large changesets

    WORKAREA-310

    Matt Duffy

*   Allow admin config array fields to define a values type

    WORKAREA-311

    Matt Duffy

*   Check if a releasable has a localized active field before redefining it

    If Workarea.config.localized_active_field is set to false, the active
    field is redefined for each Releasable model to ensure the configuration
    is honored. With inherited models like discounts, this can cause the
    redefintion of active multiple times causing it to override custom active
    behaviors for segments. Only redefining the method if its currently in
    the models localized_fields list should ensure this does not happen.

    WORKAREA-309

    Matt Duffy

*   Update releasable active test to work without localized active fields

    WORKAREA-309

    Matt Duffy



Workarea 3.5.24 (2020-12-22)
--------------------------------------------------------------------------------

Due to a mistake releasing this gem, it has been yanked. See v3.5.25 instead.



Workarea 3.5.23 (2020-11-25)
--------------------------------------------------------------------------------

*   Bump jquery-rails to patch XSS vulnerabilities


    Ben Crouse

*   Add warning to inform developers why redirects aren't working locally

    This has confused developers a couple of times, so hopefully adding a
    warning will help.

    Ben Crouse

*   Fix Elasticsearch indexes when changing locales in tests

    This ensures the proper search indexes are in place when you switch
    locales for an integration test.

    Ben Crouse

*   Prevent Error on Missing Custom Template View Model Class

    Typically, custom product templates use their own subclass of
    `Workarea::Storefront::ProductViewModel`, but this isn't supposed to be
    necessary if there's no custom logic that needs to be in the view model
    layer. However, when developers tried to add a custom template without
    the view model, they received an error. To prevent this, Workarea will
    now catch the `NameError` thrown by `Storefront::ProductViewModel.wrap`
    in the event of a custom product template not having a view model
    defined.

    WORKAREA-304

    Tom Scott

*   Fix Missing Instance Variable In Cart Items View

    The `@cart` instance variable was only being conditionally defined if
    `current_order.add_item` succeeded. This caused an error if `#add_item`
    happens to fail when calling `POST /cart/items` from the storefront,
    resulting in a 500 error. To prevent this error, the definition of this
    variable has been moved above the condition.

    WORKAREA-303

    Tom Scott

*   Shorten index name

    Mongo will raise when index names exceed a certain length. For example,
    having a long Workarea.config.site_name could cause this.

    Ben Crouse

*   Fix missing jump to positions breaking jump to

    Ruby raises when nil is compared, so default these values.

    Ben Crouse



Workarea 3.5.22 (2020-11-03)
--------------------------------------------------------------------------------

*   Only merge recent views on tracking updates

    Merging all metrics has caused a lot of confusion in testing, and the
    only core use-case this matters for is recent views. So this change only
    merges recent views when metrics are updated.

    Ben Crouse

*   Delete old user metrics after merging

    This will ensure the consistency of user-based reports.

    Ben Crouse

*   Be more specific when matching reverts in changelogs

    This change will allow starting commit messages with the word Revert
    without the changelog task ignoring the commit.

    Ben Crouse

*   Add metrics explanation for users

    This additional explanation is meant to communicate why customer
    insights may occasionally mismatch with the orders card.

    Ben Crouse

*   Add Note To Category Default Sort Edit

    The selected `default_sort` of a category will be always used in the
    storefront. If the category contains featured products, this sort will
    be labelled "Featured", and this might prove confusing to some admins.
    To resolve this, add a note just below the dropdown indicating what will
    occur when products are featured in the category.

    WORKAREA-289

    Tom Scott

*   Include referrer in ending impersonation redirect fallbacks

    When ending an impersonation, this changes to allow redirecting to the referrer
    if the return_to parameter isn't present. Better UX for ending
    impersonations while working in the admin.

    WORKAREA-293

    Ben Crouse

*   Merge metrics when a user's email is updated

    This ensures the old metrics info stays around after the email change.

    WORKAREA-294

    Ben Crouse

*   Fix release changeset indexing code duplication

    Cleanup duplicate logic so decoration for product indexes can happen in
    a single place.

    WORKAREA-292

    Ben Crouse



Workarea 3.5.21 (2020-10-14)
--------------------------------------------------------------------------------

*   Prevent Clearing Out Navigable When Saving Taxons

    The `WORKAREA.newNavigationTaxons` module was looking in the wrong place
    for the selected navigable item, therefore the `selected` var would
    always return `undefined`, causing the `navigable_id` param to be
    blank every time. Fix this by querying for the correct DOM node (the
    `[data-new-navigation-taxon]` element) and pulling the selected ID from
    its data.

    WORKAREA-297
    Fixes #534

    Tom Scott

*   Make CSV test more robust to decorations

    Improve this test so decorating ApplicationDocument to add a field won't
    cause the test to break.

    Ben Crouse

*   Refactor product entries to allow accessing logic per-product

    This allows easier reuse of this logic, specifically for the site
    builder plugin we're working on.

    Ben Crouse

*   Fix Test That Will Never Fail

    This test for the `StatusReporter` worker asserted `2`, which will never
    fail because `2` will never be falsy. Updated the assertion to use the
    intended `assert_equals`

    Tom Scott

*   Fix skip services

    This was broken due to the admin-based configuration looking for a Mongo
    connection.

    Ben Crouse

*   Try to clarify how to use search synonyms

    There has been repeated confusion around why/how to use synonyms, so this is an attempt to clarify.

    Ben Crouse



Workarea 3.5.20 (2020-09-30)
--------------------------------------------------------------------------------

*   Rename Admin::ProductViewModel#options to avoid conflict with normal options method


    Matt Duffy

*   Improve UX of default search filter sizes


    Ben Crouse

*   Improve clarity of discount verbiage

    This hopes to address some recent confusion around how the discount
    works.

    Ben Crouse

*   Fix safe navigation method calls

    This will raise if the menu content is nil.

    Ben Crouse

*   Update preconfigured session length to match recommendations


    Ben Crouse

*   Remove unnecessary Capybara blocking when testing content is not present

    Capybara's `page.has_content?` and similar methods block until a timeout
    is reached if they can't find the content. This is not what we want if
    we're checking that the content does *not* exist, switch to using
    `refute_text` in these scenarios.

    The timeout is equal to the number of installed plugins and we have
    client apps with 30+, which means that the 38 instances removed in this
    commit could represent twenty minutes of unnecessary blocking in some
    scenarios.

    Thanks to James Anaipakos in
    https://discourse.workarea.com/t/capybara-refute-assertions-waiting-full-default-wait-time/1610
    for alerting me to the issue.

    Jonathan Mast

*   Handle `nil` Percentages in Tax Rates UI

    The `TaxApplication` module already handles percentages that are not
    present, but the tax rates UI expects values there. This results in some
    avoidable 500 errors within admin when you blank out a tax rate
    percentage field. To resolve this, Workarea now makes sure that all
    percentages are of type `Float`, so they can be displayed as "0%" in
    the admin whenever a `nil` value is encountered.

    WORKAREA-278

    Tom Scott

*   Fix Precision of Tax Rates UI

    The `:step` values of the new/edit forms and precision configuration for
    `#number_to_percentage` were not only rounding certain tax rates to an
    incorrect number, but were also showing a bunch of insignificant zeroes
    in the admin for tax rates. To resolve this, configure
    `#number_to_percentage` to have 3-decimal precision, and strip all
    insignificant zeroes from the display, leaving the admin with a much
    nicer percentage display than what was presented before.

    WORKAREA-278

    Tom Scott

*   Redirect back to the previous page after stopping impersonation

    Currently we redirect to the user's show page, which can be pretty
    disorienting.

    Ben Crouse



Workarea 3.5.19 (2020-09-16)
--------------------------------------------------------------------------------

*   Fix Editing Product Images in Admin

    When an image does not include an option, the edit page errors because
    `#parameterize` cannot be called on `@image.option` since that is
    returning `nil`. Additionally, the line of code in which this is called
    is meant to set an ID attribute on the element for which an image is
    rendered. There doesn't seem to be anything in our codebase that uses
    this, and furthermore since there's no validation for unique options per
    set of product images, this could cause a duplicate ID error in certain
    scenarios. To resolve this, the ID attribute has been removed from this
    `<img>` tag.

    WORKAREA-254

    Tom Scott

*   Improve display of disabled toggles

    When a toggle button is disabled, it should reflect that visually
    instead of just looking like it should be functional.

    Ben Crouse

*   Add config to allow defining a default tax code for shipping services

    WORKAREA-256

    Matt Duffy

*   Fix incorrect tracking and metrics after impersonation

    Not managing the email cookie and unintentional merging of metrics leads
    to incorrect values in the admin.

    Ben Crouse

*   Remove CSV Messaging For Options Fields

    This removes the "Comma separated: just, like, this" messaging and
    tooltip that explains more about comma-separated fields for filters and
    details. Options do not have these same constraints, and this help
    bubble just serves as a point of confusion for admins.

    WORKAREA-266

    Tom Scott

*   Update inventory sku jump to text

    Co-authored-by: Ben Crouse <bcrouse@workarea.com>

    Matt Duffy

*   Make Order::Item#fulfilled_by? the canonical check of item's fulfillment

    Methods such as #shipping? and #download? defined from available
    fulfillment policies now call #fulfilled_by rather than being called
    by it. This allows #fulfilled_by? to be modified to support more
    complex scenarios like bundled items from kits.

    WORKAREA-273

    Matt Duffy

*   Update admin views for consistent display of inventory availability

    WORKAREA-262

    Matt Duffy



Workarea 3.5.18 (2020-09-01)
--------------------------------------------------------------------------------

*   Set Default Inventory Policy to "Standard" in Create Product Workflow

    When creating a new product through the workflow, setting the
    "Inventory" on a particular SKU would still cause the `Inventory::Sku`
    to be created with the "Ignore" policy rather than "Standard". Setting
    inventory on a SKU now automatically causes the `Inventory::Sku` record
    to be created with a policy of "Standard" so as to deduct the given
    inventory to the varaint. When no inventory is given, Workarea will fall
    back to the default of "Ignore".

    WORKAREA-265

    Tom Scott

*   Fix Admin Configuration for Email Addresses

    The hard-coded `config.email_from` and `config.email_to` settings
    conflict with the out-of-box administrable configuration for the "Email
    From" and "Email To" settings. This causes a warning for admins that
    explain why the settings on "Email To" and "Email From" won't take
    effect. Since the whole purpose of moving these settings to admin
    configuration was to let admins actually change them, the
    `config.email_from` and `config.email_to` settings have been removed
    from both default configuration and the `workarea:install` generator.

    WORKAREA-270

    Tom Scott

*   Add Permissions To Admin::ConfigurationsController

    Admins without "Settings" access are no longer able to access the
    administrable configuration settings defined in a Workarea application's
    initializer.

    WORKAREA-261

    Tom Scott

*   Handle missing or invalid current impersonation

    This surfaced as a random failing test, this should make the feature more robust.

    Ben Crouse

*   Fix wrong sorting on default admin index pages

    The query for an admin index page can end up inadvertantly introduce a
    scoring variation, which can cause results to not match the `updated_at`
    default sort.

    This makes `updated_at` the true default sort, and allows the general
    admin search to override, where `_score` is still the desired default
    sort.

    Ben Crouse

*   Visually improve changesets card when no changesets


    Ben Crouse

*   Add modifier for better disabled workflow button display

    This makes it visually clearer that a workflow button is disabled.

    Ben Crouse

*   Add asset index view heading append point


    Ben Crouse

*   Pass user into append point


    Ben Crouse

*   Add append point for storefront admin toolbar


    Ben Crouse

*   Add Rack env key for checking whether it's an asset request

    This is useful for plugins like site builder. This also reduces
    allocations by moving the regex into a constant and consolidates the
    check from multiple spots.

    This also skips force passing Rack::Cache for asset requests if you're
    an admin (minor performance improvement).

    Ben Crouse

*   Add param to allow disabling the admin toolbar in the storefront

    Used in the site builder plugin. Add disable_admin_toolbar=true to the
    query string to turn off the admin toolbar for that page.

    Ben Crouse

*   Add minor remote selects features to support site builder

    This includes an option for the dropdown parent, and an option to allow
    autosubmitting a remote select upon selection.

    Ben Crouse

*   Fix constant loading error related to metrics

    Sometimes an error will be raised when Workarea middleware is doing
    segmentation logic around `Metrics::User`.

    Ben Crouse

*   Move rake task logic into modules

    This will allow decorating this logic for plugins or builds that need
    to. For example, site builder needs to search-index resources that are
    unique per-site.

    Ben Crouse

*   Add append point for admin top of page


    Ben Crouse



Workarea 3.5.17 (2020-08-19)
--------------------------------------------------------------------------------

*   Fix missing release changes for CSV importing with embedded models

    Trying to update an embedded model via CSV import with a release causes
    an existing changeset for the root model to get destroyed. This happens
    because the CSV import calls `#save` on the root, which has no changes
    so it removes the changeset.

    This patch fixes by iterating over the models the CSV row might affect
    and calling `#save` on the embedded ones first (if necessary) to ensure
    the changesets get correctly created and to avoid calling the save on
    the root without changes which removes the existing changeset.

    Ben Crouse

*   Return Status of `Checkout#update`

    For APIs and other consumers of the Checkout model, return a boolean
    response from the `#update` method to signify whether the operation
    succeeded or failed. This response is used directly in the API to return
    an `:unprocessable_entity` response code when an update operation fails.

    WORKAREA-253

    Tom Scott

*   Remove port from host configuration in installer

    Ports aren't part of hosts, this causes problems when the value is used
    like a true host.

    This PR also fixes mailer links with missing ports as a result of this
    change.

    Ben Crouse

*   Bump Chartkick to fix bundler audit warning

    The vulnerability won't affect Workarea in use, but it'll be easier to fix builds doing this.

    Ben Crouse

*   Allow inquiry subjects to be localized

    WORKAREA-238

    Matt Duffy

*   Update inquiry subject documentation

    WORKAREA-238

    Matt Duffy

*   Remove order summary append point from mailer that is meant for storefront views


    Matt Duffy



Workarea 3.5.16 (2020-07-22)
--------------------------------------------------------------------------------

*   Add js module to allow inserting remote requests onto the page


    Matt Duffy

*   Configure Sliced Credit Card Attributes

    To prevent an unnecessary decoration of the `Workarea::Payment` class,
    the attributes sliced out of the Hash given to `Workarea::Payment#set_credit_card`
    is now configurable in initializers. This same set of attributes is also
    used in the `Users::CreditCardsController`, so the configuration will be
    reused when users are attempting to add a new credit card to their
    account.

    WORKAREA-257

    Tom Scott

*   Setup PlaceOrderIntegrationTest in a Method

    Currently, decorating the PlaceOrderIntegrationTest to edit the way its
    set up (such as when adding an additional step) is impossible, you have
    to basically copy everything out of the `setup` block and duplicate it
    in your tests. Setup blocks should be methods anyway, so convert this to
    a method and allow it to be decorated in host apps.

    Tom Scott

*   Fix `Hash#[]` Access On Administrable Options

    Accessing administrable options on `Workarea.config` can produce
    unexpected results if you don't use the traditional method accessor
    syntax. For example, an admin field like this:

    ```ruby
    Workarea::Configuration.define_fields do
    field :my_admin_setting, type: :string, default: 'default value'
    end
    ```

    ...will only be available at `Workarea.config.my_admin_setting`:

    ```ruby
    Workarea.config.my_admin_setting # => "default value"
    Workarea.config[:my_admin_setting] # => nil
    ```

    To resolve this, the code for fetching a key's value from the database
    has been moved out of `#method_missing` and into an override of `#[]`.
    [Since the OrderedOptions superclass already overrides this][1] to call
    `#[]`, we can safely move this code and still maintain all functionality.

    [1]: https://github.com/rails/rails/blob/fbe2433be6e052a1acac63c7faf287c52ed3c5ba/activesupport/lib/active_support/ordered_options.rb#L41-L58

    Tom Scott

*   Fix race condition when merging user metrics


    Ben Crouse

*   Improve Content Area Select UX

    Remove the current content name and replace it with a static label
    indicating what the `<select>` menu to the right of it is selecting,
    which is the current content area. This UI only displays when there are
    multiple areas for a given `Content`.

    WORKAREA-244

    Tom Scott

*   Changes to support package product kits


    Matt Duffy

*   Update inventory and fulfillment sku policy info text, allow appending


    Matt Duffy



Workarea 3.5.15 (2020-07-07)
--------------------------------------------------------------------------------

*   Patch Jbuilder to Support Varying Cache

    Previously, admins were not able to see up-to-date data in API requests
    due to the `#cache!` method in Jbuilder not being patched to skip
    caching when an admin is logged in. To resolve this, Workarea now
    applies the same patch to Jbuilder as it does to ActionView. Reading
    from the cache is now skipped if you're logged in as an admin, and cache
    keys are appended with the configured `Cache::Varies` just the same as
    in regular Haml views.

    WORKAREA-243

    Tom Scott

*   Bump rack version

    Fixes CVE-2020-8184

    Ben Crouse

*   Add Permissions Append Point to User Workflow

    This allows a plugin (such as API) to specify permissions categories when
    admins are either editing or creating a user.

    WORKAREA-240

    Tom Scott



Workarea 3.5.14 (2020-06-25)
--------------------------------------------------------------------------------

*   Reset Geocoder between tests

    This ensures individual tests monkeying around with Geocoder config will
    get restored before the next test runs.

    Ben Crouse

*   Fix indexing categorization changesets for deleted releases

    A category can have orphan changesets (from deleted releases) that cause
    an error when indexing the percolation document for that category.

    Ben Crouse

*   Disable previewing for already published, unscheduled releases

    Due to the previewing in the search index, previewing a published and
    unscheduled release can cause issues that require it to go through
    scheduling to get reindexed.

    Ben Crouse

*   Use Display Name For Applied Facet Values

    When rendering the applied filters, wrap the given facet value in
    the `facet_value_display_name` helper, ensuring that the value rendered
    is always human readable. This addresses an issue where if the applied
    filter value is that of a BSON ID, referencing a model somewhere, the
    BSON ID was rendered in place of the model's name.

    WORKAREA-122

    Tom Scott

*   Fix Segments Workflow Setup Duplication

    The setup form for the new custom segment workflow did not include the
    ID of an existing segment (if persisted) in the form when submitted,
    causing multiple duplicate segment records to be created when users go
    back to the setup step in the workflow. None of the other steps are
    affected because the ID appears in the URL, but the setup step does a
    direct POST to `/admin/create_segments`, thus causing this problem.

    WORKAREA-219

    Tom Scott

*   Fix index duplicates after a release is removed

    When a release is deleted, its changes must be reindexed to fix previews
    for releases scheduled after it. This manifests as duplicate products
    when previewing releases.

    Ben Crouse

*   Fix Promo Code Counts in Admin

    Previously, promo codes could only be generated once through the admin,
    so rendering the count of all promo codes as the count requested to be
    generated was working out. However, as CSV imports and API updates became
    more widespread, this began to break down as the `#count` field would
    have to be updated each time a new set of promo codes were added.
    Instead of reading from this pre-defined field on the code list, render
    the actual count of promo codes from the database on the code list and
    promo codes admin pages.

    WORKAREA-199

    Tom Scott

*   Fix indexing after a release publishes

    Due to potential changes in the index, publishing a release can result
    in duplicate products when previewing.

    Ben Crouse

*   Update queue for release reschedule indexing

    This should be in the releases queue, which has top priority. This will
    help decrease the latency to accurate previews.

    Ben Crouse



Workarea 3.5.13 (2020-06-11)
--------------------------------------------------------------------------------

*   Fix duplicate products in release previews for featured product changes

    When featured product changes stack in a release, duplicates will show
    when previewing. This is due to the product's Elasticsearch documents
    missing changeset IDs for releases scheduled after the release that
    document is for. This fixes by indexing those release IDs as well.

    Note that this will require a reindex to see the fix immediately. But
    there's no harm in letting it roll out as products gradually get
    reindexed.

    Ben Crouse

*   Fix reindexing of featured product resorting within a release

    Resorting featured products within a release causes an inaccurate set of
    changes from Mongoid's perspective, since it is only looking at what's
    live vs what's going to be released. The changes within the release
    aren't represented. This can manifest as incorrect sorts when previewing
    in the storefront.

    Ben Crouse

*   Add additional append points to admin system.

    Adds append points to product details, product content, variant and inventory sku.

    Jeff Yucis

*   Bump Geocoder

    This fixes an irrelevant bundler-audit CVE warning, and adds/updates a bunch of Geocoder lookup options. See https://github.com/alexreisner/geocoder/blob/master/CHANGELOG.md for more info.

    Ben Crouse

*   Fix releases shifting day on the calendar when scrolling

    This was caused by legacy timezone code that's irrelevant since we
    shifted to a fix server-side timezone for the admin.

    Ben Crouse

*   Add QueuePauser to pause sidekiq queues, pause for search reindexing

    WORKAREA-236

    Matt Duffy

*   Add index for releasable fields on changets, correct order fraud index

    WORKAREA-235

    Matt Duffy

*   Handle error from attempting to fetch missing S3 CORS configuration

    WORKAREA-234

    Matt Duffy

*   Fix storefront indexing when releases are rescheduled

    When releases get rescheduled, the storefront index can end up with
    duplicate and/or incorrect entries. This adds a worker which updates the
    index with minimal querying/updating.

    Ben Crouse

*   Don't assume promo codes for indexing discounts

    A custom discount may be implemented that doesn't use promo codes.

    Ben Crouse

*   Bump rack-attack to latest version

    This fixes rack-attack keys without TTLs set piling up in Redis. This has caused hosting problems.

    Ben Crouse

*   Bump Kaminari dependency to fix security alert


    Ben Crouse

*   Fix query caching in Releasable

    When reloading a model to get an instance for a release, if the model
    had already been loaded, a cached version of the model was returned.
    This causes incorrect values on the instance you thought you were getting
    for a release.

    This first manifested as a bug where adding a featured product that
    had a release change to make it active caused reindexing to make it
    active but it shouldn't have been.

    Ben Crouse

*   Fix incorrect shipping options error flash message

    A flash error incorrectly showed when the order doesn't require shipping,
    and addresses are updated.

    Ben Crouse



Workarea 3.5.12 (2020-05-26)
--------------------------------------------------------------------------------

*   Fix incorrect import errors

    When an import fails due to a missing `DataFile::Import` document, the
    `ProcessImport` worker will raise a nil error due to the ensure. This
    fixes by ensuring the `DocumentNotFound` error gets raised.

    Ben Crouse

*   Remove caching from direct upload CORS requests

    The caching continues to give us problems, and this isn't a high-traffic
    part of the system so there isn't a practical need for it.

    Ben Crouse

*   Add paranoid fallback for segment metrics lookup

    Although this should never happen, giving a user incorrect segments
    could have important consequences. If the email cookie is removed or
    missing for some other reason, it doesn't hurt to fallback to looking up
    based on the user model (even though this is an additional query) when
    we know they're logged in.

    Ben Crouse

*   Don't set a blank tracking email in checkout

    Doing this has the potential to create an incorrect tracking email,
    which could cause a visitor's segments to change in checkout.

    Ben Crouse



Workarea 3.5.11 (2020-05-13)
--------------------------------------------------------------------------------

*   Rename index to avoid conflicts in upgrade

    We changed the abaondoned orders index so trying to create indexes after
    upgrading will cause a conflict due to different indexes with the same
    name. This renames the index to fix that.

    Ben Crouse

*   Fix comment subscription messaging

    Also improves UI to move the secondary action of
    subscribing/unsubscribing out of the main area.

    Ben Crouse

*   Correct/clarify Dragonfly configuration warning


    Ben Crouse

*   Remove extra order ID cookie

    No need for the extra cookie if the order isn't persisted. Note this
    doesn't actually affect functionality.

    Ben Crouse



Workarea 3.5.10 (2020-04-28)
--------------------------------------------------------------------------------

*   Fix bugs with per_page used in page calculation for search queries

    Even though this shouldn't come from the outside world, it's easy and
    best to ensure per_page is always a valid number.

    Ben Crouse

*   Skip localized activeness test when localized active fields are off

    Fixes #421

    Ben Crouse

*   Fix accepting per_page param from outside world

    Page size is the most important factor in performance for browse pages,
    so we don't want these exposed to the outside world out-of-the-box.

    Ben Crouse

*   Update grammar for consistency


    Ben Crouse

*   Corrected no_available_shipping_options translation typo (#418)


    JurgenHahn

*   Fix fullfilment shipped mailer template

    Fullfilment shipped mailer template is using cancellation header.

    heyqule

*   Improve visual design of most discounted products insight


    Ben Crouse

*   Change HashUpdate to use the setter instead of mutation

    Simply mutating the value doesn't work when the field is localized.
    Mongoid's localization behavior only kicks in when you use the setter.

    Ben Crouse

*   Allow setting locale fallbacks for a test

    This is useful if you want to test fallback behavior. Tests in base
    should be agnostic to whether fallbacks are available or not.

    Ben Crouse

*   Fix locale fallback getting unexpectedly autloaded

    This can happen in the middle of a test suite, causing apparently random
    test failure. This freedom patch prevents fallbacks from autoloading.
    We want to let the implementation make that decision.

    Ben Crouse


Workarea 3.5.9 (2020-04-15)
--------------------------------------------------------------------------------

*   Fix harded JS path for admin jump to dropdown

    This prevents locale from being included in the path to load results.
    Ben Crouse

*   Fix index serialization not happening per-locale

    Previously, indexing was using the same document per-locale. This was
    masked by Mongoid loading data from the cached document to look correct
    in most browse scenarios. This fixes it to serialize per-locale so each
    locale has a separate representation of the document.
    Ben Crouse

*   Fix Mongoid not returning defaults for localized fields

    If a locale is missing from the translations hash, Mongoid returns nil
    instead of the default specified on the field. That causes all kinds of
    errors.
    Ben Crouse

*   Fix duplicate key errors in metrics synchronization

    It's important this be kept in sync as real-time as possible, so we need
    to avoid the Sidekiq retry delay where possible.
    Ben Crouse

*   Fix index serialization not happening per-locale

    Previously, indexing was using the same document per-locale. This was
    masked by Mongoid loading data from the cached document to look correct
    in most browse scenarios. This fixes it to serialize per-locale so each
    locale has a separate representation of the document.
    Ben Crouse

*   Fix Mongoid not returning defaults for localized fields

    If a locale is missing from the translations hash, Mongoid returns nil
    instead of the default specified on the field. That causes all kinds of
    errors.
    Ben Crouse

*   Tighten up segment geolocation matching rule

    This was playing a little fast and loose with matching, causing CA to
    match for California and Canada, IL to match for Illinois and Israel,
    etc.

    Matching only based on IDs chosen from the UI fixes these problems.
    Ben Crouse

*   Don't include locale in hidden fields for switching locales

    This can result in duplicate and conflicting locale params in the query
    string, which can cause the incorrect locale to be selected.
    Ben Crouse

*   Fix locale not passed through in return redirect when not in URL

    If a return_to parameter is generated without the locale, and a request
    includes a parameter to switch locale, the locale is dropped causing the
    request to revert to the default locale.

    The original observed bug is switching locale in content editing and
    seeing the request to save always redirect to the default locale.
    Ben Crouse

*   Fix locales not in cache varies

    To ensure all cache varies correctly by locales, it's important that
    locale be part of the Rack env's `workarea.cache_varies`. To do this, we
    need to move setting the locale into middleware (where the varies is
    set).
    Ben Crouse

*   Add missing append points to option-based product templates

    This append point was only in the generic template, but is useful for
    plugins.
    Ben Crouse

*   Fix dev env autoloading problem with Categorization

    Ben Crouse

*   Fix product search entries flattening

    When entries are overridden to return multiple results _and_ there are
    release changes for the product, the results weren't being flattened.

    Fixes #405
    Ben Crouse

*   Don't allow more than one valid password reset token per-user

    Ben Crouse



Workarea 3.5.8 (2020-03-31)
--------------------------------------------------------------------------------

*   Fix incorrect placeholder text

    Ben Crouse

*   Allow for blank index URLs in import emails

    This can happen for models without index pages, like wish lists.
    Ben Crouse

*   Remove unneeded grid modifier

    Causes misalignment of the users index aux navigation append point.
    Ben Crouse

*   Update critical easymon checks

    Only elasticsearch, mongodb and redis are critical services for running
    the application.
    Eric Pigeon

*   Sort jump to results by last updated_at (within each type)

    This adds updated_at as a sort in jump to so most recent results show at
    the top within their type. The types are still sorted the same.
    Ben Crouse

*   Force autoloading of BulkIndexProducts

    app/workers/workarea/bulk_index_products.rb isn't getting autoloaded by
    Rails. This causes a NameError to be raised for admin actions like
    updating a product in the development environment.

    This quick and dirty hack should be tested to see if it can be removed
    after the update to Zeitwerk.
    Ben Crouse

*   Fix missing relation changesets in storefront indexing

    This shows as duplicate products when previewing release changes to
    related resources like pricing. This would require reindexing to take
    effect.

    WORKAREA-223
    Ben Crouse

*   Handle missing price in sell_price method itself

    Fixes QA issue.

    WORKAREA-220
    Tom Scott



Workarea 3.5.7 (2020-03-17)
--------------------------------------------------------------------------------

*   Validate Date In Timeline Report Custom Events

    Ensure the hidden input storing the value for the dateTimePicker is
    `:required`, which prevents the form from saving. This value is also
    passed down into the template UI created by the JS module in order to
    make sure the user gets some visual feedback.

    WORKAREA-221
    Tom Scott

*   Handle Missing Price in Pricing SKUs Admin Index

    Ensure that price ranges in the pricing SKUs admin index can handle when
    there are no prices for the SKU.

    WORKAREA-220
    Tom Scott

*   Prevent Tracking Index Filters on JSON Requests

    When `.json` or Ajax requests are made against the admin, the
    `#track_index_filters` callback was previously saving off the full path,
    resulting in issues with the back-linking on the admin UI. To resolve
    this, Workarea no longer considers `.json` requests on the index page to
    be a valid `session[:last_index_path]`.

    WORKAREA-214
    Tom Scott

*   Add append point to user index page

    Jeff Yucis

*   Add pricing SKU admin append points and align views (#388)

    Ben Crouse

*   Improve admin jump to search result types

    This improves results by limiting the number of results that will show
    per-type. This allows the user to see a more diverse set of results
    instead of being overwhelmed by many matches in the top types.
    Ben Crouse



Workarea 3.5.6 (2020-03-03)
--------------------------------------------------------------------------------

*   Fix duplicate suggested searches

    This can heppen if Predictor and Elasticsearch both return a similar
    query suggestion.
    Ben Crouse

*   Generate weekly and monthly insights for historical data

    Seeds were only generating insights for a single previous week
    and month which caused some insights that rely on historical data
    to not be generated i.e. trending products and searches.

    WORKAREA-166
    Matt Duffy

*   Validate Custom Event Name

    Workarea now ensures that the "Name" of a custom event is filled in
    before submitting the form.

    WORKAREA-181
    Tom Scott

*   Divide By Units Sold in Average Price Calculation

    When calculating the average price for a product in its insights,
    Workarea was previously using the amount of orders the product appears
    in as a divisor. This will not show the correct average price of a
    product unless every order only has a quantity of 1, since it includes
    the total price of the item rather than its unit price. To make this
    number accurately reflect the average price paid per unit on a product,
    Workarea now uses the number of units sold as the divisor when
    calculating the average unit price of a product.

    WORKAREA-215
    Tom Scott

*   Randomize Addresses In Seeds

    Workarea now provides random values for street address, city, and state.
    All addresses are still in the US, however, so they will still validate
    with default configuration. This provides more diverse seed data that
    better reflects the real-life admin.

    WORKAREA-213
    Tom Scott

*   Render Setup When Link is Clicked in Segment Workflow

    The "Setup" page link sent users to the edit action, which has no
    template associated with it. This resulted in an `UnknownFormat` error
    appearing in development and a blank page in production. Workarea now
    renders the `:setup` action's template when going back to the setup
    page so this will render properly with the right information in the
    form.

    WORKAREA-182
    Tom Scott

*   Remove Changes Count in Releases Index

    The `#changesets_for_releasable` query cannot be optimized any further
    without using some kind of aggregation. Remove it from the index so it
    won't cause performance problems.

    WORKAREA-208
    Tom Scott

*   Display Price Range in Pricing SKUs Table

    The price display in the Pricing SKUs index is somewhat confusing, and
    would show different "Regular Price" data depending on the sale state of
    the SKU. To resolve this, replace the two price columns with "Sell
    Price", a column that renders a price range if there are multiple prices
    set on the SKU, and indicates that it's always going to show the price
    that a SKU is being sold for. Otherwise, it will just show the `#sell`
    price of the SKU.

    WORKAREA-311
    Tom Scott



Workarea 3.5.5 (2020-02-21)
--------------------------------------------------------------------------------

*   Stub S3 CORS for all integration tests

    It's annoying and unnecessary to have to stub this for every test that
    uses an asset picker.

    WORKAREA-209
    Ben Crouse

*   Don't store content block types in configuration

    Storing these in `Workarea.config` breaks when combined with the
    multisite plugin because `Workarea.config` gets copied to the site as
    part of the creating the site. Since creating the site happens during
    initialization and the blocks typesaren't set on `Workarea.config`, you
    end up with an empty configuration for block types.

    Storing these elsewhere ensures they are set regardless of how
    `Workarea.config` has been copied during initialization.

    Reported in Disource here: https://discourse.workarea.com/t/multi-site-and-testing/1778/3
    Ben Crouse

*   Add Append Point For Post Subtotal Adjustments

    This adds an append point right underneath the order subtotal and above
    the shipping total in the admin order attributes view.

    WORKAREA-183
    Tom Scott

*   Handle Deleted Categories in Category Options (#359)

    In the `options_for_category` method, Workarea did not previously check
    for whether a category exists, resulting in Mongoid throwing a
    `DocumentNotFound` error when encountering the method and causing a 500
    error in the real world. This has now been resolved by rewriting the
    code to check for whether the model was found before proceeding.
    `options_for_category` will now return an empty string early.

    WORKAREA-207
    Tom Scott

*   Fix Overwriting CORS Rules for S3 Direct Uploads

    Workarea previously replaced the existing CORS configuration on the S3
    bucket used for storing direct uploads with its own, which caused issues
    for environments that share an S3 bucket between servers (such as ad-hoc
    demo servers or low-traffic "all-in-one" instances). Instead of
    replacing the entire configuration, Workarea now reads the existing
    allowed hosts configuration and appends its own onto the end, preserving
    the configuration that previously existed. This should address the
    problem wherein if another server attempts a direct upload, it can
    revoke the access from previous servers to upload to the S3 bucket,
    since they were no longer in the CORS configuration.

    WORKAREA-209
    Tom Scott

*   Fix `#casecmp?` in Traffic Referrer Segment Rule

    This method call fails with a `TypeError` on any Ruby version lower than
    2.5.0, when the method was changed to support `nil` values in its
    arguments. To address this, call `#to_s` on all arguments passed into
    the `#casecmp?` calls in `Segment::Rules::TrafficReferrer`. This
    prevents an out-of-box test failure if you are running tests on Ruby
    2.4.x. Additionally, this commit adds a test matrix to the build that
    will ensure all code is tested against the latest versions of Ruby
    2.4.x and Ruby 2.6.x, and any other Ruby versions that the platform may
    support.

    WORKAREA-201
    Tom Scott

*   Add Guide for Installing Plugins

    This guide explains how to install a plugin in the Workarea platform.
    Although there may be some overlap with how this works in the rest of
    the Rails community, there is no mention of how to connect to our
    private gem server, which is not something most Rails developers know
    how to do. It addresses the lack of mentions for the
    `$BUNDLE_GEMS__WEBLINC__COM` environment variable in our documentation,
    which is a knowledge gap for newcomers to Workarea and/or using private
    gem servers.

    WORKAREA-204
    Tom Scott

*   Use correct page title for navigation menus index

    Luis Mercado

*   Drop Support for Ruby 2.4 and Below

    If one installs Workarea when running Ruby 2.4.x and below, a test will
    fail because it is expecting that `#casecmp?` will be able to handle
    `nil` arguments without throwing a `TypeError`. To address this,
    `Workarea::Core` now restricts the required Ruby version in the gem
    specification to 2.5.0 and above, dropping support for 2.4 and below,
    which at this point is also reaching EOL by the Ruby maintainers.

    WORKAREA-201
    Tom Scott

*   [DOCS] Add feedback mechanism to empty search results

    Improve the "no search results" UI to encourage users to open a GitHub
    issue explaining what documentation they aren't able to find.

    WORKAREA-177
    Chris Cressman

*   [DOCS] Fix order of steps to create new app

    The procedure in "Create a New Workarea App" fails at step 3:
    "Install Workarea into the Rails application", because that step
    requires MongoDB to be running.

    Fix the procedure by transposing steps 3 and 4, resulting in
    "Start Workarea service dependencies" running before "Install Workarea
    into the Rails application", which ensures MongoDB is available.

    I re-tested the entire procedure from scratch to ensure this works.

    WORKAREA-186
    Chris Cressman

*   [DOCS] Fix incomplete sentence in "Add a Fraud Analyzer"

    The doc "Add a Fraud Analyzer" contains an incomplete sentence
    describing the embedded `FraudDecision` document.

    Re-write the sentence to complete the thought and to link to the
    definition of the `FraudDecision` model.

    WORKAREA-176
    Chris Cressman

*   [DOCS] Update testing coverage in "Configuration"

    The "Configuration" doc has a section that covers changing configuration
    within tests. The section hasn't been updated for Workarea 3.5.

    Rather than update the content in-place, replace this coverage with a
    reference to the up-to-date coverage of this topic within the "Testing"
    section of the documentation.

    WORKAREA-175
    Chris Cressman

*   [DOCS] Overhaul "testing"

    WORKAREA-150
    Chris Cressman

*   Fix Sidekiq callbacks workers missing due to code reloaded

    This can cause missing workers in development, which causes callback
    workers which should be enqueued to be missing.
    Ben Crouse

*   Fix nil segment IDs

    This will fix errors raised when `active_segment_ids` are `nil`.
    Ben Crouse

*   Expose shipping service code in admin create and edit screens

    WORKAREA-190
    Jeff Yucis



Workarea 3.5.4 (2020-01-21)
--------------------------------------------------------------------------------

*   Ignore elements with no ID value when announcing duplicate IDs on-page

    WORKAREA.duplicateID was throwing a false positive exception when it
    would find elements containing an `id` attribute with no value
    specified. This behavior should be allowed, since empty ID values should
    pose no issues for the developer

    WORKAREA-184
    Curt Howard

*   Add link to edit the footer area of Layout content in Shortcuts

    We need to be more permissive in our linking to footer content areas
    from the header, since themes and builds can technically rename these
    areas. Now this link will point to the first content area that contains
    the word 'footer'.

    WORKAREA-145
    Curt Howard

*   Order release changesets during publishing, touch releasables after publish

    WORKAREA-164
    Matt Duffy



Workarea 3.5.3 (2020-01-07)
--------------------------------------------------------------------------------

*   Another hardcoded 2020 fix

    We've all learned our lesson, right?
    Ben Crouse

*   Pin version for wysihtml-rails

    Setting the version to 0.6.0.beta2 fixes the dependency issues that arose after the new version of Bundler.
    Jeff Yucis

*   Fix some references to 2020

    These were causing build failures. Assuming these fixes got lost in a
    merge.
    Ben Crouse

*   Reuse new Activity UI for main dashboard in Admin

    WORKAREA-138
    Curt Howard

*   Use the Rack session ID cookie value for user activity session IDs

    Rack >= 2.0.8 adds the idea private/public session IDs to prevent timing
    attacks where a session ID can be stolen. This is big for sessions stored
    in databases because the session can then be stolen.

    Workarea only supports a cookie session store, so we can continue to
    safely use the cookie value of the session ID for metrics lookups.

    You can learn more about the Rack vulnerability here:
    https://github.com/rack/rack/security/advisories/GHSA-hrqr-hxpp-chr3
    Ben Crouse

*   Disallow multiple form submissions throughout the Admin

    Disable any submit button within a form after submission to prevent
    multiple clicks. Also be less opinionated with disabled inputs and
    buttons, applying only an opacity and a cursor style, which allows
    relevant component's disabled states to more easily be inherited.

    WORKAREA-133
    Curt Howard

*   Fix Performance Test Task

    Instead of using a Boolean `true` value, use the String `"true"` so Ruby
    won't complain when running the task.

    WORKAREA-156
    Tom Scott



Workarea 3.5.2 (2019-12-19)
--------------------------------------------------------------------------------

*   Use the Rack session ID cookie value for metrics session IDs

    Rack >= 2.0.8 adds the idea private/public session IDs to prevent timing
    attacks where a session ID can be stolen. This is big for sessions stored
    in databases because the session can then be stolen.

    Workarea only supports a cookie session store, so we can continue to
    safely use the cookie value of the session ID for metrics lookups.

    You can learn more about the Rack vulnerability here:
    https://github.com/rack/rack/security/advisories/GHSA-hrqr-hxpp-chr3
    Ben Crouse

*   Don't bother with segmentation for SVG requests

    Ben Crouse

*   Fix bad method call in migrate task

    Ben Crouse

*   Add a Shortcut for editing the Footer to Admin

    WORKAREA-145
    Curt Howard



Workarea 3.5.1 (2019-12-17)
--------------------------------------------------------------------------------

*   Bump Puma version to fix security advisory

    See https://github.com/advisories/GHSA-7xx3-m584-x994 for more details.
    Ben Crouse

*   Exclude Update Timestamp From Imports

    Update the `:updated_at` timestamp to the current time when existing
    models are updated via an import, and ignore any settings of the
    `:updated_at` timestamp in JSON/CSV imports, as this can interfere with
    cache key generation.

    WORKAREA-126
    Tom Scott

*   Improve Redis configuration defaulting

    This makes Redis configuration a little more robust, allowing partial
    configuration values that will always end up falling back to defaults.
    Ben Crouse

*   Fix time zone querying for insights and reports

    Data was getting stored correctly, but not queried correctly. When
    building aggregations for MongoDB, the Mongoid logic to use UTC does not
    kick in since it's not going through the Mongoid DSL.

    This was the lowest impact fix. Changing how we store reporting_on will
    invalidate current data and not allow for changing timezones later.

    WORKAREA-135
    Ben Crouse

*   Fix Install Generator On Freshly Created App (#274)

    The `workarea:install` generator failed with an error finding the
    `Storefront::Engine` constant when it was run against a freshly
    generated Rails 5.2.3 application. To resolve this, require the
    necessary engines in **lib/workarea/core.rb** so the application loads
    properly the first time, and can run the generator.

    WORKAREA-134
    Tom Scott

*   [DOCS] Add/improve payment tender types documentation

    Existing payment tender type documentation is limited to the credit card
    tender type, covers only a portion of the implementation, and does not
    explain the concepts or provide context to those new to the platform.

    Replace and significantly expand coverage, providing 3 separate howtos:

    * Customize the Credit Card Tender Type
    * Implement a Primary Tender Type
    * Implement an Advance Payment Tender Type

    WORKAREA-13
    Chris Cressman

*   Remove Logstasher as a dependency (#273)

    Logstasher isn't required to run an instance of Workarea. This dependency is being moved to the `workarea-commerce_cloud` gem for hosting.
    Eric Pigeon

*   Fix password config not available when building indexes

    This causes a null value for expireAfterSeconds when creating indexes in
    Mongo.
    Ben Crouse

*   Add index for better redemption querying

    As suggested by the hosting team.
    Ben Crouse

*   Restrict release datetimepicker to dates in the future

    WORKAREA-65
    Matt Duffy

*   Add activate_with as a field on block drafts for compatibility

    Matt Duffy

*   Fix adding a new first content block hidden

    This can happen in certain release conditions

    WORKAREA-111
    Ben Crouse

*   Remove Releasable module from Content::BlockDraft

    WORKAREA-121
    Matt Duffy

*   Fix nil search customizations when inactive in ProductSearch

    WORKAREA-80
    Ben Crouse

*   Fix polymorphic embedded relations in CSV importing/exporting

    WORKAREA-120
    Ben Crouse



Workarea 3.5.0 (2019-11-26)
--------------------------------------------------------------------------------

*   Add caching to order item details results

    This was a point of bottleneck during recent Reformation load-testing.

    WORKAREA-102
    Ben Crouse

*   Add admin alert when a newer workarea version is available

    WORKAREA-107
    Matt Duffy

*   Base discount auto-deactivation on updated_at, expose auto_deactivate field

    WORKAREA-114
    Matt Duffy

*   Ensure UTF-8 Encoding of Data File Import Samples

    This ensures data file import samples are always treated as UTF-8.
    While Ruby itself does do this pretty well, and most browsers are good
    at guessing the file type/encoding based on the contents of the file,
    there might be some outliers that rely on metadata that's a bit more
    strictly adhered to. This change ensures that sample CSV/JSON files are
    delivered to the user as an attachment, and using the correct MIME type,
    so that they register as such when downloaded by the browser.
    Previously, all imports were showing as "TXT file" types, when they were
    really "CSV file" or "JSON file", and at least in Firefox, they were not
    downloading when you clicked the sample link. Instead, a new tab would
    open (since Firefox thinks it's a text file), and you have to refresh
    the page to actually get the browser to download the file.

    WORKAREA-77
    Tom Scott

*   Import UTF-8 CSVs With BOM Characters

    UTF-8 doesn't need a BOM in order to start or end a file, but these
    characters can end up in CSVs generated by older software that doesn't
    have great support for Unicode. As a result, if a BOM is in the CSV near
    `_id` it will cause improper importing of the data held within. To
    address this, Workarea now specifies the `bom|` prefix in the `:encoding`
    param for `CSV.foreach` by default. This can still be overridden if you
    have an ASCII file, and since BOM stripping doesn't really apply,
    developers can override the entire encoding string in configuration
    if necessary. But this is a sane default for those who use UTF-8 and
    happen to be exporting out of older spreadsheet software.

    WORKAREA-79
    Tom Scott

*   Fix content block asset uploads, set redis key to reduce S3 CORS config requests

    WORKAREA-109
    Matt Duffy

*   Handle display of missing segment for active_by_segment admin filter

    Matt Duffy

*   Add admin alert for segmented resources with no matching segments

    WORKAREA-116
    Matt Duffy

*   Clean up generic admin activity view partials

    WORKAREA-117
    Matt Duffy

*   Clean up generic admin activity view partials

    Matt Duffy

*   Allow redis to be configured with TLS (#234)

    Matt Martyn

*   Update Tests Referencing 2020

    The credit card expiration year `2020` was hard-coded into many Workarea
    integration tests, and would fail when January 2020 passes. Update these
    tests to always set the credit card expiration year to 1 year in
    advance of when the test runs so this won't happen again in the future.

    WORKAREA-104

    Fixes #222
    Tom Scott

*   Extend impersonation notification to guest browsing

    WORKAREA-115
    Matt Duffy

*   Add special tags information tooltip to content asset tags field

    WORKAREA-99
    Matt Duffy

*   Add Event functionality to Timeline Report UI

    WORKAREA-86
    Curt Howard

*   Expand last order segment rule to allow not ordered within

    WORKAREA-90
    Matt Duffy

*   Bump Chartkick dependency to fix security warning

    Fixes bundler-audit failures in builds.
    Ben Crouse

*   Add link to browse as a guest to admin shortcuts menu

    Matt Duffy

*   Add discount cards append point

    Ben Crouse

*   Create the life cycle segments as part of migration task

    Ben Crouse

*   Use query string over ID for insights display

    Query string will also be used in the search autocomplete output.
    Ben Crouse

*   Remove require_permission for admin guest browsing

    Matt Duffy

*   [DOCS] Improve table of contents for docs

    The table of contents that appears within each doc contains a link to
    every h2-h6 in the document. Therefore, in longer docs, the TOC gets
    quite crowded and stops communicating the overall structure of the doc.

    Help readers maintain context by simplifying the TOC, limiting links to
    h2-h3.

    I spot-checked docs of various lengths and found this version of the TOC
    more useful in all cases.

    WORKAREA-96
    Chris Cressman

*   Update `Redis::Rack::Cache` to v2.2.0

    This new version requires `Rack::Cache` v1.10 and enables over-the-wire
    gzip compression to the Redis server. This feature is useful for
    extremely high traffic sites, but should be used with caution since it
    will increase the CPU/RAM load on your application server. You should
    use this if the trade-off between RAM increase and bandwidth decrease
    makes sense.

    WORKAREA-94
    Tom Scott

*   Bump Chartkick dependency to fix security warning

    Fixes bundler-audit failures in builds.
    Ben Crouse

*   Add index to SearchByDay model

    Bryan Alexander

*   Add index to SearchByDay model

    Bryan Alexander

*   Add admin browsing by segmentable content

    This adds "Active by Segment" as a filter, and adds a "Content" card to
    segments to surface what stuff has been setup specifically for a
    segment.

    WORKAREA-89
    Ben Crouse

*   Remove now-unneeded version restriction on the BSON gem

    If we remove this restriction, we can use newer versions of the `mongo` gem, which contain cluster fixes.
    Ben Crouse

*   [DOCS] Rename and update doc for testing CC transactions

    Rename "Test a Credit Card Transaction" to
    "Manually Test Credit Card Transactions" and update the content.

    The content was specific to a particular gateway and didn't make that
    clear. These changes provide a generic solution in addition to the
    specifics for the default gateway.

    The title confused devs who reviewed this doc in a different PR,
    thinking that it had to do with automated testing.

    WORKAREA-13
    Chris Cressman



Workarea 3.5.0.beta.1 (2019-11-07)
--------------------------------------------------------------------------------

*   Allow storing non-unique recently viewed items

    This will allow us to do better segmenting in the future with rules like
    "viewed this product more than once".

    WORKAREA-88
    Ben Crouse

*   Fix Incorrect Test Setup

    The `Pricing::Calculators::Calculator.test_adjust` method accepts two
    arguments, and expects the first argument is going to be of type
    `Order`, but in a `TaxCalculator` test only a shipping was being passed
    in. Update this test to use the correct syntax so that other downstream
    projects that expect data to be on an Order won't get confused.
    Tom Scott

*   Allow an asset to be tagged 'og-default' to use for open graph images

    WORKAREA-76
    Matt Duffy

*   Move segment overriding into middleware

    To enable correct segment headers and caching, segment overriding will
    need to happen in middleware. To accomplish this, we'll need to store
    whether someone is an admin in their metrics.

    This has a nice side-effect of not needing the `cache` cookie anymore,
    so that's being removed.
    Ben Crouse

*   Add buttons to allow admin users to subscribe/unsubscribe from comments

    WORKAREA-75
    Matt Duffy

*   Add browser info options for segment rules

    This also replaces Workarea's `Robots` class with use of the `browser`
    gem, which keeps far better and updated checks.
    Ben Crouse

*   Adds graceful handling of timestamps from CSV imports

    WORKAREA-24
    Matt Duffy

*   Don't default to S3 asset store

    This causes problems spinning up environments in other hosting setups
    where S3 isn't available or desired.

    To retain the old behavior (which you'll want if you're on the Workarea
    Commerce Cloud) drop this into an initializer:
    `Workarea.config.asset_store = (Rails.env.test? || Rails.env.development?) ?
    :file_system : :s3`

    WORKAREA-32
    Ben Crouse

*   Use private HTTP caching headers for responses with segmented content

    If a page has segmented content, it can't be cached by any upstream HTTP
    caches because the user's segments can change request-by-request.

    Our solution is to use the headers we've been using for cached responses
    if the page has no segmented content. If it does have segmented content,
    change those headers to force refetching every time, while allowing the
    server to return a 304 to eliminate sending unnecessary responses.

    This is being done in a piece of middleware to ensure to
    Rack::Cache the headers look the same. This allows us to still cache
    complete responses in Rack::Cache for requests with segmented content.

    This commit also refactors the middleware that sets this all up into a
    single ApplicationMiddleware so it's easier to see everything going on
    in one file.

    WORKAREA-36
    Ben Crouse

*   Don't shell out to bundler to get gem path

    This can cause problems if bundler outputs warnings/errors. There's a safe way to do it in Ruby, so use that instead.

    Fixes #191
    Ben Crouse

*   Add a hook method to allow extending product's activeness

    Plugins like package products need a place to add more logic to a
    product's activeness without having to reimplement all of active's
    `super`. With the addition of segments, this becomes a bunch of
    code.
    Ben Crouse

*   Allow content to be appended to head element in Content

    WORKAREA-4
    Curt Howard

*   Add notes about admin config fields and encryption to upgrade guide

    WORKAREA-25
    Matt Duffy

*   Integrate segments into discount cache keys

    Also, since we won't be able to expire keys in a performant way
    (delete_matched is O(N) on the number of keys in Redis), we'll have to
    remove discount cache busting.
    Ben Crouse

*   Fix changeset loading missing root

    Can raise an error when rendering changesets on the release's show page.
    Ben Crouse

*   Implement Tribute.js for comment notifications

    WORKAREA-6
    Curt Howard

*   Fix issue around Visit#referrer and Puma

    Curt Howard

*   Add segmented icons to index pages

    Ben Crouse

*   Add segment icon to content blocks UI

    Ben Crouse

*   Rework FeaturedCategorizations to allow easier decoration

    WORKAREA-21
    Matt Duffy

*   Removes Puma auto-configuration (#151)

    This is going to part of the `workarea-commerce_cloud` gem going forward. If you're a subscriber to the Workarea Commerce Cloud service, you should include that gem in your project to get Puma and other configuration for that service.
    Jesse McPherson

*   Fix Product URL In Breadcrumbs

    The `storefront_url_for` method doesn't handle models other than taxons,
    but the Schema.org helpers use it to render breadcrumb URLs in the
    `BreadcrumbList` for any model that's in the breadcrumbs. To prevent
    incorrect URLs from showing up in the breadcrumbs, the
    `Navigation::Breadcrumbs` class has been modified to accept a model
    object as its `:last` parameter, instead of just a name, to be added to
    an arbitrary `Navigation::Taxon` created for the purpose of rendering
    both the name and URL of the final navigation taxon. This wasn't needed
    prior to the introduction of Schema.org's `BreadcrumbList`, because the
    final URL of breadcrumbs was always left out. The helper methods that
    render the breadcrumbs will continue to leave out the final taxon's URL,
    but for breadcrumbs in Schema.org, the URL will now be included.

    (#83)
    Tom Scott

*   Apply tax to items that do not require shipping

    * Adds Payment lookup to pricing request
    * Modifies TaxCalculator to check shipped and not shipped items
    * Renames TaxApplier to ShippedTaxApplier, Uses TaxApplier for not shipped items
    Matt Duffy

*   Update order documentation for Workarea 3.5

    Cover suspected fraud.

    Closes #99
    Chris Cressman

*   Allow setting active by segment

    This allows configuring releasable resources to be active only for
    certain segments. If no segments are specified, it will be active
    globally. If segments are specified, only those segments will be able to
    see it.

    For #102
    Ben Crouse

*   Pass Options To `Storefront::UserActivityViewModel`

    This was an oversight that got caught and fixed in the `flow-io` plugin,
    but should really be in base since it will allow more control over the
    product summaries on the recent views action. The `view_model_options`
    were not getting passed into the `UserActivityViewModel`, and thus the
    `ProductViewModel` instances that it creates, causing some stale content
    to appear in the view.
    Tom Scott

*   Surface Asset alt text and behavior within Content Blocks (#95)

    In an effort to make the recent updates to alt text overridding in
    Content Blocks a bit clearer, alt text is now being output:

    - On the content assets index view
    - In the title for a content asset summary

    Default alt text has been removed from the Content block DSL, which
    makes the default text come directly from the Asset itself.

    The help text displayed on Asset Content Blocks always appears now,
    better explaining the behavior of this feature.
    Curt Howard

*   Spruce up Timeline UI (#58)

    The `activity`, `activity-group`, and `date-marker` UIs couple together
    to create, what's unofficially referred to as, The Timeline UI. These
    components have been neglected for a long time... until now!
    Curt Howard

*   Update inventory docs for Workarea 3.5 (#98)

    Add coverage of inventory collection status, a new concept
    in Workarea 3.5
    Chris Cressman

*   Update search docs for Workarea 3.5 (#97)

    * Remove references to Storefront autocomplete
    * Update examples to reflect release-specific search documents
    * Call out the impact of current release and current segments on search documents
    Chris Cressman

*   Remove Refund Tests

    Since we're no longer able to regenerate VCR cassettes at-will (due to
    credentials needing to be scrubbed before pushing to GitHub), this
    configuration setting is no longer necessary, and furthermore, could
    potentially prevent legitimate tests from running and catching bugs in
    the wild. They're only used in one plugin, so remove the tests from base
    and copy them into the plugin.
    Tom Scott

*   Refine fullfillment UI around skus and tokens

    * Change package messaging for items with no carrier and tracking number
    * Add table of fulfillment tokens associated to an order
    * Fix paginating fulfillment tokens

    Closes #93
    Matt Duffy

*   Remove Schema.org structured data from unspiderable pages

    There seems to be little reason to bloat the markup of pages explicitly
    disallowed in our default `robots.txt` file.

    Closes #82
    Curt Howard

*   Remove /wish_lists entry from Robots.txt

    This was a relic from a more monolithic age and will be readded by
    workarea-commerce/workarea-wish-lists#2.

    Closes #106
    Curt Howard

*   Add config field to limit total item count for a single cart

    Matt Duffy

*   Update docs to reflect changes in Workarea 3.5

    * Storefront price partial removed
    * `Workarea.with_config` obsoleted by automatic resetting
    of configuration between tests
    * Changes to headless Chrome configuration
    * Changes to Sidekiq queues
    * Addition of `query_cache` Sidekiq option
    Chris Cressman

*   Add Workarea 3.5 release notes

    * Add 3.5 release notes doc
    * Link to 3.5 release notes doc from release notes index
    * Rename and modify 3.5 upgrade guide for consistency with 3.4 upgrade guide
    * Cross-reference 3.5 release notes and upgrade guide
    * Clean up upgrade guide
    * Fix title of doc added for v3.5
    Chris Cressman

*   Factor release id into discount cache keys

    closes #43
    Matt Duffy

*   Update content block helper to use view helper cache method.

    This was previously using Rails low level caching, which does not
    factor in varies headers or prevent caching for admins.
    Matt Duffy

*   Fix showing comments without authors in admin

    Comments generated in plugins don't have an author; update the view to
    handle rendering when the `author_id` is nil.
    Eric Pigeon

*   add query_cache flag to index workers

    Matt Duffy

*   Eliminate n+1 query from ProductPrimaryNavigation

    Matt Duffy

*   Eliminate n+1 query from FeaturedCategorization

    Matt Duffy

*   Add query cache middleware for sidekiq to provide options for enabling query caches

    Matt Duffy

*   Use the same Mongo connection options for the index enforcement warning.

    Fixes #31
    Ben Crouse

*   Only check notablescan in development

    #31
    Jesse McPherson

*   Completely remove jQuery UI Autocomplete

    Curt Howard

*   Remove Search Autocomplete

    Porting to
    https://github.com/workarea-commerce/workarea-classic-search-autocomplete
    Curt Howard

*   Update sales report queries and metric indexes for cancellations (#14)

    Matt Duffy

*   Remove Search Autocomplete (#16)

    This functionality is being moved to `workarea-classic-search-autocomplete` to maintain compatibility. Going forward, a new improved `workarea-search-autocomplete` is the preferred search autocomplete for Workarea. It's much improved.
    Curt Howard

*   Remove artifact from conflict resolution

    Jake Beresford

*   Initial commit for v3.5

    Ben Crouse



Workarea 3.4.20 (2019-10-30)
--------------------------------------------------------------------------------

*   Fix logout from pages without authenticity tokens

    On pages without authenticity tokens (like HTTP cached pages), clicking
    log out won't work because Rails is checking for that. This disables
    that check for logout to fix.

    WORKAREA-66
    Ben Crouse

*   [DOCS] Fix/improve various docs based on community feedback

    Navigating the Code

    * Fix typos and difficult wording
    * More clearly define the term "meta-gem"

    Seeds:

    * Remove vestiges of previous build system
    * Make some code blocks easier to copy and paste
    * Update plugin examples to use only plugins that
    are published to RubyGems.org

    Create a New App:

    * Update introduction and outline to latest style
    * Fix incorrect command for seeding
    * Make code blocks easier to copy and paste
    * Explain how to get help if experiencing issues

    WORKAREA-62
    Chris Cressman

*   Bump Loofah dependency to fix bundler-audit error

    Ben Crouse

*   Mount api engine in routes during workarea:install if api is installed

    Matt Duffy

*   Update Docker image build workflow

    Matt Duffy

*   Update demo Dockerfile to use plugins

    WORKAREA-7
    Matt Duffy

*   Update README with docker memory messaging

    WORKAREA-8
    Matt Duffy

*   Modify SystemTest to help increase reliability of #within_frame

    * Move #wait_for_iframe to SystemTest class
    * Add #within_frame to methods that wait for xhr requests
    * Use #wait_for_iframe on spotty ImpersonationSystem Test
    Matt Duffy



Workarea 3.4.19 (2019-10-16)
--------------------------------------------------------------------------------

*   Fix missing aspect ratio magic attribute

    This magic attribute doesn't need to be calculated, it's the inverse of the aspect ratio we already have.
    Ben Crouse

*   v3.4.19 Patch Release Notes

    Tom Scott

*   Improve Mailer Documentation

    Direct readers to ActionMailer resources when they're looking to create
    new mailers rather than style or modify existing ones. Also added some
    information about unit testing mailer classes.
    Tom Scott

*   Lock Down Sprockets to v3.7.2

    Sprockets v4.0 was released on 10/8/2019, which removed the
    `.register_engine` method that is depended on by many extensions to
    Sprockets at the current moment. Lock down Sprockets to v3.7.2 to avoid
    these issues, which will show up when the app is loaded or tests are
    run.

    WORKAREA-18
    Tom Scott

*   Keep `_id` Suffix In Customized Fields

    When adding a customized field to a `Customizations` class that ends in
    `_id`, Workarea was previously stripping this suffix from the computed
    instance variable name that is converted into snake case from any kind
    of input. This causes issues because the data doesn't appear to be
    making it into customizations, but is really there under a different
    instance variable name. To resolve the issue, Workarea is now using the
    `#underscore` String helper prior to calling `#optionize`, which will
    cause the value to be properly cased before it's displayed to the end
    user.

    (#144)
    Tom Scott

*   Fix Self-Referential Category Rules

    Adding the same ID to a category product rule matching the product list
    that contains it results in some wonky results coming back. This was
    originally diagnosed as an issue when combining category rules, but in
    reality, it has to do with an admin mis-using the product rules
    interface and perhaps accidentally using the category's own ID in a
    product rule. To prevent this from happening, prevent the category's own
    ID from being selectable in the admin interface.

    (#52)
    Tom Scott

*   Improve order of changesets in Timeline UI (#124)

    The Timeline UI should now display:

    1. Unscheduled changesets
    1. Scheduled changesets, ordered by the release's publish date,
    descending
    1. Today (if applicable)
    1. Historical changesets
    Curt Howard



Workarea 3.4.18 (2019-10-01)
--------------------------------------------------------------------------------

*   Fix test failure due to iframe loading

    This test has started failing due to Capybara or Selenium not finding
    the release select in the iframe. A simple sleep fixes the problem, we
    weren't able to track down a proper cause.

    We'll be refactoring the admin toolbar away from an iframe in v3.6, so
    this will be a temporary hack to fix. We'll remove this at that point in
    time.
    Ben Crouse

*   Fix Faraday dependency issue

    Curt Howard



Workarea 3.4.17 (2019-10-01)
--------------------------------------------------------------------------------

*   Add Inverse Aspect Ratio To Product Image Fields (#118)

    Populate the `:image_inverse_aspect_ratio` automatically using
    Dragonfly, in order to reduce the amount of requests made to S3 in order
    to find out this information.

    (#116)
    Tom Scott

*   Exclude docs/ from the gem build

    Matt Duffy

*   Ensure Tags Are Unique

    When inserting tags into a taggable document, make sure their values are
    unique. This addresses an issue where incorrect tag counts were being
    displayed on the storefront.

    Fixes #112
    Tom Scott

*   Display Referrer URL in tooltip on Order Attributes in Admin

    Due to the length of URLs being displayed on Order Attributes in the
    admin they will potentially break layout. Now they are displayed within
    a tooltip behind a "View" link click. The resulting tooltip will prompt
    the user to copy the contents of a text box containing the URL.

    Fixes #60
    Curt Howard

*   Fix incorrect URL for workarea support on CLI documentation

    Matt Duffy

*   Add checkout confirmation append point (#76)

    Adds append point below default order confirmation text.
    Jeff Yucis

*   Fix blank default category in admin ProductViewModel (#55)

    `ProductViewModel#default_category` now protects against a `nil` value
    for the default category before passing its value into a view model.

    Fixes #33
    Tom Scott

*   Replace App Template Command With Install Generator in Upgrade Docs

    In the upgrade guide for v3.4, we're instructing users to apply an app
    template which no longer exists. Instead of using the app template, we
    now rely on a generator called `workarea:install` to place the expected
    files into your Rails app directory, so update the command in docs to
    avoid confusion.
    Tom Scott

*   Improve plugin template

    * Updates usage documentation at top of template
    * Properly namespace directories under `app/assets`
    * Set starting version to `1.0.0.pre`
    * Point to HTTPS GitHub url instead of SSH
    * Clean up generated README
    * Add LICENSE
    * Link license in gemspec and README
    * Fix indentation and whitespace issues in gemspec
    * Remove `script/` directory
    * Clean up generated gitignore
    * Fix link to developer documentation in README
    * Fix flagrant quote fail for required Rails engines

    Closes #25
    Curt Howard



Workarea 3.4.16 (2019-09-17)
--------------------------------------------------------------------------------

* Ensure test only asserts product details for product system test

* Parse URL When Ensuring CORS for Direct Uploads

  The `request.url` returns the full URL, with path included. This isn't
  valid for a CORS header, which needs just the scheme, host, and port if
  it's non-standard. Update the `DirectUpload.ensure_cors!` method to
  parse out those pieces of the URL and re-assemble it for the CORS
  header and ID.

* Use current URL for direct upload CORS headers (#20)

  Direct uploads can fail locally if your `Workarea.config.host` is not
  set to the domain you are currently using in the browser. To prevent
  this, instead of reading from the configuration when ensuring CORS
  headers on the S3 bucket, use the URL from the request for S3 CORS config.
  Addresses a problem whereby changing the domain (either accidentally or
  on-purpose) causes direct uploads to fail, since it can't create the
  proper CORS headers needed to transmit files into the bucket directly.



Workarea 3.4.15 (2019-09-04)
--------------------------------------------------------------------------------

*   Customize Search Queries That Return an Exact Match (#22)

    It's currently possible to customize search queries that return an exact
    match, but instead of seeing the customized results when you run the
    query, you'll be redirected to the product page since the
    `StorefrontSearch::ExactMatches` middleware stops further middleware
    execution and sets a redirect to the product path. To resolve the issue,
    Workarea will now ignore this middleware if a customization is present
    on the search response.
    
    Discovered by @ryaan-anthony of **Syatt Media**. Thanks Ryan!

*   Add Generic Activity Partials (#4)

    Empty results were still being seen in the trash when a model that
    doesn't explicitly have an activity partial defined is encountered. This
    is due to the `render_activity_entry` helper rescuing an
    `ActionView::TemplateError` to return a blank string. To resolve this
    issue, models that are tracked by `Mongoid::AuditLog`, without an
    explicit activity partial defined will be rendered using a generic
    partial, showing the class name and ID of the audited model, as
    something to render in the listing so that pages of blank results
    aren't shown.

*   Remove minitest plugin (#12)

    This existed for CI purposes on Bamboo, and we don't need it here after
    moving to Github. It has been moved the `workarea-ci` gem for backwards
    compatibility.

*   Fix Deep Duplication of Swappable Lists (#13)

    The `Workarea::SwappableList` class does not get duplicated correctly
    when `Workarea.config.deep_dup` is used. This was observed while using
    multi-site and attempting to change a swappable list for only one site.
    Define the `#deep_dup` method to return a new object instead of referencing
    the existing one.


*   Publish Releases In Background Job

    When a release is published, but has too many changes, it can cause a
    request timeout because it can't be fully published within the allotted
    15 seconds in production. To prevent this, Workarea now runs all release
    publishing in a background job. The success flash message for when a
    release is published has been updated to inform users that changes may
    take a little while to apply.
    
    Fixes #1

Workarea 3.4.14 (2019-08-26)
--------------------------------------------------------------------------------

*   Fix a test that doesn't reset state

Workarea 3.4.13 (2019-08-26)
--------------------------------------------------------------------------------

*   Remove references to v2 from Developer docs

*  	Fix Incorrect Currency in Mongoid Money Types
    
    Workarea's default values for the Money fields in `Pricing::Override`
    didn't previously change currency when `Money.default_currency` is
    re-configured in process (like in the case of a multi-site application
    with multiple currencies). Ensure that the correct currency is used by
    using an Integer type as the default, which will get converted into a
    Money type at runtime.

* 	Change URL used to download product images for seed data

*   Get GitHub Actions CI up and running

Workarea 3.4.12 (2019-08-21)
--------------------------------------------------------------------------------

*   Remove hardcoded IP addresses (#36)

    The hosting team will have to add these manually going forward.
    Ben Crouse

*   Add license (#33)

    Jason Hill

*   Add documentation for Workarea Themes (#15)

    Jake Beresford

*   Update release task & plugin template (#20)

    Also fixes github source in Gemfile for plugin template

    Curt Howard

*   Fix pathnames in doc

    The current publishing system requires this doc to use root-relative
    pathnames when linking to internal documents. Update all pathnames
    accordingly.
    Chris Cressman

*   Enforce positive sale prices in sample data

    ECOMMERCE-7062
    Jeff Yucis

*   Pretty up seed data (#22)

    * Add product sample images to seeds

    * Add intrinsic ratio support for product images

    Allows product images from any aspect ratio to be displayed
    out-of-the-box.

    * Update system content seeds

    * Add configurable seeds taxonomy
    Ben Crouse

*   Show relevant flash message when no shipping options are available.

    Improves UX when a user is sent back to the address step when there
    are no available shipping options for their shipping address.

    ECOMMERCE-6992
    Jeff Yucis

*   Modify metrics and reports to filter out records with no values

    ECOMMERCE-7036
    Matt Duffy

*   Improve 'Add a Content Block Type' doc

    Update doc based on feedback, specifically:

    * Fix link to content block DSL explanation and usage examples.
    * Make link to content blocks DSL usage examples more prominent.
    * Reference an initializer with further content block DSL examples.
    * Explain how to output content block data in a view without a view model.
    * Explain how to use `local_assigns` to test data in a view if no view model.

    ECOMMERCE-7059
    Chris Cressman

*   Remove unneeded Report::SearchesWithoutResults

    Matt Duffy

*   Render Shipping Details Append Point On Index

    Move the **admin.shipping_details** append point from `shippings#show`
    (which is no longer rendered) over to `shippings#index`. Remove the
    `shippings#show` partial to reduce confusion since it is no longer being
    used.

    ECOMMERCE-7061
    Tom Scott

*   Add upgrade guides index page to docs site

    Provide an index page of upgrade guides so that external docs
    (specifically the docs for the upgrade plugin) can link to it.

    Also update the 3.4 upgrade guide to follow the file and document naming
    conventions used by the release notes.

    ECOMMERCE-7057
    Chris Cressman

*   Fix Internal Server Error Page Not Rendering JSON

    When an Internal Server Error is requested via `/500.json`, another
    error occurs when attempting to render the view for that request,
    because there's no `internal` template. This is not how our error
    handler is supposed to work, any format should be acceptable to render a
    404 or 500. The syntax of the `respond_to` block in `#render_error_page`
    has been altered so that Workarea serves the custom content HTML when an
    HTML error occurs (e.g., most user-facing browser errors), and an empty
    body with a 500 error in the status code is returned for all other
    formats.

    ECOMMERCE-7034
    Tom Scott

*   Remove data linting doc

    This doc caused some confusion, and this feature is scheduled to be
    removed from Workarea, so remove this doc.

    ECOMMERCE-7058
    Chris Cressman

*   Add inventory documentation

    Add new docs:

    * Inventory
    * Integrate an Inventory Management System
    * Define & Configure Inventory Policies

    ECOMMERCE-6971
    Chris Cressman

*   Fix Order Status Lookup Route

    The `/orders/status/:order_id/:postal_code` was being resolved by the
    `#show` action of OrdersController, when it really should be served by
    `#lookup`. Change the route and add a test ensuring that the route is
    being handled properly.

    Discovered by **Andy Sides** of BVAccel. Thanks Andy!

    ECOMMERCE-7040
    Tom Scott

*   Prevent Empty Results In Trash

    Remove a check for whether a given audit log entry is `#restorable?` in
    on the **/admin/trash** page to prevent empty results clogging up the
    pagination. Without this, admins will see blank pages if they delete
    enough nav taxon/release records at the same time.

    ECOMMERCE-7019
    Tom Scott

*   Add hosting docs (#14)

    Ben Crouse

*   Remove ci gem, add lint configs to root directory (#18)

    Matt Duffy

*   Update Contributing Guides (#8)

    Update the guides in the "Contribute" section of Workarea's
    documentation to reflect the new process of GitHub Issues, Pull
    Requests, and the "fork-and-pull" model that developers will be using to
    contribute code and docs to the platform from now on. This also includes
    a bit about using `puma-dev` to preview documentation locally, because I
    thought that was useful.

    Closes #7
    Tom Scott

*   Remove help articles (#13)

    * Remove all Help articles

    These articles are largely outdated and provide little more than basic,
    general information about the expected user input on a given page.

    For more complex actions in the Admin we favor tooltips.

    This work does include one help article, How To Create Help Articles, to
    allow Admins and Developers a chance to build out this section for their
    specific purposes.

    Closes #5

    * Fix output of Help Article code blocks

    By using Redcarpet to render supplied markdown, rather than Haml's
    `:markdown` filter, we can force the article's output through the
    renderer's `hard_wrap` option, which will preserve intended whitespace
    throughout the article.
    Curt Howard

*   Add third party integration overview guide (#6)

    Ben Crouse

*   Add article Navigating the Code (#3)

    Matt Duffy

*   Add security policy (#1)

    Ben Crouse

*   Update installation process

    * Remove app_template.rb
    * Add `workarea:install` generator
    * Update documentation to reflect change

    closes #13
    Matt Duffy

*   Add Maintenance Policy to docs

    Resolves #10
    Curt Howard

*   Add Code of Conduct

    Introduce the Contributor Covenant Code of Conduct to encourage
    people from all walks of life to contribute to the project.

    Closes #4
    Tom Scott



Workarea 3.4.11 (2019-08-06)
--------------------------------------------------------------------------------

*   Use `#camelize` over `#classify` when loading report class for export

    The use of `#classify` causes errors to be thrown during export of
    a report class that is plural, e.g. WishListProducts. This causes
    the export to fail and the user to not receive the export email.

    ECOMMERCE-7032
    Matt Duffy

*   Update 'Customize a Helper' doc

    * Add additional use case of adding a new helper from a plugin
    * Add additional example that uses a decorator to extend the controller
    * Link to relevant Rails docs and Workarea docs
    * Clearly state the problems and solutions

    ECOMMERCE-6974
    Chris Cressman

*   Add 'Order Pricing' documentation

    Add new document and diagrams

    ECOMMERCE-6970
    Chris Cressman

*   Improve Accuracy of CSV Import Test

    The unit test written for configuring the charset of any CSV files
    imported into the system was not accurate, as it was not actually
    testing what would happen if the configuration was in place. The test
    continued to pass, however, becuase it turns out that it's very
    difficult to conjure up an ASCII string in Ruby, which is purely UTF8.
    Even editing the CSV file in Vim produced a compatible String when read
    into Ruby, so the test still wasn't accurate. The only way to get the
    test to fail in an expected way was to actually include the CSV file
    given to us from URBN, which was quickly fixed by setting the
    `:encoding` option on CSV imports.

    ECOMMERCE-7012
    Tom Scott

*   Filter Blank Data From Average Order Value Report

    Since the Average Order Value report divides orders by revenue in a
    MongoDB aggregation, neither of these numbers can be 0, otherwise a
    divide by zero error is thrown. To prevent this, Workarea now omits any
    `Metrics::SalesByDay` documents from the aggregation if their orders
    and/or revenue are 0.

    ECOMMERCE-7016
    Tom Scott

*   Update GeoIP Headers

    For apps that are using the GeoIP 2 database, the headers have changed
    to a slightly different syntax, and some of them output different values
    than they used to. Update `Workarea::Geolocation` to handle both
    versions of the GeoIP database and to look up the subdivision code by
    its name through the Countries gem.

    ECOMMERCE-7015
    Tom Scott



Workarea 3.4.10 (2019-07-23)
--------------------------------------------------------------------------------

*   Allow Development Access to Assets Admin Index

    Developers shouldn't need an AWS keypair to view the
    **/admin/content_assets** index. Workarea will now only call
    `DirectUpload.ensure_cors!` if the S3 bucket has been configured,
    so one can still browse the page.

    ECOMMERCE-7014
    Tom Scott

*   Replace "Views" with "Searches" on Search Insights

    For insights revolving around search, use the more apt term "Searches",
    which maps to the actual `searches` in the resultset, instead of
    "Views". This fixes an issue where insights with blank views/searches
    were showing up on the search dashboards.

    ECOMMERCE-7007
    Tom Scott

*   Improve "Commerce Model" diagram & text

    Rename "Commerce Flow" to "Commerce Model" to reflect intended future
    usage. Expand steps/actions to reflect existing narratives in products
    and orders docs. Use simpler line drawing to improve clarity.

    ECOMMERCE-6954
    Chris Cressman

*   Omit `nil` Options From Product Cache Key

    The `#details_in_options` method, meant for including any options passed
    to the `CacheKey` so long as they appear in details, would error if the
    name of an option was `nil`. Workarea now ensures that those options
    will be omitted.

    ECOMMERCE-6986
    Tom Scott

*   Remove Support For Restoring Taxons Without Parents

    `Navigation::Taxon` documents whose parents no longer exist cannot be
    restored because they are too dependent on their external relations,
    such as `:parent_ids`. This causes issues on restore when one attempts
    to restore a child taxon without restoring its parent. To prevent this
    potential issue, taxons are never allowed to be restored from the trash.
    The recommended alternative is to just create another taxon.

    ECOMMERCE-6983
    Tom Scott

*   Improve busting cache

    This may be getting backed up in Sidekiq, and admins expect it to be
    happening in real-time. Also bust shipping service cache when destroyed.

    ECOMMERCE-6981
    Ben Crouse



Workarea 3.4.9 (2019-07-09)
--------------------------------------------------------------------------------

*   Update Puma and loosen constraint

    This gem is fairly stable and doesn't follow strict semantic versioning
    anyways. This was requested by the hosting team.

    ECOMMERCE-6984
    Ben Crouse

*   Add documentation for themes

    ECOMMERCE-6932
    Jake Beresford

*   Fix Encoding Errors on Product Import

    Allow users to specify a source encoding for CSV files that are being
    imported into the application. UTF-8 encoding is still enforced, since
    that's the charset Workarea renders content with in the browser, but
    the source can now be configured to prevent errors when importing CSV.

    ECOMMERCE-6963
    Tom Scott

*   Store headless chrome options before passing into Capybara driver

    Capybara.register_driver does not execute the passed block immediately, which
    can cause issues with the aliasing of Workarea.config.headless_chrome_options,
    particularly with multi-site where the config is duplicated.

    ECOMMERCE-6969
    Matt Duffy

*   Fix Sidekiq autoconfiguration

    The main changes here are:

    * Allow configuring pool timeout
    * Fix configuring the client, not the server where we need more control
    on the pool
    * Remove fancy-pants process scaling, too complex and broken
    * Allow configuration of PID file and queues from ENV vars

    ECOMMERCE-6967
    Ben Crouse

*   Prevent error when starting taxon is deleted from taxonomy

    * Adjust logic for show_starting_taxon to account for changes in the taxonomy tree

    ECOMMERCE-6961
    Jake Beresford

*   Fixes incorrect syntax in JS adapter generator template

    ECOMMERCE-6964
    Jake Beresford

*   Make Quick Start guide less OS X centric

    ECOMMERCE-6864
    Curt Howard



Workarea 3.4.8 (2019-06-25)
--------------------------------------------------------------------------------

*   Fix time zone configuration article

    Rails needs this to be configured earlier than in an initializer, so
    this needs to be in general Rails config in `config/application.rb`.

    When done in an initializer, `Time.zone` will not be set accurately,
    so models loaded out of the database will have `Time` fields in UTC.
    Ben Crouse

*   Add 'Commerce Flow' doc

    Add diagram of commerce flow and a mapping of its concepts to relevant
    code paths.

    ECOMMERCE-6954
    Chris Cressman

*   Add view model interface diagram

    Add new section to 'View Models' doc, which illustrates the creation of
    the view model interface and the view receiving the interface as an
    instance variable.

    ECOMMERCE-6955
    Chris Cressman

*   Add Pagination to Shipping Services Admin Index

    When an application has more than 100 shipping services in the database,
    only the first 100 would show on the index. Additionally, such a large
    query should be paginated. Render the `workarea/admin/shared/pagination`
    partial at the bottom of the `<table>` containing all services and
    paginate the collection of services that are queried for in the
    controller.

    ECOMMERCE-6960
    Tom Scott

*   Do not move #content-aside when opening mobile filters to prevent DOM changing on wider viewports after mobile filters are displayed.

    ECOMMERCE-6959
    Jake Beresford

*   Stop Premailer from automatically combining properties

    When possible Premailer will combine separated properties, like
    `background-image`, `background-position`, etc, into one, single
    property. This causes issues in Yahoo, at least, and presumably other,
    inferior mail clients. It's best to stop this behavior, which gives more
    control to the developer to make their own dang decisions.

    ECOMMERCE-6941
    Curt Howard

*   Rename i18n JavaScript initializer

    No changelo
    Curt Howard

*   Use Translations as a Fallback for Missing Name in Address Region Options

    In the [countries](https://github.com/hexorx/countries) gem,
    some subdivisions in a country (what Workarea calls "regions") do not
    have a `:name` field associated with them. If this occurs, dive into the
    `#translations` hash and look for the name of the region within the
    current i18n locale.

    ECOMMERCE-6958
    Tom Scott

*   Prevent Customer Service Taxonomy Duplication

    In the footer navigation, the "Customer Service" header was duplicated
    now that the `:show_starting_taxon` option for content blocks defaults
    to `true`. Set this to `false` in the seeds for footer navigation
    content in the layout so that the heading doesn't show up twice.

    ECOMMERCE-6944
    Tom Scott

*   Wrap skip-all code in a decorated {} block

    Tom Scott

*   Fix Search Settings Clearing When Not Submitted From Main Form

    With the **workarea-swatches** plugin comes a form that updates a single
    value on the search settings, in contrast to the main search settings
    form which updates all values at once. This form's action URL is just
    `PATCH /admin/search_settings`, which does some massaging of the params
    and inadvertently causes `nil` values to be contained in the attributes
    hash for updating when those params are not included in the request.
    Workarea now runs `.compact` on the Hash of attributes generated by this
    controller action, before it's mass-assigned into `Search::Settings.current`.
    This prevents the params from getting cleared out, and fixes any kind of partial
    updates on the `/admin/search_settings` endpoint.

    ECOMMERCE-6942
    Tom Scott

*   Document checkout

    Add 'Checkout' doc w/ flow diagram.

    ECOMMERCE-6900
    Chris Cressman



Workarea 3.4.7 (2019-06-11)
--------------------------------------------------------------------------------

*   Backport Payment Factory Change

    This change allows workarea-reviews tests to pass against v3.2.x.

    ECOMMERCE-6935
    Tom Scott

*   Fixes for Chrome 75

    Chrome 75 enables W3C mode by default, which breaks lots of stuff.

    This also adds configuration via ENV variables for which options and
    args to pass to Chrome when running tests.

    `Workarea.config.headless_chrome_options` turns out to be poorly named
    because the Selenium driver accepts both args and options, and both
    may need to be configured to fix problems in Chrome. In a future minor
    release, we'll allow both args and options to be defined in
    `Workarea.config`. For now, lots of people are using them so let's not
    break in a patch.

    ECOMMERCE-6940
    Ben Crouse

*   Update chartkick dependency

    We're not vulnerable since we only use Chartkick in the admin, but bumping this will fix bundler-audit in the builds.

    ECOMMERCE-6938
    Ben Crouse

*   Improve Consistency of Order Pricing Display

    When viewing an order summary in the storefront, the price of each item
    matches its original price, with no discounts applied. This is somewhat
    confusing as the totals don't add up to the subtotal of the order. The
    order summary page now renders the `item.total_price` so that these
    totals match up in the end.

    ECOMMERCE-6809
    Tom Scott

*   Fix z-index issue in Admin due to bad merge

    ECOMMERCE-6933
    Curt Howard

*   Fix z-index issue in Admin due to bad merge

    ECOMMERCE-6933
    Curt Howard

*   Fix z-index issue in Admin due to bad merge

    ECOMMERCE-6933
    Curt Howard

*   Update architecture diagrams

    Ben Crouse

*   Fix partial name matching trigger exact match functionality

    This can happen depending on how boosts and name phrase matching scoring
    are configured.

    ECOMMERCE-6934
    Ben Crouse

*   Prevent Double Application of Order-Level Discounts When Determining Packages

    In the `Workarea::Packaging` class, the subtotal of all shippable items
    already includes the order-level discounts after pricing is performed,
    since `Order::Item#total_value` is not the total prior to discounts,
    only tax and shipping. However, order-level discounts were being
    summed and deducted from the `Packaging#total_value`, resulting in a
    miscalculation of the total price of the Order. This problem doesn't
    manifest itself until there are a sufficient number of shipping tiers
    (at the very least, 3), because either the top or bottom tier will be
    used anyway. Remove the code for subtracting order-level discounts from
    the total value of the package, so that the proper shipping price will
    be displayed to the user in checkout.

    ECOMMERCE-6918
    Tom Scott

*   Fix some test failures related to improper timezone handling

    ECOMMERCE-6931
    Ben Crouse

*   Fix New Release Form Creating Duplicates

    The "with a new release" selection on the release selector pops up a
    mini form which prompts the user for the name of their new release. This
    form is dismissed if the user clicks the button, but still allows
    potential user input (including multiple submits), causing duplicate
    releases to be accidentally created if one hits enter _and_ clicks the
    "Add" button before the page refreshes. Prevent this by adding
    `data-disable-with` to the button so that it can't be submitted twice in
    the same request cycle.

    ECOMMERCE-6837
    Tom Scott

*   Fix duplication in search suggestions indexing

    This is caused by not using the query ID as the ID for the suggestion in
    its index after the new metrics engine in v3.4.

    ECOMMERCE-6927
    Ben Crouse

*   Fix search suggestions not being indexed

    Scheduling this job got lost in the changes for v3.

    ECOMMERCE-6927
    Ben Crouse



Workarea 3.4.6 (2019-05-28)
--------------------------------------------------------------------------------

*   Fix typo in storefront categories integration test

    Ben Crouse

*   Fix up Activity UI header

    When long names are supplied to this UI it will break undesirably

    ECOMMERCE-6919
    Curt Howard

*   Add option to fix dropping of cookies in headless chrome

    ECOMMERCE-6929
    Matt Duffy

*   Add API overview doc

    ECOMMERCE-6924
    Jake Beresford

*   Document Storefront search features

    Add the following architecture docs:

    * Storefront Search Features
    * Storefront Searches

    And the following implementation docs:

    * Analyze Storefront Search Results
    * Change Storefront Search Results
    * Index Storefront Search Documents

    ECOMMERCE-6822
    ECOMMERCE-6861
    ECOMMERCE-6823
    ECOMMERCE-6862
    ECOMMERCE-6824
    Chris Cressman

*   Repair Bulk Edit Release Publishing UI Wonk

    ECOMMERCE-6914
    Curt Howard

*   Case Insensitive Comparison Fulfillment #find_package

    The method #find_package in the model Fulfillment gets an improvement for its
    detection logic.

    ECOMMERCE-6870
    Jeremie Ges

*   Fix jQuery UI Datepicker z-indexing issue

    ECOMMERCE-6757
    Curt Howard

*   Replace WebLinc with Workarea as primary business name

    In an effort to remove the name WebLinc from our public facing content,
    these changes focus on replacement of the word when appropriate and/or adding
    more context to the difference between WebLinc Corp and Workarea.

    Updated the Help & Support article to be relevant to how we handle support today.

    ECOMMERCE-6913
    James Van Arsdale III

*   Reorganize the Docs Taxonomy

    The developer documentation taxonomy was originally developed based on how
    we think about the problems - _not_ how the end-user uses the content.

    Based on OSS project docs research, analytics, developer survey results,
    card sorting and user interviews - this updated taxonomy focuses more on
    succinct groupings of content that allow the _end-user_ to associate the
    code and content more quickly.

    Further refinement based on usage patterns and planned additions are expected
    over the upcoming releases to continue to align the taxonomy with how
    developers utilize the content.

    Include the new Workarea CLI Cheatsheet

    Update the URLs in Report a Bug article

    ECOMMERCE-6910
    James Van Arsdale III

*   Fix Exports Index Not Displaying After Promo Code Export

    When a list of promo codes is exported, the data file exports index page
    had trouble rendering a link to the collection, since there's no index
    page for promo codes. Workarea will now render the non-linked name of
    the object being exported, instead of attempting to generate a URL that
    doesn't exist.

    ECOMMERCE-6911
    Tom Scott

*   Omit Blank Sorts From Product Search Index

    Sorts configured in the product entries in Elasticsearch could
    potentially get quite long and unruly if the product was categorized in
    many places, but not set up for sorting in those categories. This causes
    an error in Elasticsearch if allowed to grow out of control, since its
    field limit for a single document is 1000. Workarea now removes any
    categories in the `sorts` for which a product position in `product_ids`
    cannot be found. This reduces the amount of noise in the documents and
    prevents scaling errors like this one.

    ECOMMERCE-6912
    Tom Scott

*   Fix Date and DateTime Picker UIs default setting on page load

    Due to the issues outlined
    [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date#Timestamp_string)
    we are unable to accurately set a default date, on page load, for date
    or datetime pickers for all browsers.

    As a fallback we do our damnedest to grok at least the date from the
    datetime string passed in from Ruby.

    ECOMMERCE-6909
    Curt Howard

*   Fix Product Categorization With Missing Indexes

    When the Storefront index is missing,
    `Search::Storefront::Product.find_categories` throws an exception due to
    the **400 Bad Request** error it receives from the Elasticsearch server.
    To prevent this and any other strange Elasticsearch errors from
    affecting this method (which is not supposed to throw an exception),
    rescue the base `Elasticsearch::Transport::Transport::ServerError` class
    rather than any subclasses we find are thrown during this request.

    ECOMMERCE-6850
    Tom Scott

*   Add CI scripts for bamboo to the app_template

    ECOMMERCE-6908
    Jake Beresford



Workarea 3.4.5 (2019-05-14)
--------------------------------------------------------------------------------

*   Add permissions management ticket to release notes. No changelog ECOMMERCE-6763

    Tom Scott

*   Add 'Report a Bug' article to documentation

    ECOMMERCE-6881
    Matt Duffy

*   Disable Permissions Management When User is a Super-Admin

    When a user has super-admin privileges in admin, it was previously
    possible to attempt removing admin access as well as access to areas of
    the admin, but these values would just get re-set after the form
    completed anyway. Workarea now sets all checkboxes on the permissions
    page to `disabled`, and renders a warning message above the form stating
    that you cannot change permissions for users who are super-admins. It
    also instructs the admin how to disable super-admin for a user in order
    for this page to function normally.

    ECOMMERCE-6902
    Tom Scott

*   Generate v3.4 CI scripts in app_template

    ECOMMERCE-6908
    Jake Beresford

*   Exclude changesets with blank releasable from Release show view in admin

    In some very unusual edgecases a releasable can become nil, for example if the document is deleted without callbacks or if an embedded document is overwritten. In these cases the release cannot be viewed in the admin. This change allows the release to still be viewed if some of the changesets have invalid releasables.

    ECOMMERCE-6904
    Jake Beresford

*   Fix Sidekiq only using localhost Redis

    This happens because it needs to be configured before looking up values
    for concurrency.

    ECOMMERCE-6907
    Ben Crouse

*   Fix VCR from blocking Webdrivers from downloading Chrome

    When web drivers has to download and install Chrome, it's being blocked by VCR. Allow the Chrome host.

    ECOMMERCE-6906
    Ben Crouse

*   Fix S3 misconfiguration when using IAM profiles for authentication

    This surfaces as an error when updating CORS for direct uploads.

    ECOMMERCE-6905
    Ben Crouse

*   Fix Test During Daylight Savings Time

    Testing `Analytics::User.orders_per` during daylight savings time
    results in the test failing because of the hour difference between the
    current time and the duration of `7.days.ago` in the test. Ensure that
    this assertion always runs on a date that isn't in DST so the test won't
    fail on the day DST changes next year.

    ECOMMERCE-6731
    Tom Scott

*   Use .wrap for ProductRulesPreviewViewModel to ensure correct view model is used

    ECOMMERCE-6884
    Matt Duffy

*   Add pagination controls to admin releases index

    ECOMMERCE-6903
    Jake Beresford

*   Add Generic Summary Partial to Fix Error When Bulk Deleting Shipping Services Past Threshold

    When the `Workarea.config.bulk_action_deletion_threshold` is surpassed
    in a query for shipping services to be bulk-deleted, the page that is
    being redirected to expects the models being deleted to have
    **_summary.html.haml** partials co-located in their respective views
    directory for the controller. This isn't the case for shipping services,
    which (along with other models we may wish to bulk-delete) doesn't have
    much information other than the name of the model. For these items,
    introduce a generic **workarea/admin/shared/summary** which links to the
    model and provides its name (or BSON ID if no `#name` method is defined)
    as well as its type in the auxiliary summary info.

    ECOMMERCE-6811
    Tom Scott

*   Fix failing Product Rules system test

    ECOMMERCE-6872
    Curt Howard

*   Add `workarea:services:clean` for Removing Data

    This task runs `docker-compose down -v`, which will remove volumes
    associated with the application. It's useful when transitioning between
    v3.3 and v3.4, so the Mongo data doesn't become corrupted, but should
    only be used if you're OK with your data getting deleted.

    Additionally, an environment variable called `$COMPOSE_ARGUMENTS` was
    introduced to provide a means of passing command-line arguments to the
    `docker-compose` commands that are run using these tasks. For example:

    COMPOSE_ARGUMENTS="--remove-orphans" rails workarea:services:up

    ECOMMERCE-6874
    Tom Scott

*   Fix Issue With Sale Price Creation

    In the admin when creating a new Pricing::Price, the messaging says `Sale Price (defaults to regular)`, but when left blank the Sale Price will be saved as 0.00.

    This fix ensure the value to be cast as nil in the database for the following scenarios:
    - Creating a new price
    - Editing an existing price
    - Creating a new pricing SKU with prices

    ECOMMERCE-6833
    Jeremie Ges

*   Use batches for admin search indexing rake task

    You can hit problems like "sort uses too much memory" from MongoDB when
    you try to index large collections without batches.

    ECOMMERCE-6875
    Ben Crouse

*   Add indexes for defaults scopes that don't have corresponding indexes

    If models have a default scope, they should have a corresponding index. This may not always be caught by the base test suite, but can affect things like console usage, rake tasks, decorations, etc.

    ECOMMERCE-6876
    Ben Crouse

*   Update date and time formats to not use blank padded month day

    ECOMMERCE-6873
    Matt Duffy

*   Validate Product Rule Lucene Query Syntax

    When invalid Lucene queries are saved into product rules, an error would
    occur when attempting to browse the category because the query was never
    checked for valid syntax. As part of the validation process for product
    rules, run a `Search::CategoryBrowse` query for the rule being created
    or edited, and add an error to the model if Elasticsearch responds with
    a server error (5xx) HTTP status. This prevents the rule from being saved
    on the product list in the first place.

    ECOMMERCE-6849
    Tom Scott

*   Disable Slug Input On Released Pages

    Set `disabled: true` on slug inputs when making changes within a
    release, and add help text to explain why it's disabled. Since slugs
    cannot be changed within a release, having this as a field a user can
    type into created a confusing experience.

    ECOMMERCE-6805
    Tom Scott

*   Fix bug with non-inline Datepicker UI

    A regression was introduced when adding the Quick Range feature to the
    datepicker.

    This commit also cleans up the `WORKAREA.datepickerFields` and
    `WORKAREA.datetimepickerFields` modules which were in rough shape. It
    also rewrites and consolidates Teaspoon tests around datepicker fields.

    ECOMMERCE-6757
    Curt Howard



Workarea 3.4.4 (2019-04-30)
--------------------------------------------------------------------------------

*   Remove Hosting Documentation in favor or CLI Cheat Sheet in docs

    ECOMMERCE-6846
    Curt Howard

*   Add Mailchimp signup form to Home Page and Releases in docs

    ECOMMERCE-6852
    Curt Howard

*   Add rails tasks to start dependency services

    This provides 2 tasks to manage dependencies for running Workarea.
    Running `bin/rails worakrea:services:up` and `bin/rails worakrea:services:down`
    will use Docker Compose (https://docs.docker.com/compose/) and
    docker-compose.yml delivered out of the Workarea gem to start/stop Docker
    containers for the correct versions of MongoDB, Redis, and Elasticsearch.

    ECOMMERCE-6789
    Tom Scott

*   Fix running system tests on Chrome 74

    Bumping these dependencies and switching the driver fixes Timeout errors
    when running system tests in Chrome 74, which was released today.

    ECOMMERCE-6867
    Ben Crouse

*   Re-style Checkboxes in Admin to avoid test failure

    A recent update to the CI server required Google Chrome & Chromedriver
    to be upgraded, which caused the BulkActionsSystemTest to fail, due to
    the way the check boxes were being styled.

    The checkbox component has been rewritten ala https://css-tricks.com/the-checkbox-hack/

    ECOMMERCE-6866
    Curt Howard

*   Add rails tasks to start dependency services

    This provides 2 tasks to manage dependencies for running Workarea.
    Running `bin/rails worakrea:services:up` and `bin/rails worakrea:services:down`
    will use Docker Compose (https://docs.docker.com/compose/) and
    docker-compose.yml delivered out of the Workarea gem to start/stop Docker
    containers for the correct versions of MongoDB, Redis, and Elasticsearch.

    ECOMMERCE-6789
    Tom Scott

*   Fix Sidekiq's Redis pool size

    This was still broken in production environments, although I was unable
    to reproduce locally. I worked with hosting to determine this would fix
    the problem.

    ECOMMERCE-6715
    Ben Crouse

*   Add missing reports_access field to config.permissions_fields

    Matt Duffy

*   Display Active State In Mobile Navigation

    Apply the `--selected` modifier to the `mobile-nav__link` element in
    mobile. This was previously not being applied if the link had been
    selected, and thus the active state was not displaying on mobile.

    ECOMMERCE-5691
    Tom Scott



Workarea 3.4.3 (2019-04-16)
--------------------------------------------------------------------------------

*   Add 3.3 to 3.4 upgrade guide to docs

    * Renamed releases docs template to bare and add configuration for upgrade-guides to use the new template.

    ECOMMERCE-6825
    Jake Beresford

*   Rework OrderMetrics#calculate_based_on_items to account for item tax

    It is possible plugins may need to store tax on items rather than
    shipping, particularly when items are not shipped. To account for this,
    merchanise and revenue calculation need to not assume tax is always
    on shipping
    Matt Duffy

*   Move Admin::InsightViewModel::MODELS to a config value for easy extension

    ECOMMERCE-6834
    Matt Duffy

*   Fix Upgrading With App Template

    Some errors were observed when using the `rails app:template` task with
    the built-in app template for upgrade purposes, since there are a
    significant amount of changes in the app template for v3.4 (like
    auto-configuration). Workarea has replaced the usage of `@app_name` with
    the `#app_name` method to ensure that it's set before attempting to
    perform text processing operations, and the template will no longer
    write to `Gemfile` if it doesn't have to.

    ECOMMERCE-6830
    Tom Scott

*   Fix up OOTB app template offering

    Some updates were needed after the Rails upgrade in Workarea v3.4

    ECOMMERCE-6821
    Curt Howard

*   Prevent Logging Controller Parameters in Logstash

    Logstasher was previously configured to send controller params in
    Logstash logs, but this caused errors in Elasticsearch as each new param
    became a new mapping as it was indexed. This very quickly exhausted the
    amount of mappings allowed within the Elasticsearch index. Workarea no
    longer enables this field out of the box, so that logstash will continue
    to work as normal.

    ECOMMERCE-6829
    Tom Scott

*   Add 'Add a Report' and 'Add Metrics' documentation

    ECOMMERCE-6815
    Matt Duffy

*   Fix occasionally failing test around marking discounts redeemed

    We need to specify a sort for consistency here.

    ECOMMERCE-6818
    Ben Crouse

*   Remove @ in activity time

    This looks weird when the value is "@ 5 minutes ago" or "@ 4/4/2019"

    ECOMMERCE-6817
    Ben Crouse

*   Fix audit log entries not being recorded in Sidekiq jobs

    This is a carryover from the v2.x days. We've never updated the app to log the current user through Sidekiq, so with new functionality like bulk edit, delete, trash, etc we'll need work done in the background to be recorded as well.

    ECOMMERCE-6812
    Ben Crouse

*   Fix export samples for large collections

    The `skip` that is done to get random samples can be quite slow if
    MongoDB needs to page. A simpler way is to grap the first N number of
    documents since they don't really need to be random.

    ECOMMERCE-6813
    Ben Crouse

*   improve-docs-aside-menu-ui

    Enabled close/open functionality on aside menu. Styled sub parent’s to improve readability of the submenu navigation when going to 3 levels.

    Updated nav JS and styling, as per Jake’s feedback

    Improved nav CSS selector specificity, added comments to selectors
    James Van Arsdale III

*   Update inherting from ApplicationController for consistency

    ECOMMERCE-6816
    Matt Duffy

*   Update inherting from ApplicationController for consistency

    ECOMMERCE-6816
    Matt Duffy

*   Update inherting from ApplicationController for consistency

    ECOMMERCE-6816
    Matt Duffy

*   Make inherting from ApplicationController consistent across controllers

    ECOMMERCE-6816
    Matt Duffy

*   Add reports dashboard append point

    Matt Duffy

*   Fix CHANGELOG

    Curt Howard

*   Bump Puma dependency

    Bump this dependency to fix a bug in Kubernetes environments. The bug is a nasty one, where logouts happen frequently, and semi randomly, due to an incorrect IP being passed downstream by Puma.

    ECOMMERCE-6810
    Ben Crouse



Workarea 3.4.2 (2019-04-02)
--------------------------------------------------------------------------------

*   Add Feedback UI to articles in docs

    ECOMMERCE-6739
    Curt Howard

*   Fix scroll API pagination in admin search query wrapper

    The call to `page` here resets the size of the page, so we need to set
    that every call.

    ECOMMERCE-6721
    Ben Crouse

*   Fix I18n JS exclusions

    Changes in the gem we use caused our exclusions to stop working. By upgrading the gem, we can make use of a provided way to do this now.

    ECOMMERCE-6808
    Ben Crouse

*   Fix Puma clustering in development mode

    A combination of Puma forking, Rails constant reloading cause Sidekiq callbacks to miss workers that exist in the host app.

    Rails doesn't default to doing clustered mode in development (for good reason, the forking slows things down) so we'll allow that to be configured by an ENV var for hosting but default to not clustered in the platform.

    ECOMMERCE-6804
    Ben Crouse

*   Fix Applying Redundant Promo Codes

    When a user adds multiple promo codes that belong to the same discount
    to an order, only mark the first one as being used so other users can
    take advantage of the other promo codes.

    ECOMMERCE-5745
    Tom Scott

*   Add user tags conditon for discounts

    ECOMMERCE-6794
    Matt Duffy

*   Use strings for ids in IndexCategoryChangesTest to better reflect real ids

    ECOMMERCE-6803
    Matt Duffy

*   Fix Copy on "New Primary Navigation" Admin Page

    Remove an extra `'` in the description for the "New Primary Navigation".

    Discovered by @keverham

    ECOMMERCE-6702
    Tom Scott

*   Allow for multiple rows of products in Product List UI

    Now each "item" within the product list will render as a table row,
    allowing multiple rows of products to be displayed properly within the
    same product list.

    ECOMMERCE-6768
    Curt Howard

*   Add "Swappable List Data Structure" Guide

    Write guide for the `Workarea::SwappableList` data structure used in
    configuration.

    ECOMMERCE-6734
    Tom Scott

*   Fix current release not resetting after a raise

    Similar to a recently discovered bug in Sidekiq callbacks.

    ECOMMERCE-6759
    Ben Crouse

*   Add Breadcrumb Titles to Default Category settings

    ECOMMERCE-6745
    Curt Howard

*   Update Label Attributes to Match Cloned Field ID

    In `WORKAREA.cloneableRows`, the `id` of any `<input>` element that is
    cloned will be updated to have the suffix of `_cloned`, in order to
    differentiate it from the original element. This logic has been carried
    over to `<label>` elements so the `for` and `id` values match for each
    cloned row.

    ECOMMERCE-5931
    Tom Scott



Workarea 3.4.1 (2019-03-19)
--------------------------------------------------------------------------------

*   Fix release jobs not unscheduled when times are removed

    ECOMMERCE-6755
    Ben Crouse

*   Unfix Pagination

    The previous fix pushes more objects into History state and causes a
    bizarre regression. This will be fixed in an upcoming release.

    * Reverts "Fix scroll position bug for pagination in iOS Chrome"

    This reverts commit 087aa93f4206cb6ed9f155ee1e924f973dcac35e.

    ECOMMERCE-6652
    Curt Howard

*   Set Default `From:` Address at Time of Delivery

    For multi-site implementations, the `config.email_from` address could not be
    overwritten based on the configuration of different sites, due to the
    way it was being set in the `Workarea::ApplicationMailer`. As a result,
    an incorrect email address appeared as the "From:" of certain multi-site
    applications. This has been resolved by introducing a lambda as the
    value for the `default from:` in all emails delivered by the out-of-box
    mailers, evaluated when the message is delivered. Ensures that each mail
    always uses the most up-to-date configuration.

    ECOMMERCE-6732
    Tom Scott

*   Set Default `From:` Address at Time of Delivery

    For multi-site implementations, the `config.email_from` address could not be
    overwritten based on the configuration of different sites, due to the
    way it was being set in the `Storefront::ApplicationMailer`. As a result,
    an incorrect email address appeared as the "From:" of certain multi-site
    applications. This has been resolved by introducing a lambda as the
    value for the `default from:` in Storefront emails, which is evaluated
    when the message is delivered, and always uses the most up-to-date
    configuration.

    ECOMMERCE-6732
    Tom Scott

*   Fix inconsistent shading on some dashboards

    ECOMMERCE-6754
    Ben Crouse

*   Fix Sidekiq callback workers not restoring state when error raised in block

    This can lead to workers that are disabled/enabled, async/inline when
    the block has run.

    ECOMMERCE-6753
    Ben Crouse

*   Fix "StoreFront" => "Storefront" typos in docs

    Make sure we're spelling the name of the most decorated module in
    Workarea history correctly.

    ECOMMERCE-6750
    Tom Scott

*   Fix Typo in CSS for Content Preview Visibility

    Ensure `position: initial` is spelled correctly so the `else` condition
    of the `content-preview-visibility-state()` mixin defined in this file
    will work.

    Discovered (and solved) by @keverham

    ECOMMERCE-6746
    Tom Scott



Workarea 3.4.0 (2019-03-13)
--------------------------------------------------------------------------------

*   Fix tax in the sales by category report

    ECOMMERCE-6479
    Ben Crouse

*   Add release notes for Workarea 3.4

    ECOMMERCE-6735
    Chris Cressman

*   Fix using "category" verbiage in product rules.

    When these are shown for search customizations, this doesn't make sense.

    ECOMMERCE-6248
    Ben Crouse

*   Remove order aggregations from index

    This info is better obtained through the new reporting area in the
    admin.
    Ben Crouse

*   Index category breadcrumbs for use in xhr admin queries

    ECOMMERCE-6710
    Matt Duffy

*   Disable Shipping Method Selection When Processing

    Prevent shipping method from getting selected when Workarea is still
    pricing the order. Additionally, set the `WORKAREA.shippingServices.requestTimeout`
    to '1' in order to prevent any other parallel shipping estimate requests from
    causing a locked order and showing strange errors to the user, including
    flashes of error text and incorrect shipping price totals in the
    summary. By disabling the radio input whenever a shipping service is
    selected, and re-enabling it when the request is complete, the scenario
    of obtaining an incorrect shipping price and thus being kicked back to
    shipping to re-select is no longer possible to trigger.

    ECOMMERCE-6692
    Tom Scott

*   Prevent Disconnection Between Shipping Method Selection And Shipping Price

    Ensure order locking doesn't redirect the user to the `/cart` route,
    which is _not_ protected by `#with_order_lock`, and can potentially
    cause a race condition in pricing.

    ECOMMERCE-6692
    Tom Scott

*   Align admin index date filtering with report date filtering

    This commit does two things:
    * Aligns filtering behavior for user consistency
    * Fixes a bug with timezone-handling making inaccurate results

    ECOMMERCE-6713
    Ben Crouse

*   Remove deprecations and clean up TODOs for v3.4 release

    Ben Crouse

*   Add service class for adding items to a cart

    * Add AddMultipleCartItems class
    * Add case insensitive finds to Product#find_by_sku

    ECOMMERCE-6688
    Matt Duffy

*   Add User agent to order model

    Add the user agent to the order model for convenience.

    ECOMMERCE-6707
    Jeff Yucis

*   Stop suppressing analytics calls for admin users

    This should better synchronize our Analytics and Insights efforts.

    ECOMMERCE-6726
    Curt Howard

*   Fix email sent in unit tests

    This can result in failing unit tests due to dependencies for examples, emails rendering things from search indexes.

    ECOMMERCE-6727
    Ben Crouse

*   Display Browsing Controls & Filters above Workflow Bar

    ECOMMERCE-6723
    Curt Howard

*   Center browsing control filter dropdowns with respect to their trigger

    Allows more flexibility for use outside of the traditional browsing
    control UI.

    ECOMMERCE-6536
    Curt Howard

*   Move low inventory report into reports section

    ECOMMERCE-6696
    Matt Duffy

*   Add Breadcrumb trail to category Remote Select UIs

    ECOMMERCE-6710
    Curt Howard

*   Update 'Development Environment' doc for Workarea 3.4

    ECOMMERCE-6693
    Chris Cressman

*   Write "Add, Remove, or Change a Mongoid Validation" Guide

    Add guide explaining how to manipulate model validation, including
    detailed information on how to `unvalidate` data as well.

    ECOMMERCE-6695
    Tom Scott

*   Fix Sidekiq autoconfig misconfiguring concurrency

    This is causing timeouts in background jobs because they're aren't
    enough connections available in the pool for the number of workers.

    ECOMMERCE-6715
    Ben Crouse

*   Use search query gid for search via param, generate breadcrumbs from search

    ECOMMERCE-6697
    Matt Duffy

*   Set reports params as HashWithIndifferentAccess to ensure key availability

    ECOMMERCE-6706
    Matt Duffy

*   Trigger IndexSkus on touch of pricing or inventory

    Fixes issues around pricing where prices changing need to update
    the product index but were not.

    ECOMMERCE-6719
    Matt Duffy

*   Fix issues around order status display

    Matt Duffy

*   Search Countries By Unofficial Name

    Using an address verification or geocoding service (like Bing maps)
    which doesn't conform to the ISO3166 standard of naming and referencing
    countries caused an error when the address came back to Workarea. This
    is due to the fact that these services can potentially use the
    "unofficial" name of the country, like in the case of "United States"
    (unofficial) vs "United States of America" (official). To resolve this,
    Workarea's `Country.search_for` method now looks through the list of
    unofficial names (case-insensitively) if no matches can be found in the
    official name, alpha2, or alpha3 shorthand codes.

    ECOMMERCE-6476
    Tom Scott

*   Do not suppress analytics callbacks for admin in development environments

    In dev you're probably safe firing analytics callbacks for admin because you shouldn't have the production configuration for analytics services, otherwise a bigger concern would be firing non-admin events in dev.

    ECOMMERCE-6708
    Jake Beresford



Workarea 3.4.0.beta.2 (2019-03-05)
--------------------------------------------------------------------------------

*   Fix floating clear action within single Select 2 UIs

    ECOMMERCE-6704
    Curt Howard

*   Conditionaly show placed at field at on admin order index page

    Conditionally showing the placed at field on the order index page allows
    non placed orders to be indexed into admin search and not throw an
    error on display

    ECOMMERCE-6705
    Jeff Yucis

*   Don't set release when managing comments

    Commenting on a releasable while editing a release can cause the loss
    of release changes when a comment updates the subscribers of the
    commentable. Not setting release when adding comments prevents this.

    ECOMMERCE-6701
    Matt Duffy

*   Mark store credit authorize transactions as purchase actions

    When managing orders, particularly refunds and cancellations, store
    credit would not be processed correctly since there is no capturing
    of store credit funds. Setting the authorization transaction as a
    purchase transaction allows orders with store credit to be canceled
    and refunded as expected

    ECOMMERCE-6689
    Matt Duffy

*   Write "Add, Remove, Group, and Sort Storefront Search Filters" Guide

    This guide goes into depth on how to manipulate search filters for
    situations that surpass the abilities of the admin interface. In this
    guide, developers learn how to group filters together, add custom filter
    types, programmatically sort filters, and omit filters from display.

    ECOMMERCE-6494
    Tom Scott

*   Prevent Editing when Sorting Content Blocks

    A nicer UX is to allow blocks to be sorted without the need of the
    Content Editing UI to open at the end of the process.

    ECOMMERCE-6691
    Curt Howard

*   Further improve Dashboard, Index & Insight UIs

    ECOMMERCE-6681
    Curt Howard

*   Fix Inability to Remove Navigable Association from Taxon Through the Admin

    When associating part of the taxonomy with a "navigable" page, category,
    or product, admins were not able to remove the association later on if
    they so chose. The `Navigation::Taxon#navigable` property would only be
    set if a navigable object was sent over in params, and this contrasts
    with how Select2 is implemented to send over a blank value when no
    selection is made. Workarea will now always set the navigable to the
    contents of the params.

    ECOMMERCE-6682
    Tom Scott

*   Update font-url() Example in Email Template

    The current example for adding a font to emails uses Ruby interpolation
    to inject the URL to the font in CSS. However, Rails' out-of-box SCSS
    integration already includes a `font-url()` helper that will automatically
    load the Sprockets fingerprinted asset in production, and look through plugin
    and gem paths for the asset partial string.

    Discovered (and solved) by @keverham

    ECOMMERCE-6670
    Tom Scott

*   Add insight for sales by navigation

    Ben Crouse

*   Ensure W3C Validation Compliance

    After upgrading the Storefront for a11y compliance we failed a few W3C
    validation checks. This work ensures adherence to accessibility and HTML
    validity best practices.

    ECOMMERCE-6633
    Curt Howard

*   Add caching for reports

    Default is 1 hour, cache key includes the current hour. So report data
    will be refreshed at minimum on the hour, every hour.

    ECOMMERCE-6630
    Ben Crouse

*   Make Tags Searchable For All Models

    Ensure that if a model can be tagged, it can be searched by that tag in
    admin. This is accomplished by returning the tags Array in the base
    `Search::Admin#keywords` method by default, rather than the empty Array
    that it was defined to return previously. Ensure all subclasses of
    `Search::Admin` that define a keywords method also call `super`, so
    this feature will be available to those models as well.

    Additionally, with this change Workarea now includes the `model.id` in
    keywords, so searching for a BSON ID of any model that's indexed in
    admin search will return the model to you.

    ECOMMERCE-6678
    ECOMMERCE-6677
    Tom Scott

*   Expire Extra Admin Cookies

    The `:analytics` and `:cache` cookies were not being expired at the
    same time as `:user_id`, resulting in those cookies lingering around
    after an admin's session has expired. This causes errors when developers
    are testing things related to cache and analytics, because those cookies
    prevent the aforementioned functionality from succeeding. Workarea now
    expires these cookies at the same time as the user ID, rather than just
    when the session no longer exists.

    ECOMMERCE-6369
    Tom Scott

*   Remove legacy analytics code

    All functionality from the Analytics module has been reimplemented in
    Metrics, Reports, and Insights so this is dead code now. This is code
    that isn't regularly decorated, so migration should be relatively
    straightforward.

    ECOMMERCE-6630
    Ben Crouse

*   Switch status report mail to use new dashboards data

    ECOMMERCE-6630
    Ben Crouse

*   Ensure String Values When Grouping Images without Options in the Option Thumbnails Template

    Typically, the `Catalog::ProductImage#option` value is a String, but it
    can be nil when images are uploaded programmatically, such as through
    the bulk upload or CSV import tools, or potentially through a custom
    data integration of some kind. Ensure that this image option is converted
    to a String in the `Storefront::OptionThumbnailsViewModel#images_without_options`
    method, so that the `option_thumbnails` product template works as
    expected.

    ECOMMERCE-6635
    Tom Scott

*   Release verasion 3.0.52

    Curt Howard

*   Chunk product_grid items into rows of four in mailers

    ECOMMERCE-6642
    Curt Howard



Workarea 3.4.0.beta.1 (2019-02-20)
--------------------------------------------------------------------------------

*   Ensure admin pages touch auth cookies

    Because we aren't touching this in every access to current_user, we'll
    want to ensure this gets touched continuously while using the admin.

    ECOMMERCE-6453
    Ben Crouse

*   Digest Pricing Cache Key Contents

    Convert the contents of a pricing cache key into a SHA1 digest so it's
    easier to read in the data.

    ECOMMERCE-6621
    Tom Scott

*   Design improvements to dashboards

    Ben Crouse

*   Do better with Reports Dashboard

    ECOMMERCE-6641
    Curt Howard

*   Clarify fulfillment state when fulfillment is not persisted

    * Adds Not Available status for fulfillment
    * Always show fulfillment card on orders#show

    ECOMMERCE-6680
    Matt Duffy

*   Inform Admins Of Default Category Cache

    If an admin changes a product's calculated default category and goes to
    view the product immediately afterward, they will not see their changes
    reflected in the "Default Category" pane of the product's
    categorizations page. Add text to the help bubble explaining this
    behavior, since this data is cached at a very low level and cannot be
    changed for this admin page.

    ECOMMERCE-6653
    Tom Scott

*   Force SSL In Deployed Environments

    Set `config.force_ssl = true` to enable HSTS and prevent non-secure
    clients from connecting to any deployed environment. Applies to all
    environment-specific configuration files in `./config/environments`
    that are not typically run on a local developer machine, so
    "development" and "test" are omitted.

    ECOMMERCE-6632
    Tom Scott

*   Return More Than 10 Results In Category Percolator

    When finding categories for a product, provide a `:size` parameter equal
    to the total count of all categories, so that any category on the system
    that matches the product by rules can be viewed on the product's admin
    page. Previously, since no `:size` param was applied, Elasticsearch
    defaulted to returning 10 results.

    Discovered (and solved) by @sstaub

    ECOMMERCE-5012
    Tom Scott

*   Fix scroll position bug for pagination in iOS Chrome

    As it turns out, Chrome, in iOS, doesn't want to replace the state of a
    History object that does not yet exist. Who'da thunk?

    ECOMMERCE-6652
    Curt Howard

*   Fix issue with loading bulk action results from query

    ECOMMERCE-6674
    Matt Duffy

*   Add filter on searches report

    * view searches with results, without results, or all
    * remove SearchesWithoutResults report

    ECOMMERCE-6664
    Matt Duffy

*   Expand ruby compatibility up to 2.6

    ECOMMERCE-6663
    Matt Duffy

*   Hide Signup Form On Confirmation When Account Already Exists

    When a User's account can be found by the same email that a guest is
    checking out with, don't show the "Create Account" form on checkout
    confirmation since this will always lead to an error.

    ECOMMERCE-6507
    Tom Scott

*   Use insights for top/trending in the admin

    ECOMMERCE-6665
    Ben Crouse

*   Fixes malformed closing span tag

    ECOMMERCE-6673
    Lucas Boyd

*   Add option to defer publishing in workflow

    ECOMMERCE-6661
    Matt Duffy

*   Improve Transactional Email index UI

    ECOMMERCE-6660
    Curt Howard

*   Replace Order.placed with basic scope

    This method is no longer used significantly, and the scope provides
    a clearer, more obvious purpose.
    Matt Duffy

*   Add more search insights

    ECOMMERCE-6629
    Matt Duffy

*   Add search weekly metrics

    ECOMMERCE-6629
    Matt Duffy

*   touch pricing sku when prices are saved

    Matt Duffy

*   Add a custom feature.js test append point

    ECOMMERCE-6643
    Curt Howard

*   Add product-details__heading class for direct styling hook

    ECOMMERCE-6363
    Curt Howard

*   Add Quick Range select to Date Selector UI

    ECOMMERCE-6344
    Curt Howard

*   Add newest products insight

    ECOMMERCE-6628
    Matt Duffy

*   Disable scrollToButton When Rendered Within Dialog

    The `scrollToButton` module automatically scrolls down the page towards
    the anchor that the href of the link was pointing to, but when this
    occurs within a dialog it can accidentally cause a scroll to the wrong
    element. This manifested itself when the reviews and quickview plugins
    were installed and the "Read Reviews" link was clicked while a product
    was being quick-viewed.

    ECOMMERCE-6510
    Tom Scott

*   Fix Regression in Product Rule Inverse Relationships

    This was originally working in v3.3 and below, but for some reason in
    v3.4 the `inverse_of:` rules the product rules embedding macro got
    removed, causing issues in the tests when a previous ticket was merged
    up.

    ECOMMERCE-6650
    Tom Scott

*   Prevent IndexPaymentTransactions from indexing unplaced orders

    ECOMMERCE-6649
    Matt Duffy

*   Use metrics in navigation tracking

    ECOMMERCE-6630
    Ben Crouse

*   Create insights generation rake task

    This task will loop through all orders and create the matching metrics.
    It will then use those metrics to generate insights for the past 4
    weeks.

    ECOMMERCE-6630
    Ben Crouse

*   Add permissions for reports

    ECOMMERCE-6637
    Ben Crouse

*   Integrate new insights into the insights content block

    ECOMMERCE-6630
    Ben Crouse

*   add mongoid client configuration class, add client for metrics

    ECOMMERCE-6563
    Matt Duffy

*   Update Mini-Insight Card UI

    ECOMMERCE-6555
    Curt Howard

*   Design Insight UI

    ECOMMERCE-6555
    Curt Howard

*   Only Link Primary Navigation For Navigable Taxons

    Taxons that are not navigable cannot be rendered with a `#link_to`,
    because the href argument passed into the helper is `nil` and Rails is
    converting that to the URL of the current page, making it appear as
    though the link is pointing to the wrong place. Use `<span>` tags with
    the same `.primary-nav__link` classes as the primary nav links in place
    of `<a>` tags so these items are not clickable, but can be styled the
    same as regular links.

    ECOMMERCE-6556
    Tom Scott

*   Update seeds for new insights

    ECOMMERCE-6630
    Ben Crouse

*   Move data tracking into Metrics namespace

    ECOMMERCE-6630
    Ben Crouse

*   Add date range selection to dashboards

    ECOMMERCE-6613
    Ben Crouse

*   Integrate new insights throughout admin

    ECOMMERCE-6613
    Ben Crouse

*   Add and adjust append points for storefront orders

    Matt Duffy

*   Add validation to product image direct uploads

    * Validate presence of product
    * Validate correct filename format
    * Output relevant errors in UI

    ECOMMERCE-6608
    Curt Howard

*   Remove CleanUniqueJobs Worker

    In sidekiq-unique-jobs v6, the `Util.expire` method was removed because
    it's no longer necessary. The worker that we used to periodically call
    this method is no longer necessary, so it's been removed from Workarea
    v3.4.

    ECOMMERCE-6623
    Tom Scott

*   Redesign search insights card

    ECOMMERCE-6613
    Ben Crouse

*   Integrate insights data into product sorting

    ECOMMERCE-6618
    Ben Crouse

*   Integrate insights tracking to the storefront

    ECOMMERCE-6618
    Ben Crouse

*   Add via tracking to order items

    This will allow reporting on categories and searches to reflect orders
    and traffic actually going through those pages.

    ECOMMERCE-6618
    Ben Crouse

*   Improve New Search Customization flow

    ECOMMERCE-6530
    Curt Howard

*   Remove placeholders from index

    ECOMMERCE-6615
    Curt Howard

*   Add default factory configuration to Workarea::Configuration.config directly

    plugins, like multi-site, can define the Workarea.config method, which causes
    the factory defaults configuration to apply only to a single site. This breaks
    tests that add new sites and try to use factories since that configuration does
    not exist. Modifying the configuration object directly ensures the factory defaults
    apply globally.

    ECOMMERCE-6619
    Matt Duffy

*   Added the ability to display the selected starting taxon in taxonomy content blocks.

    Offers greater control over the structure of navigation menus by allowing the admin user control over whether the selected starting taxon should be displayed within a taxonomy content block.

    * Supports placeholder taxons as starting node
    * For starting taxons with no children, boolean determines style of taxon displayed

    ECOMMERCE-6562
    Jake Beresford

*   Redesign discounts insights

    ECOMMERCE-6613
    Ben Crouse

*   Redesign customer insights card

    ECOMMERCE-6613
    Ben Crouse

*   Redesign category insight page

    ECOMMERCE-6613
    Ben Crouse

*   Redesign product insights page

    ECOMMERCE-6613
    Ben Crouse

*   Configure Logstasher with Environment Variable

    Logstasher will automatically configure when the `$WORKAREA_LOGSTASH`
    environment variable is set. Previously, this would happen when the
    `Rails.env` was not development or test, but this caused issues on
    environments which are not deployed on Kubernetes, like demos for new
    prospective clients and testing environments for the product development
    team.

    ECOMMERCE-6606
    Tom Scott

*   Improve Settings Dashboard UI

    ECOMMERCE-6532
    Curt Howard

*   Remove unnecessary titleization from price adjustment descriptions

    ECOMMERCE-6596
    Curt Howard

*   Update graphs throughout admin to use Chartkick

    Also sets up styling for charts admin-wide.

    ECOMMERCE-6590
    Ben Crouse

*   Remove now-unused JS from manifests

    We're leaving these files to make it easier on upgrades to v3.4.

    ECOMMERCE-6590
    Ben Crouse

*   Add graphs to marketing dashboard

    ECOMMERCE-6590
    Ben Crouse

*   Add graphs to search dashboard

    ECOMMERCE-6590
    Ben Crouse

*   Add graphs to people dashbaord

    ECOMMERCE-6590
    Ben Crouse

*   Add graph cards to orders dashboard

    ECOMMERCE-6590
    Ben Crouse

*   Add graph cards to main dashboard

    ECOMMERCE-6590
    Ben Crouse

*   Create insights-based dashboards

    ECOMMERCE-6590
    Ben Crouse

*   Improve Direct Upload UI Failure State

    * Order failures in table before successful uploads
    * Scroll user to the top of the UI for review on completion

    ECOMMERCE-6609
    Curt Howard

*   Add thresholds to Direct Upload UI

    ECOMMERCE-6610
    Curt Howard

*   Fallback to sorting product images by most recently updated

    If an image is uploaded with the same position (through direct uploads
    or API), fallback to sorting by most recent, as this is most likely the
    intent of the merchandiser.

    ECOMMERCE-6265
    Ben Crouse

*   Add og:image:secure_url

    ECOMMERCE-6407
    Curt Howard

*   Hide Puma Startup Output In Capybara Tests

    Add the `:Silent` flag to the Capybara server configuration in
    `Workarea::SystemTest` so that startup output from Puma is hidden. This
    decreases noise in the test output so when viewing logs, or when running
    system tests, your success/failure messages are easier to see.

    ECOMMERCE-6577
    Tom Scott

*   Center browsing control filter dropdowns with respect to their trigger

    Allows more flexibility for use outside of the traditional browsing
    control UI.

    ECOMMERCE-6536
    Curt Howard

*   Add most discount given insight

    ECOMMERCE-6569
    Ben Crouse

*   Add top discounts insight

    ECOMMERCE-6569
    Ben Crouse

*   Add popular searches without results insight

    ECOMMERCE-6569
    Ben Crouse

*   Add release reminder insight

    ECOMMERCE-6569
    Ben Crouse

*   Add upcoming releases insight

    ECOMMERCE-6569
    Ben Crouse

*   Add trending products insight

    ECOMMERCE-6569
    Ben Crouse

*   Add popular searches insight

    ECOMMERCE-6569
    Ben Crouse

*   Add customer acquisition insight

    ECOMMERCE-6514
    Ben Crouse

*   Add top categories insight

    ECOMMERCE-6514
    Ben Crouse

*   Add top products insight

    ECOMMERCE-6514
    Ben Crouse

*   Add products purchased together insight

    ECOMMERCE-6514
    Ben Crouse

*   Add repeat purchase rate insight

    ECOMMERCE-6569
    Ben Crouse

*   Include Product as a 'links to' target for Taxons.

    ECOMMERCE-6557
    Mark Platt

*   Use docker for testing dependencies in CI scripts

    This will allow us to control versions much more easily.

    ECOMMERCE-6566
    Ben Crouse

*   Add low AOV customers insight

    ECOMMERCE-6514
    Ben Crouse

*   Add customers at risk insight

    ECOMMERCE-6514
    Ben Crouse

*   Prevent non-admin users from modifying carts with pricing overrides

    ECOMMERCE-6552
    Matt Duffy

*   Set unit prices explicity for order pricing overrides

    Rather than defining adjustment amounts for items, admin define the
    desired price for items.

    ECOMMERCE-6552
    Matt Duffy

*   Add order price overriding from OMS

    ECOMMERCE-6552
    Matt Duffy

*   Send Status Report Email To Multiple Recipients

    Previously each status report email was calculated and delivered
    explicitly for each admin on the site. This is a potentially expensive
    operation, so the report mailer has been altered to accept an array of
    emails and send one email using `Bcc:` for all addresses at the same
    time.

    ECOMMERCE-5683
    Tom Scott

*   Allow reordering on multiple-choice remote selects in admin

    ECOMMERCE-6522
    Curt Howard

*   Add best full price customers insight

    ECOMMERCE-6514
    Ben Crouse

*   Add best customers insights

    Along with framework for daily/monthly insight generation

    ECOMMERCE-6514
    Ben Crouse

*   Add cold products insight

    ECOMMERCE-6514
    Ben Crouse

*   Add hot products insight

    ECOMMERCE-6514
    Ben Crouse

*   Add most discounted products insight

    ECOMMERCE-6514
    Ben Crouse

*   Add non-sellers insight

    ECOMMERCE-6514
    Ben Crouse

*   Add promising products insight

    ECOMMERCE-6514
    Ben Crouse

*   Add insights seeds

    Use product sales data from an actual live site (anonymized)

    ECOMMERCE-6514
    Ben Crouse

*   Add star products insight

    ECOMMERCE-6514
    Ben Crouse

*   Add basic rendering of insights

    ECOMMERCE-6514
    Ben Crouse

*   Add products to improve insight generation

    ECOMMERCE-6514
    Ben Crouse

*   Don't do unneeded ES updates when cleaning orders

    This is crufty code from when we were indexing all order statuses into the admin. Now that we only index placed orders, these are just wasteful calls to ES.

    ECOMMERCE-6549
    Ben Crouse

*   Add Class For Inventory Status on Product Detail

    Instead of reusing the `.value__note` class for the inventory status on
    the product detail page, create a special
    `.product-details__inventory-status` so this element is easier to style.
    Retains the `display: block` setting from `.value__note` by way of the
    fact that it is now being rendered as a `<p>` tag.

    ECOMMERCE-6469
    Tom Scott

*   Allow direct asset uploading from within content blocks

    ECOMMERCE-6534
    Curt Howard

*   Fix scoping bug in WORKAREA.directUploads

    ECOMMERCE-6534
    Curt Howard

*   Prevent double click requirement for search autocomplete on touch devices

    The mouseenter event triggers a hover state on mobile devices, by unbinding this event listener in jquery UI autocomplete#open we can treat the touch event as a click, meaning the user no longer has to double click search autocomplete results to follow the link.

    ECOMMERCE-6511
    Jake Beresford

*   Allow flexibility in skipping appends

    ECOMMERCE-6445
    Curt Howard

*   Force Dragonfly attachments to be private

    ECOMMERCE-6520
    Curt Howard

*   Improve favicons feature

    * Indicate which assets are tagged as Favicon in the admin
    * Fall back to a favicon placeholder if none are present

    ECOMMERCE-6435
    Curt Howard

*   Add the correct path for serviceworkers to precompile

    ECOMMERCE-6390
    Curt Howard

*   Fix admin analytics system tests

    ECOMMERCE-6493
    Matt Duffy

*   Add searches report

    ECOMMERCE-6501
    Ben Crouse

*   Add searches without results report

    ECOMMERCE-6500
    Ben Crouse

*   Add append point in product pricing partial

    Matt Duffy

*   Add each_by for Elasticsearch queries

    This should be used for feed generation or other bulk operations based
    on Elasticsearch queries.

    It's highly recommended to use Elasticsearch for feeds!

    ECOMMERCE-6446
    Ben Crouse

*   Add first-time vs returning sales report

    ECOMMERCE-6499
    Ben Crouse

*   Add average order value report

    ECOMMERCE-6495
    Ben Crouse

*   Add sales by categories report

    ECOMMERCE-6479
    Ben Crouse

*   Add sales by country report

    ECOMMERCE-6478
    Ben Crouse

*   Improve Direct Uploads UI

    * Disallow processing more than one batch at a time
    * Disallow navigating away from Direct Upload while processing
    * Improve UI & UX
    * Add Style Guide

    ECOMMERCE-6424
    Curt Howard

*   Add one time customers report

    ECOMMERCE-6475
    Ben Crouse

*   Add returning customers report

    ECOMMERCE-6475
    Ben Crouse

*   Add sales by discount report

    ECOMMERCE-6474
    Ben Crouse

*   Add sales by traffic referrer report

    ECOMMERCE-6459
    Ben Crouse

*   Add sales by SKU report

    ECOMMERCE-6458
    Ben Crouse

*   Add sales over time report

    ECOMMERCE-6457
    Ben Crouse

*   Move default configuration out of app template, into gems

    This allows us to more easily rollout changes to configuration, since we
    won't have to coordinate many repos making changes.

    ECOMMERCE-6452
    Ben Crouse

*   Add css classes to checkout payment methods

    Matt Duffy

*   Remove defining of #respond_to? in favor of #respond_to_missing?

    ECOMMERCE-6461
    Matt Duffy

*   Update implementation of breakPoints.currentlyLess than to return false if argument is not a breakpoint

    This change makes the API of breakPoints more predictable. Previously if the argument was not a breakpoint name, or was some unexpected data type (like undefined) the module would return true.

    ECOMMERCE-6425
    Jake Beresford

*   Allow OpenGraph image override for Contentable models

    Categories, Searches, Pages & the Home Page allow for an asset to be
    chosen as the OpenGraph image.

    ECOMMERCE-6407
    Curt Howard

*   Provide support for Progressive Web Applications

    ECOMMERCE-6390
    ECOMMERCE-6392
    ECOMMERCE-6437
    Curt Howard

*   Fix some issues with HTTP caching

    In investigation of adding a check for safe HTTP caching, I uncovered
    some issues with our current handling of some things.

    The initial safety-check for HTTP turned up some behavior that was
    difficult to work around, so that is on the backburner for now.

    ECOMMERCE-6453
    Ben Crouse

*   Add a default meta_description fallback if one is not present

    ECOMMERCE-6396
    Curt Howard

*   Add a configurable default meta description as a fallback

    ECOMMERCE-6396
    Curt Howard

*   Add reports infrastructure and sales by product report

    This establishes a baseline for further reporting

    ECOMMERCE-6322
    Ben Crouse

*   Adds a new generator for creating JS adapters

    * Update name of 'context' option to 'engine' in js_module generator

    ECOMMERCE-6430
    Jake Beresford

*   Add helper methods to Shipping::Sku

    Update Shipping::Sku dimensions to match ActiveShipping::Package
    dimensions

    ECOMMERCE-6109
    Eric Pigeon

*   Add Direct Uploads for Assets and Product Images

    This feature replaces the previous Dropzone.js-based bulk image uploader
    with a custom solution that allows Assets and Product Images to be
    uploaded directly to S3 from the Admin.

    ECOMMERCE-5853
    ECOMMERCE-6265
    Ben Crouse

*   Add managed Puma config

    This will allow us to rollout Puma config changes in patch releases, minors, etc without needing everyone to update their apps.

    ECOMMERCE-6413
    Ben Crouse

*   Add managed Puma config

    This will allow us to rollout Puma config changes in patch releases, minors, etc without needing everyone to update their apps.

    ECOMMERCE-6413
    Ben Crouse

*   Clean up product index to use same placeholder image as everywhere else

    (minor)
    Ben Crouse

*   Add search analyze

    This feature is mostly focused on helping developers debug and
    understand what's going on when a retailer is confused by search
    behavior.

    ECOMMERCE-6246
    Ben Crouse

*   Add yard to Fulfillment ship_items and cancel_items

    ECOMMERCE-6270
    Eric Pigeon

*   Move factory method default attributes to configuration

    ECOMMERCE-6382
    Matt Duffy

*   Align prices table columns across index, edit, and new templates.

    (minor)
    Matt Duffy

*   Set cookie for traffic referrer, set referrer on order

    ECOMMERCE-6342
    Matt Duffy

*   Adds optional note and tooltip attributes to all Content::Field types

    The addition of 'note' and 'tooltip' attributes to content fields allows the developer to provide further information to admin users about the intent of a field within a block type. This may be used to provide recommended asset sizes, explain how to use a complex field, or remind why alt text is important.

    ECOMMERCE-6371
    Jake Beresford

*   Upgrade Sidekiq to latest minor version

    Some worthwhile improvements in the CHANGELOG.

    ECOMMERCE-6377
    Ben Crouse

*   Upgrade sidekiq-unique-jobs

    v5 had some significant problems, and v6 is much improved. The owner
    posting this message made me want to do this: https://github.com/mhenrixon/sidekiq-unique-jobs/issues/234#issuecomment-400452075

    ECOMMERCE-6377
    Ben Crouse

*   Add MailInterceptor to limit outgoing emails

    The MailInterceptor utilizes the "send_email" config, which now
    defaults to a lambda which limits outgoing email to admin users
    in the qa and staging environments. The config still also
    supports a boolean value.

    ECOMMERCE-6359
    gharnly

*   Vendor mongoid-simple-tags

    This gem is no longer maintained, so we're vendoring it in the same
    freedom patches file as the `.all_tags` monkey-patch that was made a
    few years prior to now. As a result, Workarea applications can use v2.0
    of the `json` gem, which implements the newer [RFC 7159](https://tools.ietf.org/html/rfc7159.html)
    specification of the JSON standard. Using this newer specification
    allows other top-level objects like `nil` instead of throwing an error
    when an Array or Hash is not passed into `JSON.generate`.

    ECOMMERCE-6308
    Tom Scott

*   Update app_template.rb to provide common configuration for projects

    ECOMMERCE-6317
    Matt Duffy

*   Improve markup and styles for recommended products

    * Added a new Sass component for recommendations
    * Updated markup accross all instances of recommendations in the storefront touse new component
    * Added a styleguide component for recommendations

    ECOMMERCE-6324
    Jake Beresford

*   Clean aXe in-browser plugin logs

    * Inject role='presentation' into iframe embed codes
    * Add aria labels to Social Networks content blocks
    * Clean up misc offenses in home page sample data
    * Fix issues with jQuery Dialog
    * Fix empty H1 on User's Order summary
    * Fix issues with Back To Top button
    * Add Aria labelledby attributes to option thumbnail inputs
    * Add Aria labelledby attribute to cart item quantity
    * Add a visually hidden label to phone extension field
    * Add proper aria landmarks to UIs appended to body
    * Make aria roles on option thumbnails template unique

    ECOMMERCE-6272
    Curt Howard

*   Update login test to click actual logout link

    ECOMMERCE-6288
    Curt Howard

*   Sort SVG Icons By Filename in Style Guide

    The order that SVG icons appeared in the storefront and admin style
    guides was dependent on which order the plugin gems loaded, because
    there was no alphanumeric sort being applied after all icon path names
    were consolidated together. Workarea now sorts the `#style_guide_icons`
    helper method by each icon's filename, ensuring that the icons are no
    longer re-sorted based on whether a plugin or app overrode any.

    ECOMMERCE-6307
    Tom Scott

*   Add trending/top icons for categories and discounts, refactor helpers

    ECOMMERCE-6273
    Matt Duffy

*   Add top and trending icons to select2 results for products

    ECOMMERCE-6273
    Matt Duffy

*   Patch ActionView::PathResolver to improve view path resolution performance

    ECOMMERCE-6298
    Matt Duffy

*   Add production exclusion product rules, add product rules to search customizations

    ECOMMERCE-6248
    Matt Duffy

*   Update code list views to align with other show pages

    ECOMMERCE-6283
    Matt Duffy

*   Include the entire aside within the Mobile Filters UI

    ECOMMERCE-6255
    Curt Howard

*   Allow admins to edit code list name and expiration date

    ECOMMERCE-6251
    Matt Duffy

*   Improve Release Select UI

    - Fix width of Release Select UI without truncation
    - Dynamically add full release name to Release Select UI title attr

    ECOMMERCE-6244
    Curt Howard

*   Mark Individual Prices Within a SKU As On-Sale

    Pricing SKUs have an `#on_sale` flag that determines whether to use the
    `Pricing::Price#sale` field or the `Pricing::Price#regular` field when
    pricing a given item. However, this determination can only be made on a
    SKU level, and not within individual price tiers. To do that, Workarea
    3.4 introduces the `Pricing::Price#on_sale` field, which takes on the
    value of the parent `Pricing::Sku#on_sale` if it's not set explicitly on
    the price.

    ECOMMERCE-6118
    Tom Scott

*   Search By Variant Name in "Jump-To" Autocomplete

    Allow admins to search for a variant's display name in order to retrieve
    product results. This works similarly to searching for a product by name
    in the Jump-To.

    ECOMMERCE-6234
    Tom Scott

*   Add icons for top and trending products

    * Show icons on product index next to matching products
    * Show icon on insight card on product show page

    ECOMMERCE-6237
    Matt Duffy

*   Update plugin_template

    Added require 'workarea/plugin_name' to the engine file for new plugins,
    this allows generators to be executed from the context of a plugin.
    Also removed the temporary stash paths for workarea and workarea-ci as the
    CI gem is now released.

    ECOMMERCE-6194
    Jake Beresford

*   Add the ability to exclude categories and/or products from discounts

    ECOMMERCE-6214
    Matt Duffy

*   Fix reference to secret key base that might not be there anymore

    Rails 5.2 switches to config/credentials.yml.enc

    ECOMMERCE-5574
    Ben Crouse

*   Clean up discount rules UI

    ECOMMERCE-6214
    Matt Duffy

*   Remove now-uneeded hacks for routes in integration tests

    These hacks can be safely removed.

    ECOMMERCE-5574
    Ben Crouse

*   Upgrade to Rails 5.2

    This commit also introduces vendoring the active_shipping gem, because
    it has been abandoned and the current work in that repo to support Rails
    5.2 has not been released as a gem. In addition, the latest in the
    active_shipping repo removes the UPS gateway due to a request from UPS.
    I have re-added that here, so as to continuing to support UPS out of the
    box.

    ECOMMERCE-5574
    Ben Crouse

*   Bump workarea version

    Curt Howard

*   Add view status of comments per user

    * Track which users have viewed comment
    * Change icon on index pages depending on whether user has viewed all comments

    ECOMMERCE-6155
    Matt Duffy

*   * Use ID to select primary navigation

    ECOMMERCE-6186
    Jake Beresford

*   Update implementation to remove hover state when another nav item is touched, or the user touches outside of the primary nav

    ECOMMERCE-6186
    Jake Beresford

*   Add support for touch events in the primary nav

    Allows large touchscreen devices like MS Surface or iPad Pro to access primary navigation dropdowns.

    * Touch events have the same functionality as hover
    * User is able to follow primary navigation link by touching a primary nav item twice

    ECOMMERCE-6186
    Jake Beresford

*   Add alert next to admin link to model when model is inactive

    ECOMMERCE-6156
    Matt Duffy

*   Implement conditional link to block helpers

    * Adds 2 new view helper methods to conditionally wrap a haml block in a link if a condition is met

    ECOMMERCE-6159
    Jake Beresford



Workarea 3.3.11 (2018-10-16)
--------------------------------------------------------------------------------

*   Prefer Most Specific Tax Rate When All Parameters Are Given

    Providing a country and region to `Tax::Category.find_rate` when there
    are rates that exist on the postal code level would previously return
    those more specific postal code rates instead of the "general"
    `Tax::Rate` for the state. Workarea now ensures that the `:postal_code`
    on the rate is blank when a postal code is not given to the `.find_rate`
    method.

    ECOMMERCE-6361

    Discovered by **Devan Hurst**.
    Tom Scott

*   Add the content area ID to the draft block when editing content.

    ECOMMERCE-6383
    Jake Beresford

*   Ensure Redirect Path is Encoded Before Persisting

    The `Navigation::Redirect#sanitize_path` callback could potentially
    throw a `URI::InvalidURIError` if the given path is not valid. Workarea
    now checks if the argument passed in is URI-encoded, according to the
    specifications of [RFC 2396](https://www.ietf.org/rfc/rfc2396.txt). If it
    has not already been encoded, `Navigation::Redirect.sanitize_path` will
    call `URI.encode` to make sure that an error won't be thrown when
    parsing as a URI.

    ECOMMERCE-6329
    Tom Scott

*   Improve `#wait_for_xhr` error in system tests

    Check for the presence of JavaScript errors after the timeout
    in `#wait_for_xhr` and output a more helpful error message
    incase an xhr callback is raising an error

    ECOMMERCE-6368
    Eric Pigeon



Workarea 3.3.10 (2018-10-08)
--------------------------------------------------------------------------------

*   Fix Dragonfly config forced to file system after bad merge

    Discovered by Matt Martyn, we believe this is from a bad merge related
    to the scheduled jobs cleaning patch.

    ECOMMERCE-6370
    Ben Crouse

*   Update test to pass under mongo 3.6, 4.0

    Under mongo 3.6 and 4.0 the default order of the related documents
    changed so the test needs to grab specific records rather than rely
    on array indexing

    ECOMMERCE-6358
    gharnly

*   Add Change the Storefront Search Filters UI guide

    ECOMMERCE-6293
    Curt Howard



Workarea 3.3.9 (2018-10-03)
--------------------------------------------------------------------------------

*   Fix unstable cart items system test

    This was failing intermittently, more reliably for some people than
    others. The failure was related to waiting for XHR, but the
    functionality in question had nothing to do with that, so go for the
    full page load.
    Ben Crouse

*   Fix search suggestions with same query ID

    ECOMMERCE-6362
    Ben Crouse

*   Fix docker initializer to get tests passing

    The WebConsole gem is only loaded in the development environment. As such
    modifying its configuration should also only happen in dev.

    ECOMMERCE-6360
    gharnly

*   Add `workarea new` to CLI documentation

    This describes the `workarea new {app|plugin|theme}` command which
    allows users of the CLI to generate applications, plugins, or themes
    for any combination of Ruby version and Workarea version.
    Tom Scott

*   Fix admin taxonomy system test

    This wasn't reliable, make sure XHR is complete before checking in a
    Capybara scope.

    ECOMMERCE-6301
    Ben Crouse

*   Sort Product Images In Option Set Templates

    The `option_selects` and `option_thumbnails` product templates will now
    respect the `:position` field, and sort by that value before filtering
    out images based on the selected SKU or primary image.

    ECOMMERCE-6326
    Tom Scott

*   Import & format Hosting Documentation to docs

    ECOMMERCE-6319
    Curt Howard



Workarea 3.3.8 (2018-09-19)
--------------------------------------------------------------------------------

*   Disable Request Throttling When Logged In As Admin

    Logged-in admin users are no longer bound by the `Rack::Attack` rules
    for abusive clients. Add a safelist rule that checks whether the `:admin`
    cookie is present and `true`. If so, the request is "safelisted",
    meaning any other rule (like `blocklist` or `fail2ban`) is ignored.

    ECOMMERCE-6318
    Tom Scott

*   Selectively replace 'WebLinc' with 'Workarea' in old docs

    Replace references to 'WebLinc' the software with 'Workarea'. Retain
    references to 'WebLinc' the company.

    ECOMMERCE-6331
    Chris Cressman

*   Update admin navigation to correctly style additional navigation sections

    * Prevents blog navigation section being 100% width when installed

    ECOMMERCE-6330
    Jake Beresford

*   Add a custom 404 page to docs

    ECOMMERCE-6313
    Curt Howard

*   Add Article Navigation UI to Documentation Articles

    ECOMMERCE-6323
    Curt Howard

*   Add Quick Link UI to Documentation Headings

    ECOMMERCE-6327
    Curt Howard

*   Improve readability of Developer doc articles

    * Stop the madness with fancy-box text overflow
    * Improve article positioning & gutters
    * Improve styling of tables
    * Setup and configure highlight.js
    * Visually distinguish images and code blocks

    ECOMMERCE-3620
    Curt Howard

*   Remove Reverted Commits From Changelog

    Manually removes reverted commits that exist in the `CHANGELOG`, and fix
    the `workarea:changelog` Rake task to match on the subject rather than
    the body of the commit so that reverts don't appear in the changelog in
    the future.

    ECOMMERCE-6121
    Tom Scott

*   Fix issues with Order::Item#current_unit_price with some discounts

    The BuySomeGetSome discount type can cause issues with calculating unit
    price at the price adjustment level. To alleviate these issues, unit
    price for an item is calculated as the sum of all price adjustments
    divided by the item's quantity, instead of each price adjustment
    calculating its own unit price and adding them up. This allows the
    calculation of other discount values to be accurate if the
    BuySomeGetSome discount discounts the amount of an entire unit.

    ECOMMERCE-6242
    Matt Duffy

*   Update gems

    Curt Howard

*   Internationalize Price Range Facets Text

    Add translations for the "Over" and "Under" text in price range facets,
    named `workarea.facets.price_range.over` and
    `workarea.facets.price_range.under`, respectively. This is the text that
    appears in price range filters on the storefront.

    ECOMMERCE-6292
    Tom Scott

*   Add StringId to allow collections with a mix of string and bson object ids

    ECOMMERCE-6241
    Matt Duffy

*   Allow Spaces in Product Filter Pattern Validation

    Filters cannot have the "Type" property associated with them, so
    Workarea has a browser-based pattern validation ensuring the filter name
    is never "Type" or "type". This regular expression had the unintentional
    effect of blocking spaces in new filter names through the admin, resulting
    in some confusion. Add to the regex in order to allow it to support
    spaces before or after the word "Type" is detected (or at all).

    ECOMMERCE-6163
    Tom Scott

*   Allow Changing Taxonomy Slugs in Workflow

    Workarea now ensures that taxonomy changes occur outside the context of
    a release, in order to address a validation error that occurs when an
    admin attempts to add a new taxon in the middle of the taxonomy tree.

    ECOMMERCE-6184
    Tom Scott

*   Add "Sort and Exclude Product Options" Guide

    This guide details how an implementer might manipulate the sorting and
    exclusion of product options.

    ECOMMERCE-6284
    Tom Scott



Workarea 3.3.7 (2018-09-05)
--------------------------------------------------------------------------------

*   Add CLI link to docs

    Also use flexbox to better control main fancyboxes

    ECOMMERCE-6279
    Curt Howard

*   Iterate Over Missing Dead Jobs and Remove Them

    Prevent sidekiq-cron jobs which no longer exist from being enqueued by
    removing them out of Redis on the app's `after_initialize` callback.

    ECOMMERCE-2367
    Tom Scott

*   Ensure order locking happens before inventory check

    This should prevent concurrency issues where inventory causes items to
    be removed from the order while it's being placed.

    ECOMMERCE-6300
    Ben Crouse

*   Allow mailer previews from plugins and applications to be loaded

    Load all mailer previews at the same time to fix issues with loading
    previews from a host application while still allowing plugin previes
    to be decorated.

    ECOMMERCE-6299
    Matt Duffy

*   Add Guide for Custom Product Templates

    Add the "Add, Remove, or Change a Custom Product Template" guide which
    replaces the "Create a Custom Product Template" guide. This expands the
    documentation around custom product templates, including more
    information about each step to do it manually, as well as documentation
    around changing and removing existing templates.

    ECOMMERCE-6267
    Tom Scott

*   Specify Format in Remote Select URL for Product List Content Block

    ECOMMERCE-6271
    Tom Scott

*   Fix Overriding SVG Icons in Style Guide

    SVG icons could not be overridden in the style guides, instead, the icon
    would just be appended to the end of the list. Update the
    `#style_guide_icons` helper to ensure only 1 of each filename exists, so
    icons will appear to override each other in the style guide.
    Additionally, instead of filtering icon paths by their "engine slug"
    (e.g. "storefront", "admin"), just use the '*' wildcard, because it made
    the whole thing impossible to test.

    ECOMMERCE-6183
    Tom Scott

*   Fix option selects when there isn't a matching variant

    ECOMMERCE-6297
    Ben Crouse

*   Collect All Payment Methods into ARIA Radiogroup

    The ARIA `role="radiogroup"` is meant to encapsulate all radio buttons
    on a page, and we were separating these radio buttons by saved cards and
    new cards. Set the `role` of the
    `.checkout-payment__primary-method-group` element and remove the extra
    `div` elements added to the page during the WCAG audit.

    ECOMMERCE-6144
    Tom Scott

*   Fix creating invalid search customizations

    Somehow this happened in URBN, it's an easy fix.

    ECOMMERCE-6289
    Ben Crouse

*   Add proper link class to Result Filters UI

    ECOMMERCE-6249
    Curt Howard

*   Fix arrows

    Curt Howard

*   Fix Payment Method Selection in Checkout

    When switching between a New Credit Card and Saved Credit Card in the
    payment step of checkout, the fields for the New Credit Card were still
    being validated (and displayed) even though they were no longer selected.
    The JS code that is supposed to select all the other payment methods on
    the page and visually un-select them was only targeting siblings of the
    current payment method, which as of v3.3.1, v3.0.35, v3.1.21, and v3.2.10,
    are now wrapped in a `<div aria-role="radiogroup">`, and therefore are
    no longer siblings of the selected item. Change the way we're targeting
    the elements for selection/un-selection on the page from sibling-based
    to top-down, using the top-level `<form>` element as a "root" to find
    all other payment methods, and the `event.currentTarget` to find the
    "current" element that is being selected.

    ECOMMERCE-6224
    Tom Scott

*   Fix Redirection When Editing Content

    When editing content for a given `Contentable` model, like navigation,
    the `return_to` param was not being passed between the content block
    type chooser form and the actual content block editor form.
    Additionally, this param was not being passed on the delete action,
    causing post-action redirects from these locations to result in the
    default, which goes to the content model itself and loses track of the
    object that content is being edited for. Ensure that the `return_to`
    param is being passed to these locations so that all actions redirect
    back to the content editor form from which one came.

    ECOMMERCE-5826
    Tom Scott

*   Tighten up search result items

    Curt Howard

*   Link to v2 docs properly

    Curt Howard

*   Extend link to text next to logo

    Curt Howard

*   Update external facing links

    Curt Howard

*   Fix weird blue bar at bottom of search

    Curt Howard

*   Add releases layout

    Curt Howard

*   Fix up box layout on landing page

    Curt Howard

*   Switch Fancy Box UI to contain links instead of being one

    Curt Howard

*   Constrain images to the maximum width of their container

    Curt Howard

*   Make the left nav arrows work like MacOS Finder

    Curt Howard

*   Reduce h2-h6 sizes within articles

    Curt Howard



Workarea 3.3.6 (2018-08-21)
--------------------------------------------------------------------------------

*   Handle missing Geocoder data when bogus IP is given

    In certain environments (like Docker), IP addresses are not guaranteed to
    be valid, thus a `Geocoder` response has the potential of returning
    invalid data for the `Geolocation#coordinates` method. Update this
    method to call `#compact` on the Array it returns, causing it to be
    empty in the case that an invalid IP address is geocoded.

    ECOMMERCE-6233
    Tom Scott

*   Add "Change Product Placeholder Image" Guide

    This guide instructs implementers of the Workarea platform on how to
    change the product placeholder image from the default provided by the
    platform, or even a theme. It also mentions how to configure the product
    placeholder filename, which by default is `product_placeholder.jpg`,
    that is used to look up a placeholder from the asset pipeline.

    ECOMMERCE-6225
    Tom Scott

*   Fix product_image_url not being absolute when asset host is a proc

    Discovered on URBN, this is a bug when asset host is a proc. This
    is a situation we must handle after using one in multi site to
    provide automatic asset host management.

    ECOMMERCE-6239
    Ben Crouse

*   Preview Future Navigation Menu Changes

    Changes to the navigation menu order (and activity) are now visible when
    previewing a future release. To achieve this, the `#navigation_menus`
    helper sorts the collection returned from the database by its
    `#position`, which (unlike a bare DB query) is affected by the release
    changes.

    ECOMMERCE-6219
    Tom Scott

*   Clean up a few minor issues in the "Testing" document

    Chris Cressman

*   Update Testing Guide for v3.3

    - Document changing configuration for the duration of a test
    - Document setting a locale for the duration of a test
    - Document time manipulation within a test using ActiveSupport's `travel_to` (thanks @fbongiovanni)
    - Note that a decorator path cannot be passed as an argument to a test runner, and provide an example for how to run tests in isolation that are located within `.decorator` files. (thanks @khenson)
    - Explain quote usage throughout the document (thanks @khenson)

    ECOMMERCE-6130
    Tom Scott

*   Add documentation for running sidekiq locally

    ECOMMERCE-6201
    Matt Duffy

*   Add unique indexes for uniqueness-validated fields

    There are a number of places, namely `Catalog::Category`,
    `Content::Email`, and `Navigation::Taxon`, that were missing unique
    indexes and thus resulted in a full table scan upon validation. In most
    cases this is inconsequential to page load times, but in larger
    deployments this scan can pose a problem when attempting to save these
    items from the admin. Therefore, we've added unique indexes to all
    fields that are validated for uniqueness out of the box, in order to
    mitigate this problem on future deployments. We still stress that fields
    that you have decorated to validate uniqueness should also have unique
    indexes associated with them in the database.

    ECOMMERCE-6119
    Tom Scott



Workarea 3.3.5 (2018-08-07)
--------------------------------------------------------------------------------

*   Fix ImageCollection when product image option is nil

    ECOMMERCE-6231
    Ben Crouse

*   Fix sending admin status emails to non-admins

    This can happen is admin permissions are only partially removed. Reported by hosting team.

    ECOMMERCE-6230
    Ben Crouse

*   Fix issues with rack attack throttles

    ECOMMERCE-6229
    Matt Duffy

*   Update documentation tree and home page links

    Chris Cressman

*   Remove docs that found their way back to life

    Chris Cressman

*   Prevent event propagation on optional field reveal

    Event propagation was causing unexpected behaviour with optional fields within drawers, causing the drawer to close when the prompt is removed. Preventing propagation allows this module to work in the context of a drawer.

    ECOMMERCE-6228
    Jake Beresford

*   Style Workarea Documentation

    WHB-92
    Curt Howard

*   Autocomplete product by ID and SKUs

    This regression was introduced in v3.2.0 when we removed the product's
    ID from the `#search_text` to improve matching. That field is
    full-text analyzed, and was causing incorrect matches to occur when
    performing an admin search, but as a result of its removal, the "jump
    to" autocomplete would no longer match on product ID or SKUs. We've
    added these data points into the `#jump_to_search_text` field, which is
    *not* analyzed as fulltext, so that products can be matched by ID or
    SKUs in the jump-to autocomplete.

    ECOMMERCE-6187
    Tom Scott

*   Adjust wysiwyg to use correct method for preserving link targets.

    {{preserve}} was added in our customization of WYSIHTML5, and when the editor was updated to WYSIHTML, we did not adjust this reference. The new method that does this same thing is named {{any}}.

    ECOMMERCE-6198
    Kristin Henson

*   Add custom renderer to add ids to all headers for linking

    ECOMMERCE-6200
    Matt Duffy

*   Only send refund emails for non-zero amounts

    When an order for $0.00 is refunded, we were sending a transactional
    email indicatin that the order had been refunded. The core system no
    longer does this, instead refraining to deliver the email if the refund
    amount is $0.00.

    ECOMMERCE-6196
    Tom Scott

*   Fix error on display of email content updates

    When email content updates were displayed in the activity feed, a syntax
    error was thrown due to a lack of parenthesis at the `else` end of a ternary
    statement in Haml. Once this error was resolved, however, a new error
    would be thrown stating that `Content::Email#name` was not a method.
    Define this method as the titleized version of `Content::Email#type` in
    order to view the activity feed for email content properly in admin.

    ECOMMERCE-6190
    Tom Scott

*   Update workers documentation

    ECOMMERCE-6173
    Matt Duffy

*   Move storefront.cart_show append point above recommendations/recently viewed

    Matt Duffy

*   Fix CSV Dragonfly importing for embedded documents

    The original commit did not fix the reported issues, this completes the
    job.

    ECOMMERCE-6164
    Ben Crouse

*   Set asset host from an ENV variable

    Requested by the hosting team, this will make project configuration easier.

    ECOMMERCE-6188
    Ben Crouse



Workarea 3.3.4 (2018-07-24)
--------------------------------------------------------------------------------

*   Fix payment profiles created before they are needed in checkout

    This was reported as a bug of profiles with wrong email
    addresses in Lonely Planet. This fix isn't ideal, but I was
    seeking minimal impact to builds and payment gateway plugins.

    ECOMMERCE-6167
    Ben Crouse

*   Fix Dev server

    Curt Howard

*   Update resetSelectUI to find regionField regardless of DOM structure

    * Fixes a bug where region select was not being properly reset if the DOM is changed, for example a styled select is used.

    ECOMMERCE-6189
    Jake Beresford

*   Fix session access in Cache::Varies

    This will only work with the cookie session store. Also fixes a prob
    with the HTTP cache varying in general. This is why you always write a
    test.

    ECOMMERCE-6181
    Ben Crouse

*   Fix intermittant template errors

    This helper will occasionally randomly start raising errors. Specifying
    parameters explicitly as opposed to allowing Rails to infer them, fixes
    the issue.

    ECOMMERCE-6143
    Ben Crouse

*   Fix Spelling Error in Config.JS This should fix issues with the scroll to button module in v3.3

    ECOMMERCE-6185
    Lucas Boyd

*   Do not nest content block within HTML tags

    Lets the content block dictate it's own markup

    ECOMMERCE-6122
    Curt Howard

*   Include selected taxon in left nav cache key

    For categories and pages, the selected child taxon for a given top-level
    node in the taxonomy was not being included in the fragment cache key
    for the left navigation, resulting in the incorrect link being bolded
    when changing subcategories from this nav. If a child taxon is selected
    in the breadcrumbs, we'll put its ID in the cache key to differentiate
    that cache from others, otherwise the key will stay the same.

    ECOMMERCE-6141
    Tom Scott

*   Add rack attack throttles for contact/, email_signup/, and forgot_password/

    ECOMMERCE-6180
    Matt Duffy

*   Prepare for CI gem release

    This will be released inline with the next patch so version numbers are
    in sync.

    ECOMMERCE-6178
    Ben Crouse

*   Use a volume for gem cache if docker-sync is not used

    ECOMMERCE-6177
    Matt Duffy

*   Assign Dragonfly attributes explicitly in data file imports

    When importing catalog products with embedded image URLs, e.g. with the
    header `images_image_url`, the image could not be added because the
    attribute was not being sensed as a field on the model. We're now taking
    attributes that start with any `dragonfly_accessor` field names, e.g.
    "image", and assigning them to the model via its `#update` method.

    ECOMMERCE-6164
    Tom Scott

*   Remove mongo dependency, allow Mongoid to specify that

    We originally did this to fix this issue, which is now fixed in the
    driver: https://jira.mongodb.org/browse/RUBY-1285

    ECOMMERCE-6168
    Ben Crouse

*   Bump puma to latest minor

    This helps fix issues with Docker setups.

    ECOMMERCE-6169
    Ben Crouse

*   Remove mongo dependency, allow Mongoid to specify that

    We originally did this to fix this issue, which is now fixed in the
    driver: https://jira.mongodb.org/browse/RUBY-1285

    ECOMMERCE-6168
    Ben Crouse

*   Ensure we require Dragonfly S3 storage if we're going to use it

    ECOMMERCE-6166
    Ben Crouse

*   Fix product filters regex

    Product filters could not be edited in the workflow because the regex we
    added in was not working properly. This fixes the regex by removing the
    modifier and slashes for the "type" field.

    ECOMMERCE-6161
    Tom Scott

*   Allow decimal values for Range Content::Field by adding step attribute

    * Add validation attributes to range field number input to prevent invalid user input

    ECOMMERCE-6158
    Jake Beresford



Workarea 3.3.3 (2018-07-10)
--------------------------------------------------------------------------------

*   Allow Products content field to be configured for single products

    * Allow developer to configure single: true for products content field
    * Removed duplicate required attribute from products content field

    ECOMMERCE-6149
    Jake Beresford

*   fix workarea:test:plugins when no plugins are installed

    Matt Duffy

*   Allow Products content field to be configured for single products

    * Allow developer to configure single: true for products content field
    * Removed duplicate required attribute from products content field

    ECOMMERCE-6149
    Jake Beresford

*   Remove "Configure Basic Site Information" guide

    The contents of this guide were previously moved into the "Configs"
    guide with the intention of removing this guide, but it was not removed.

    * Remove guide
    * Adjust metadata in surrounding guides
    Chris Cressman

*   Port wait_for_xhr stability improvements from headless Chrome

    This improves reliability of tests on PhantomJS as well. And it seems
    necessary to get consistent build results.

    ECOMMERCE-6081
    Ben Crouse

*   Correct value for aria label for address region select

    ECOMMERCE-6148
    Jake Beresford

*   Fix SKU selection and inclusion in cache key

    We don't always need a current SKU, everything seems to be fine without
    it, and it's a more correct representation when no selection has been
    made.

    This commit also fixes problems with the new templates where
    option-derived current SKU isn't being included in the cache key.

    ECOMMERCE-6145
    ECOMMERCE-4886
    Ben Crouse

*   Add "Showing Products" section to "Products" guide

    ECOMMERCE-6129
    Chris Cressman

*   Fix Dragonfly S3 autoconfig depending on region presence

    Specifying a region of `us-east-1` is not allowed.

    ECOMMERCE-6146
    Ben Crouse

*   Add Dragonfly S3 datastore as dependency

    We have default configuration that relies on this, at this point makes sense to add a dependency.

    ECOMMERCE-6142
    Ben Crouse

*   Fix duplicate selectors

    ECOMMERCE-6081
    Ben Crouse

*   Fix dupliacte selectors

    ECOMMERCE-6081
    Ben Crouse

*   Bump puma to match generated Rails apps

    ECOMMERCE-6081
    Ben Crouse

*   Fix duplicate selectors for linting

    ECOMMERCE-6081
    Ben Crouse

*   Add workarea-ci gem

    This gem will provide shared CI scripts for all projects on the workarea
    platform. It includes:
    * Standardized linting configs for Ruby, JavaScript, and CSS
    * Scripts for running linting and gem auditing
    * Reporting linting in JUnit formatting

    This commit also makes some changes to base to conform to the linting.

    ECOMMERCE-6081
    Ben Crouse

*   Do not show unpurchasable products in recommendations

    Don't recommend something someone can't buy, duh.

    ECOMMERCE-6135
    Ben Crouse

*   Add workarea-ci gem

    This gem will provide shared CI scripts for all projects on the workarea
    platform. It includes:
    * Standardized linting configs for Ruby, JavaScript, and CSS
    * Scripts for running linting and gem auditing
    * Reporting linting in JUnit formatting

    This commit also makes some changes to base to conform to the linting.

    ECOMMERCE-6081
    Ben Crouse

*   Do not show unpurchasable products in recommendations

    Don't recommend something someone can't buy, duh.

    ECOMMERCE-6135
    Ben Crouse

*   Load and show mailer previews in all environments except production

    ECOMMERCE-6128
    Matt Duffy

*   Add scoped selectors to .taxonomy-content-block for different navigation locations

    ECOMMERCE-5835
    Jake Beresford

*   Do not memoize User.console

    ECOMMERCE-6140
    Matt Duffy

*   Only use sellable during inventory capture if theres a positive value

    Applications being upgraded to v3.3.0 might not have sellable set on
    inventory skus, which will cause the capture to fail if looking for
    a document with sellable 0 that does not have the field set.

    ECOMMERCE-6127
    Matt Duffy

*   Use elasticsearch client to determine health

    ECOMMERCE-6124
    Matt Duffy



Workarea 3.3.2 (2018-06-21)
--------------------------------------------------------------------------------

*   Fix locale related tests, and add helper for management in tests

    Since different dependencies look at different things, lots of mess in
    correctly setting temporary locales. This adds a helper to make that
    easier, and fixes tests relying on a locale.

    ECOMMERCE-6136
    Ben Crouse

*   Fix option set templates which display too many images

    Use only images matching the primary image when no options are selected. This
    is more natural logic and fixes products with lots of images.

    ECOMMERCE-6139
    Ben Crouse

*   Fix wrong action in option template links

    Use details to 1) fix XHR requests being incorrectly cached, 2) prevent
    duplicate content on search engines crawling detail pages.

    ECOMMERCE-6138
    Ben Crouse

*   Add product browsing section to products guide

    ECOMMERCE-6089
    Chris Cressman

*   Add separate container for webpack-dev-server process, remove foreman.

    ECOMMERCE-6100
    Matt Duffy

*   Add docker generator

    ECOMMERCE-6100
    Matt Duffy

*   Release verison 3.0.35

    Curt Howard

*   Fix build

    Curt Howard

*   Fix build

    Curt Howard

*   Fix build

    Curt Howard

*   Address region text box is not required

    * Hide field required indicator if region field text-box is displayed, this field does not have the required attribute.

    ECOMMERCE-6108
    Jake Beresford



Workarea 3.3.1 (2018-06-12)
--------------------------------------------------------------------------------

*   Fix build

    Curt Howard

*   Delay initialization of Pagination session until Waypoint is triggered

    This fixes an issue reported where, if a user with a clean session
    refreshes a category or search page before scrolling down, the
    pagination UI just hangs.

    ECOMMERCE-6054
    Curt Howard

*   Revert "Fix finite scroll when refreshing the page"

    This reverts commit 4ce94dd140f643364accaca14d3b3c230d4468bd.
    Curt Howard

*   Don't try to bulk index if there aren't any documents to index

    Elasticsearch will raise an error in this case.
    Ben Crouse

*   Fix OptionSetViewModel for images with nil option

    This caused demo data indexing to fail.
    Ben Crouse

*   Update "Documentation Style Guide"

    Add sections covering proper nouns and voice

    ECOMMERCE-6092
    Chris Cressman

*   Document INLINE option for search index tasks

    The option is added in Workarea 3.3

    ECOMMERCE-6093
    Chris Cressman

*   Update "Configs" guide with descriptions of PO box configs

    * Remove old guide that is obsoleted by this change
    * Update guide metadata to support removal of guide

    ECOMMERCE-6094
    Chris Cressman

*   Fix finite scroll when refreshing the page

    With our "finite scroll" pagination, refreshing the page caused the
    `unload` event to get fired and the current height of the window saved
    into the local state. This prevents a waypoint from being set so that
    pagination fires when you scroll past the bottom of the page. To fix
    this, we're checking whether the viewport height of the current browser
    is greater than the height of the current scroll position. If it is,
    we're setting `height: 'auto'` in order to make sure the waypoint still
    gets fired as it would if you never refresh the page.

    ECOMMERCE-6054
    Tom Scott

*   Include CHANGELOG.md in Workarea gem

    ECOMMERCE-6110
    Eric Pigeon

*   Prevent order locking when changing shipping

    When the type of shipping service is changed and the form is submitted
    too quickly, an error can occur related to order locking, since the
    requests are coming in simultaneously. Implement a request queue using
    `_.debounce()` similarly to how we prevent this issue in
    **workarea-split_shipping**, and disable the form for submission until
    all requests finish.

    ECOMMERCE-6086
    Tom Scott

*   Revert "Create pre release for 3.3.1"

    This reverts commit dc4efb1f4d9c280588426f8778b537126ab5e148.
    Curt Howard

*   Create pre release for 3.3.1

    Curt Howard

*   Fix WCAG issues after aXe accessibility audit

    ECOMMERCE-6035
    Curt Howard

*   Fix WCAG issues after aXe accessibility audit

    ECOMMERCE-6035
    Curt Howard

*   Fix WCAG issues after aXe accessibility audit

    ECOMMERCE-6035
    Curt Howard

*   Add "Products" guide

    ECOMMERCE-6029
    Chris Cressman

*   Fix swatch product display when packaged

    When a 'swatches' product is packaged within a package product, it was
    previously rendering the PDP for the package product rather than the PDP
    for the underlying swatch product, because we weren't explicitly passing
    the slug of the swatch product when generating the URL to request upon
    changes to the swatches. Ensure we're always passing the `:id` as
    the `product.slug` when building hashes to pass into `url_for` for
    generating URLs.

    ECOMMERCE-6107
    Tom Scott

*   Fix WCAG issues after aXe accessibility audit

    ECOMMERCE-6035
    Curt Howard

*   Use fully-qualified URLs in page og:image tags

    Content pages were still using the `image_path` syntax to render URLs to
    the logo image. This wasn't working on social media networks, wherein
    the URL lookup would result in an error. Changing this to `image_url`,
    which incorporates the host, allows pages to be shared on social media.

    ECOMMERCE-6106
    Tom Scott

*   Fix ActiveMerchant refinement for Net::HTTP

    ActiveMerchant recently made an update to enable more detailed logging
    of HTTP requests for PCI compliance purposes (which apparently take
    effect June 30th). They did this by applying a
    [refinement](https://ruby-doc.org/core-2.1.1/doc/syntax/refinements_rdoc.html)
    to `Net::HTTP` which adds a new method, `#ssl_connection`. This was throwing a
    `NoMethodError` in the Baudville build when used with our Payflow Pro integration,
    because WebMock monkey-patches `Net::HTTP#start` and doesn't ever set
    the `@socket` variable. This causes mass havoc, but can be resolved by
    checking whether `@socket` is present before trying to call methods on
    it.

    This has been [resolved
    upstream](https://github.com/activemerchant/active_merchant/pull/2874),
    so the changes as part of this ticket are only going to be active for
    the next release, after which (as long as ActiveMerchant doesn't drag
    their feet) we will just update ActiveMerchant since it should include
    the merged changes.

    ECOMMERCE-6099
    Tom Scott

*   Update "Configs" guide for Workarea 3.3

    Add/remove configs to reflect changes in Workarea 3.3

    ECOMMERCE-6066
    Chris Cressman

*   Update "Content" guide for Workarea 3.3

    Add the "range" field type

    ECOMMERCE-6068
    Chris Cressman

*   Update "Error Pages" guide for Workarea 3.3

    Workarea 3.3 renders Workarea error pages by default.

    ECOMMERCE-6067
    Chris Cressman

*   Update documentation of required Ruby version

    Workarea's Ruby dependency changed in Workarea 3.2.9.

    ECOMMERCE-6065
    Chris Cressman

*   Fix pattern validation for new filter/detail names

    We don't allow the usage of the word "type" in a filter/detail name, and
    validate this on both the client-side and the server-side. When we
    removed the `jQuery.validate` plugin in order to fully rely on browser
    native input validation, we noticed that some of the regular expressions
    used for validation were not giving us the expected result. These
    regexes have been fixed and you can now get past adding details in the
    product edit, "create product" workflow, and bulk action sequential product editor.

    ECOMMERCE-6087
    Tom Scott

*   Revert "Don’t use relative paths for email settings"

    This reverts commit f8cb96a1b749abf1378d5dfb71619eece5a427be.
    Curt Howard

*   Fix releases integration tests when time zone is set

    With the new release calendar export option added in v3.3, the
    `Admin::ReleasesIntegrationTest` will fail when `config.time_zone` is
    configured, resulting in the calendar no longer generating for UTC. To
    remedy this, we're forcing UTC time zone on all these tests and
    resetting back to the original time zone after each test runs, ensuring
    that we are always testing against the same time zone, except in the one
    unit test that we assert the calendar can operate in multiple time
    zones.

    ECOMMERCE-6085
    Tom Scott

*   Expand variations shown in Workflow Bar style guide component.

    ECOMMERCE-5811
    Kristin Henson

*   Remove currency from structured pricing data

    In the `workarea/storefront/products/_price` partial, we were previously
    returning the full currency with the price in the `price` data point.
    We're now returning the numerical value of the price without its
    currency, as the currency is denoted above in `priceCurrency`.

    ECOMMERCE-6064
    Tom Scott

*   Adjust the amount of default filter values returned to be configurable.

    ECOMMERCE-6083
    Kristin Henson

*   Close tooltip when choice is made in release reminder form

    When one of the choices within the release reminder tooltip is selected,
    close the entire tooltip. This is a regression due to a change in
    behavior in Tooltipster, which we've addressed in a different place
    prior to this patch.

    ECOMMERCE-6058
    Tom Scott

*   Make OrderDataIntegrationTest Less Great Again

    This test was originally named `Storefront::OrderDataIntegreationTest`,
    and thus caused issues when it was decorated due to the file name and
    class name not matching up. Rename the class to
    `Storefront::OrderDataIntegrationTest`. While the test is ostensibly
    much less great due to this change, it does allow implementors to
    decorate its methods, thus improving its usefulness in our platform.

    ECOMMERCE-5551
    Tom Scott

*   Prevent throwing an error when SVG file can't be found in Sprockets

    In the base implementation of `InlineSvg`, it would seem that locally,
    we assume that an SVG file is present in Sprockets, and if it isn't an
    error is thrown. This `NoMethodError` is very difficult to reason about
    as a developer, so we're rescuing and treating the response as if we're
    missing the SVG, leveraging the existing system in place for handling
    that error.

    ECOMMERCE-6046
    Tom Scott

*   Fix workarea:changelog task to work when no tags exist

    When there are no tags on the current repo, the workarea:changelog task
    now looks back to the initial commit of the project, assuming all of the
    commits pertain to the current (as-yet-unreleased) version.

    ECOMMERCE-6079
    Eric Pigeon



Workarea 3.3.0 (2018-05-24)
--------------------------------------------------------------------------------

*   Ensure cloneable rows duplicate unique IDs

    Curt Howard

*   Add "Workarea 3.3.0" minor release notes guide

    ECOMMERCE-6030
    Chris Cressman

*   Fix duplicate ID errors in ContentSystemTest

    Tom Scott

*   Remove deprecated feature_spec_helpers

    Since v3.2.0 our feature_spec_helpers have been deprecated in favor of
    feature_test_helpers. Now they are finally removed.

    ECOMMERCE-6075
    Curt Howard

*   Handle all-day events better in Calendar Feed

    The previously written controller action has been decomposed into a
    couple of View Models as well.

    ECOMMERCE-6040
    Curt Howard

*   Update gitignore

    Curt Howard

*   Add "Drive System Tests with PhantomJS/Poltergeist" guide

    ECOMMERCE-6061
    Chris Cressman

*   Employ custom JS Error Catcher for Headless Chrome

    Like `js_error: true` but for Chrome!

    Via https://medium.com/@coorasse/catch-javascript-errors-in-your-system-tests-89c2fe6773b1

    ECOMMERCE-6053
    Curt Howard

*   Remove jQuery Validation from the admin

    Since we live in 2018, aka The Future, the last two versions of all
    "modern browsers" support native HTML-5 form validation, and since the
    Admin only supports the last two version of all "modern browsers," we
    stand in defiant protest against the tyranny that was, is, and forever
    shall be jQuery Validation by removing it as a dependency from the Admin.

    ECOMMERCE-6056
    Curt Howard

*   Improve look of Variant cards

    ECOMMERCE-6036
    Curt Howard

*   Use prepend_before_action for impersonation status check

    Move status check to top of before actions to ensure it updates
    the session if an impersionation has expired before other before_actions
    attempt to use session.

    ECOMMERCE-6078
    Matt Duffy

*   Add system test for client side validation of add to cart on option_thumbnails product template

    Product option inputs are visually hidden but must be validated. Using display: none; or changing the class to .hidden will prevent the sku options from being validated and cause an error if the user attempts to add to cart without selecting a sku.

    ECOMMERCE-6077
    Jake Beresford

*   Fix geolocation when IP address cannot be geocoded

    When IP address cannot be geocoded, _almost_ every method in
    `Workarea::Geolocation` falls back to `nil`, except for
    `Geolocation#region`. We now test for its presence and fall back to a
    `nil` value if the geocoder query turns up with zero results.

    ECOMMERCE-6076
    Tom Scott

*   Fix geolocation when IP address cannot be geocoded

    When IP address cannot be geocoded, _almost_ every method in
    `Workarea::Geolocation` falls back to `nil`, except for
    `Geolocation#region`. We now test for its presence and fall back to a
    `nil` value if the geocoder query turns up with zero results.

    ECOMMERCE-6076
    Tom Scott

*   Add index page for imports and exports

    ECOMMERCE-6057
    Matt Duffy

*   Add warning when dragonfly is set to use filesystem

    On load of the application, output a warning that dragonfly is using the
    filesystem when in a non-test, non-development environment.

    ECOMMERCE-6072
    Matt Duffy

*   Lock version of rufus-scheduler to prevent breaking changes to sidekiq-cron

    ECOMMERCE-6060
    Matt Duffy

*   Don't allow Ruby 2.5

    Several deep issues with 2.5 compatibility right now:
    * seeding fails due to an unkown bug with SwappableList
    * bizarre delegation failures in checkout step classes
    * segfaults when running tests

    For now, disallow Ruby 2.5. We will revisit this in the not-so-distant
    future.

    ECOMMERCE-5887
    Ben Crouse

*   Prevent duplicate IDs when editing content blocks

    By default, the Rails form helper tags will generate an ID based on the
    `name` attribute of the element and the name of the `<form>` tag it's
    surrounded by. Because fieldsets within the same form sometimes share
    names, we used the `dom_id()` helper method to generate mostly-unique
    DOM IDs for each element. As we gradually shifted to a more asynchronous
    and feature-rich content editor, it was observed that duplicate IDs were
    appearing on the page for different fieldsets, or sometimes the same
    fieldset rendered multiple times in a content block. To prevent this,
    we're now setting `id: nil` on all tags that previously had a `dom_id`
    associated with it. This will ensure that Rails won't generate an ID on
    the DOM element, which is not necessary given the way we handle styling
    and behavior for elements on the page.

    ECOMMERCE-5873
    Tom Scott

*   Ensure releases in primary nav are unique

    When rendering release options in the primary nav, it was possible for
    the same release to make it in there twice, because the release is both
    "current" and "upcoming" as it is being edited. Ensure that the list of
    releases is unique by the BSON ID from Mongo.

    ECOMMERCE-5883
    Tom Scott

*   Remove IDs from fields on product/variant forms

    Duplicate ID warnings were being thrown in certain cases on the featured
    products forms, catalog product workflow, and variant forms. Since Rails
    will (by default) set IDs on each DOM element we are creating with its
    tag helpers, we're now passing `id: nil` so IDs are not generated at
    all.

    ECOMMERCE-5864
    Tom Scott

*   Block flash messages from being able to be rendered twice

    ECOMMERCE-5725
    Tom Scott



Workarea 3.3.0.beta.1 (2018-05-21)
--------------------------------------------------------------------------------

*   Check for publish date when user schedules an undo

    Since we don't validate the `publish_at` date on releases when they're
    saved, it's possible for releases that have a scheduled undo date, but
    no scheduled publish date. This results in the unpublished release
    erroneously appearing on the release calendar. We're no longer allowing
    releases like this to be saved, instead, it's only valid to save a
    release with an undo date when the release has a publish date.

    ECOMMERCE-5796
    Tom Scott

*   Add sidekiq-throttled; throttle import/export

    Prevent import or export from running more than one job at a time.

    ECOMMERCE-6038
    Matt Duffy

*   Allow export to send to multiple email addresses

    ECOMMERCE-6034
    Matt Duffy

*   Add shipping instructions field to shipping step of checkout

    ECOMMERCE-6047
    Matt Duffy

*   Disable emails during seeding

    Matt Duffy

*   Improve display of data file samples

    ECOMMERCE-6048
    Matt Duffy

*   Use tags on assets to mark as favicons over boolean field

    ECOMMERCE-6049
    Matt Duffy

*   Add range Content::Field for use in content blocks

    ECOMMERCE-6027
    Jake Beresford

*   Install Spectrum Colorpicker as a polyfill

    Now, browsers that don't support a native colorpicker UI will fallback
    to using Spectrum.

    ECOMMERCE-6043
    Curt Howard

*   Add configuration for scroll_to_buttons.js top offest

    ECOMMERCE-6045
    Jake Beresford

*   Add append point for adding sections to admin fulfillments#show

    Matt Duffy

*   Rename BulkAction::Delete to BulkAction::Deletion to avoid name collisions

    ECOMMERCE-6041
    Matt Duffy

*   Omit release commits from changelog

    We were still getting some "Release version x.x.x" commits in the
    changelog task when it was auto-generated. Make the regex for skipping
    release version commits a bit more loose so we don't get extra noise in
    the changelog.

    ECOMMERCE-6011
    Tom Scott

*   Replace guard clause with unless statement

    Ruby 2.3.x doesn't accept a guard clause in the main context like this,
    and thus a `SyntaxError` is thrown if `WORKAREA_SKIP_SERVICES=true'. In
    the next minor release, we will bump the required Ruby version for all
    gemspecs.

    ECOMMERCE-6017
    Tom Scott

*   Update order mailer confirmation and checkout confirmation views

    * Don't render shipping sections on email confirmation for orders that
    do not require shipping
    * Don't render fulfillment sections on order summary for checkout
    confirmations

    ECOMMERCE-5994
    Matt Duffy

*   Add running_from_source? and running_in_dummy_app?

    depecrate running_from_gem? in favor of running_in_dummy_app? to see if
    the test suite is running from a plugin and running_from_source? to see
    if the test is defined from rails root.

    ECOMMERCE-6007
    Eric Pigeon

*   Document System Emails

    ECOMMERCE-5997
    Curt Howard

*   Remove irrelevant Mongoid configuration

    This removes primary_preferred since we've later learned of MongoDB's
    recommendation against secondary reads altogether.

    Also set a max_pool_size since this ends up being done in practice.
    Ben Crouse

*   Remove control cells from tables with no bulk selection

    ECOMMERCE-6024
    Matt Duffy

*   Remove bulk selection controls from admin system content#index

    ECOMMERCE-6024
    Matt Duffy

*   Add bulk action delete, clean up bulk actions across admin

    * Adds bulk delete functionality
    * Adds bulk selection to email signups and navigation redirects
    * Modifies bulk_action partial to allow use in non-es-based views
    * Fix errors being thrown from bulk_action_items when nothing is selected

    ECOMMERCE-5993
    Matt Duffy

*   Update admin users#index xhr request to return any matching admin

    Allow an exclude_current_user param to be passed to exclude the
    current user.
    Matt Duffy

*   Add credit card integration style tests

    Adds new integration tests that test the credit operations instead of
    unit testing the classes.  Adds a new method to Tender::CreditCard for
    dealing with tokens.  Activemercant gateways expect tokens to be passed
    as strings instead of being wrapped in instance of
    ActiveMerchant::Billing::CreditCard.  Updates calls to #authorize
    and #purchase to pass an options hash as implementations will want to
    pass the order id and billing address to the gateway

    ECOMMERCE-6000
    Eric Pigeon

*   Allow setting a country on an Address by its name

    This adds flexibility and better serialization symmetry (like in CSV
    formatting for example)
    Ben Crouse

*   Define configuration to allow ordering of facet values

    ECOMMERCE-5996
    Matt Duffy

*   Submit content preset form asynchronously

    The "add content preset" form shows up in a tooltip, and when creating a
    new content preset within a workflow, it refreshes the page and knocks
    you out of the workflow. Remedy this by making the form submission
    asynchronous, so the page won't refresh. Results of the operation are
    shown in a flash message.

    ECOMMERCE-5820
    Tom Scott

*   Add text explaining the globe icon

    This adds a little tooltip explaining what the globe icon means in the
    context of our admin. It also places the icon in the locale switcher to
    give a visual connection to the symbol in all localized admin fields.

    ECOMMERCE-5753
    Tom Scott

*   Improve Add to Calendar UI

    ECOMMERCE-5798
    Curt Howard

*   Fix missing translation in recommendations show view

    ECOMMERCE-6004
    Jake Beresford

*   Clean up & classes to result filters

    ECOMMERCE-5830
    Curt Howard

*   Add arrows to jQuery UI Accordion styling

    ECOMMERCE-5930
    Curt Howard

*   Add jQuery UI Accordion style guide

    Curt Howard

*   De-translate & cleanup Product Rules UI

    ECOMMERCE-5930
    Curt Howard

*   Update "Order Life Cycle" guide for Workarea 3.3

    Update explanation of expired orders to reflect changes in Workarea 3.3.

    ECOMMERCE-5989
    Chris Cressman

*   Update mailer previews for import/export

    Matt Duffy

*   Fix issues with AdminQueryOperation

    * Pass options into #query the same as when executing for results.
    * Use GlobalID::Locator.locate_many to minimize db queries
    Matt Duffy

*   Remove references to unneeded PricingDiscountCodeLists query

    Matt Duffy

*   Add append point for data file bulk actions

    Matt Duffy

*   Update "Orders & Items" guide for Workarea 3.3

    Incorporate the concept of Admin guest browsing

    ECOMMERCE-5988
    Chris Cressman

*   Update "Configure Sidekiq" guide for Workarea 3.3

    ECOMMERCE-5987
    Chris Cressman

*   Improve AdminQueryOperation#count logic

    Matt Duffy

*   Overhaul Bulk Actions UI

    ECOMMERCE-5956
    Curt Howard

*   Translate product rules category field

    There were some missing translations in the admin for category product rules.
    This hard-coded text was moved to the locale file for admin so it can be
    changed easily.

    ECOMMERCE-5870
    Tom Scott

*   Update #images_matching_options to account for multiple values in option

    Matt Duffy

*   Allow admin to remove user from email signups

    ECOMMERCE-5900
    Matt Duffy

*   Allow admin to delete email signups

    ECOMMERCE-5901
    Matt Duffy

*   Search through plugin paths with FindPipelineAsset

    Add the ability to find assets within plugins using the
    `Workarea::FindPipelineAsset` class. This searches through plugin asset
    directories as well as core components, but prefers the path in the host
    application in order to retain previous functionality.

    ECOMMERCE-5981
    Tom Scott

*   Make DataFile::Json#serialize_models public

    Matt Duffy

*   Make Order place callbacks model callbacks to include before/after hooks

    Matt Duffy

*   Make asset manifest paths configurable

    Matt Duffy

*   When generating an app, set action_mailer asset_host equal to asset_controller asset_host

    ECOMMERCE-5973
    Dave Barnow

*   Add help tooltip to explain different inventory policies

    ECOMMERCE-5941
    Dave Barnow

*   Use .test TLD instead of .dev for app generation

    ECOMMERCE-5976
    Dave Barnow

*   Add unit tests for Pricing::CacheKey

    Contributes positively to our test coverage and allows us to decorate
    the tests when functionality is added to `Pricing::CacheKey`, like in
    the case of segmentation.

    ECOMMERCE-5975
    Tom Scott

*   Move categorized-autocomplete and its templates to each engine

    You better believe this is breaking. Errors containing helpful
    instructions will be thrown so that the necessary changes are made to
    each overridden manifest during the upgrade process.

    ECOMMERCE-5950
    Curt Howard

*   Add generalized importing/exporting across the admin

    ECOMMERCE-5946
    Ben Crouse

*   If defined, use a Google Maps Geocoding API key for doing geocoder lookups

    https://github.com/alexreisner/geocoder#google-google

    ECOMMERCE-5953
    Dave Barnow

*   Add link to release page to event description in calendar feed

    ECOMMERCE-5799
    Kristin Henson

*   Always use Workarea Error pages

    Content is not required to render Workarea Error pages any longer, as it
    will now be created on-demand and customized as necessary.

    ECOMMERCE-5914
    Curt Howard

*   Increase the visibility of invalid properties

    ECOMMERCE-5877
    Curt Howard

*   Revert "Improve invalid field state during checkout"

    This reverts commit 34be324afe656439bd0f07fbfa4e41c46d8a4196.
    Curt Howard

*   Improve Insight Card UI

    ECOMMERCE-5903
    Curt Howard

*   Persist flash messages if they are errors

    ECOMMERCE-5876
    Curt Howard

*   Support exclusions for Category rules

    ECOMMERCE-5915
    Curt Howard

*   Add generic importing framework for the admin

    Switching away from CSV makes offering importing much more easily - we
    can offer multiple formats that support rich data structures.

    This implements a framework for importing most anything in the admin.

    ECOMMERCE-5946
    Ben Crouse

*   Add an easy way to vary Rack::Cache and fragment caches

    This is very dangerous, and should be used with great care. See the
    documentation on Workarea::Cache::Varies.on for more details.

    ECOMMERCE-5780
    Ben Crouse

*   Include inventory when considering product purchasable

    This allows more sensible detail page displays, especially with the
    displayable when out of stock inventory policy.

    ECOMMERCE-5938
    Ben Crouse

*   Remove the requiring of workarea from bin/rails

    While this enabled use of workarea generators from within a plugin,
    this was causing test runs to not use the `test` environment.
    Matt Duffy

*   Allow an asset to be set as favicon, automate favicon madness

    ECOMMERCE-5769
    Matt Duffy

*   Fix error on Teaspoon tests

    This wasn't causing a failure, just throwing a JS error that we needed
    to resolve. Move tests requiring a different fixture to a different
    suite.

    ECOMMERCE-5934
    Tom Scott

*   Require file input fields when doing CSV imports

    ECOMMERCE-5897
    Dave Barnow

*   Ditch .item-table in favor of .product-grid

    ECOMMERCE-5776
    Curt Howard

*   Remove forceful focus-ring globally

    inputs, textareas, and selects shouldn't naturally use the focus ring,
    as its purpose is to assist implementers when creating non-standard,
    custom, focasable UIs.

    ECOMMERCE-5888
    Curt Howard

*   Partialize recommendations

    ECOMMERCE-5827
    Curt Howard

*   Rename Order.abandoned to .expired_in_checkout

    This scope was named confusingly, changed to `.expired_in_checkout` so
    it's more explicit about what it's actually querying for. Requested by
    @ccressman.

    ECOMMERCE-5884
    Tom Scott

*   Use i18n fallbacks when determining whether prices are active

    When locale fallbacks are configured, the now-localized `:active` flag
    on prices doesn't take into account the fallbacks, and always represents
    the current locale configured. We're now using the first found fallback
    value for the price.

    ECOMMERCE-5752
    Tom Scott

*   Add inventory policy for displayable when out of stock

    Products with this inventory policy will show at the end of the results
    for the category or search.

    ECOMMERCE-5626
    Ben Crouse

*   Clean up help, add community forum links to admin

    ECOMMERCE-5866
    Ben Crouse

*   Add classes to breadcrumbs

    * adds breadcrumb__link and breadcrumb__text selectors to all breadcrumb nodes

    ECOMMERCE-5882
    Jake Beresford

*   Lock down promo code lists while generating

    Removing or exporting a code list while generating can cause errors.

    ECOMMERCE-5848
    Ben Crouse

*   Add shipping service importing

    ECOMMERCE-5855
    Matt Duffy

*   Move cache expiration times into config

    ECOMMERCE-5780
    Ben Crouse

*   Scroll test browser to bottom of the page in pagination tests

    The pagination system tests have the ability to fail due to the
    configuration of the grid on either categories#show or searches#show.
    Scrolling the browser to the bottom of the test should ensure that, no
    matter the configuration, the waypoints controlling the pagination
    functionality will still operate as expected.

    ECOMMERCE-5880
    Curt Howard

*   Refactor imports

    Simplifies import behavior and convert catalog import
    to bring into alignment with all other import behaviors.

    ECOMMERCE-5849
    Matt Duffy

*   Add missing append point to new product templates

    ECOMMERCE-5881
    Jake Beresford

*   Add gems.weblinc.com to Gemfile source of apps generated with WORKAREA_EDGE

    Matt Duffy

*   Implement Premailer gem & simplify email templates

    NOTE: Before an integration team upgrades _a live site_ to v3.3.0 all
    email templates should be overridden. Keep in mind there are both
    designed and plain-text emails to consider.

    Overridding will ensure the email design does not change unexpectedly
    during the upgrade.

    ECOMMERCE-5827
    Curt Howard

*   Convert tax import to simplified import style

    ECOMMERCE-5863
    Matt Duffy

*   Adds required indicator to field label names throughout checkout

    ECOMMERCE-5765
    Mansi Pathak

*   Fix on-page value__error styling

    ECOMMERCE-5764
    Curt Howard

*   Fix incomplete test setup for view tests

    Depending on the order in which tests run, this can cause errors by not properly resetting the test environment.

    ECOMMERCE-5867
    Ben Crouse

*   Add poltergeist driver setup automatically if gem is installed

    In case builds don't want to go through the pain of headless Chrome
    upgrade.

    ECOMMERCE-5759
    Ben Crouse

*   Enhance TestCase#running_in_gem? to not return true from other gems

    Problems could arise when the test from one gem was run within another
    gem. #running_in_gem? would return `true` unexpectedly. We can verify
    from within the method that both the root of the test and the root of
    rails is the same to ensure this does not happen.

    ECOMMERCE-5718
    Matt Duffy

*   Set format for json xhr requests that share an action with html templates

    ECOMMERCE-5841
    Matt Duffy

*   Only set sort to relevance if relevance is a sort option

    Matt Duffy

*   Fix issues around navigation redirect importing / management

    ECOMMERCE-3360
    Matt Duffy

*   Ensure Dragonfly URLs always use the CDN

    Automatically set the `url_host` config in Dragonfly so it always uses the CDN when rendering images.

    ECOMMERCE-5842
    Ben Crouse

*   Improving the stylings of our shortcuts menu in the admin

    ECOMMERCE-5622
    Ben Crouse

*   Modify Fulfillment::Status to be canceled even if items have shipped

    It is possible to cancel shipped items, and therefore its possible
    for an entire order to be canceled even if items have been shipped.
    Matt Duffy

*   Use #find_by_path for detecting existing redirects during import

    Sanitizing the path to match the format we store will avoid preventable
    errors from occurring during import.
    Matt Duffy

*   Add help articles for tax and redirects importing, clean up tax import.

    Matt Duffy

*   Improve invalid field state during checkout

    https://baymard.com/pro/checkout-usability-2016/guidelines/719-how-to-style-position-and-introduce-error-messages

    ECOMMERCE-5764
    Curt Howard

*   Hide Promo Code Forms by default

    https://baymard.com/pro/checkout-usability-2016/guidelines/615-hide-coupon-promotional-fields-behind-a-link&sa=D&ust=1519661353829000&usg=AFQjCNEY6YiGPNp0zT5mfOv4njmkznkJUg

    ECOMMERCE-5768
    Curt Howard

*   Add importing for navigation redirects

    ECOMMERCE-3360
    Matt Duffy

*   Hides optional fields during checkout

    https://baymard.com/pro/checkout-usability-2016/guidelines/674-choosing-the-right-interface-type-for-optional-inputs

    ECOMMERCE-5766
    Curt Howard

*   Lay out address fields according to Baymard.com

    https://baymard.com/pro/checkout-usability-2016/guidelines/685-place-labels-above-fields-to-reduce-fixations-and-ensure-needed-label-length

    ECOMMERCE-5800
    Curt Howard

*   Add option thumbnails template

    Driven by same view model code as option selects. Tries to find images
    matching the option to render a thumbnail for each option.

    ECOMMERCE-5779
    Ben Crouse

*   Delete abandoned orders even though checkout has started

    Previously, the `Workarea::CleanOrders` job would not factor in orders
    which have already started checkout in its query for deleting old
    orders in the system. We're no longer constraining the query by a blank
    `:checkout_started_at`, thus deleting orders currently in checkout but
    not updated in the last 6 months.

    ECOMMERCE-5669
    Tom Scott

*   Unify issues messaging across indexes, views, and mailers

    ECOMMERCE-5760
    Matt Duffy

*   Add new product issues to alerts

    ECOMMERCE-5760
    Matt Duffy

*   Add option selects product template

    This template shows selects per option based on variant details
    configuration. The URL and images automatically update to match.

    ECOMMERCE-5746
    Ben Crouse

*   Automatically configure sidekiq

    ECOMMERCE-5709
    Matt Duffy

*   Make the active field localized

    This allows more flexibility when setting up sites per-locale.

    There's a feature flag to turn this off if you want to avoid a MongoDB
    migration in an upgrade scenario.

    ECOMMERCE-5670
    Ben Crouse

*   Add styles for jquery ui accordion

    Matt Duffy

*   Prevent pending quantity from being negative

    This can happen, for example, if an item has a quantity 1 then has
    it shipped then canceled. Events' quantity will total 2.
    Matt Duffy

*   Determine order shipping used on either a passed id or the first of #shippings

    Matt Duffy

*   Adding rake task to run app specific tests.

    ECOMMERCE-5762
    Komaron James

*   Provide 3rd Party Calendar integration for Site Planner

    Now, if a user is an admin and has release permissions, they can
    subscribe to the site planner with their choice of iCalendar, Microsoft
    Outlook, or Google Calendar.

    ECOMMERCE-5668
    Curt Howard

*   Revert "Make the active field localized"

    This reverts commit fd72259df854ed072bb9c9f43a3db6d6f7cc41b7.

    # Conflicts:
    #	core/lib/workarea/configuration.rb
    Dave Barnow

*   Add missing and inconsistent variant details to admin product issues

    ECOMMERCE-5710
    Matt Duffy

*   Add worker for admin bulk indexing

    ECOMMERCE-5716
    Matt Duffy

*   Strip all HTTP caching in test environment

    We'll have to be more aggressive about this. Using middleware should
    effectively strip all HTTP caching happening.

    ECOMMERCE-5459
    Ben Crouse

*   Provide an index for Email Signups in the admin

    ECOMMERCE-5711
    Curt Howard

*   Switch to headless Chrome for system tests

    This switch is certainly breaking, but many people from different
    departments expressed strong desire for it. There were several
    consequences to this change.

    This required disabling HTTP caching in the test environment. This
    should be fine, but is a potentially breaking change. Chrome didn't have
    a way to automatically clear cache that we could get to work.

    This also introduces overrides on many Capybara methods to effectively
    make XHR browser requests blocking. We experienced a lot of random
    failures related to this. We prefer stability over the slight loss of
    performance.

    To upgrade your app or plugin:
    * Change all “trigger(‘click’)” to “click”
    * Remove calls to clear_driver_cache
    * Change your tests for sorting to drag up instead of down

    ECOMMERCE-5459
    Ben Crouse

*   Allow disabling inline in search rake tasks

    This can be helpful to more quickly reindex. Example usage:
    INLINE=false bin/rails workarea:search_index:storefront

    ECOMMERCE-5742
    Ben Crouse

*   Add sample data for product, category, and discount insights analytics

    ECOMMERCE-5739
    Dave Barnow

*   Display correct image when ?sku= param is given

    We can only know which images belong to a given SKU via the `:option`
    field. When `?sku=` is the only parameter given, search through all of
    the possible detail values that match search terms facets for the given
    variant, as if they were passed in the URL. A product with the URL
    `/products/foo?sku=123&color=Red` should now show the same primary image
    as if the product was requested with `/products/foo?sku=123`.

    ECOMMERCE-5226
    Tom Scott

*   Short-circuit promo code condition when there are no promo codes on the order

    ECOMMERCE-5726
    Matt Martyn

*   Ensure sidekiq is set as the ActiveJob queue_adapter

    ActionMailer is not using sidekiq when it should. It is currently using the default ActiveJob queue adapter of async. This generally doesn't exhibit any symptoms unless you are a multi-site where it will result in no emails getting sent out as the current site doesn't get properly set. See https://github.com/rails/rails/issues/19801

    ECOMMERCE-5724
    Matt Martyn

*   Sprinkle Analytics Sparklines throughout Admin

    Using [AtF Spark](https://aftertheflood.co/projects/atf-spark) along
    with our own analytics tracking, we're now featuring inline analytics
    sparklines on:

    - Featured Product Selection UI for Categories
    - Remote Select UI (Select2) for Products
    - Category, Product, Discount, and Search Customization Index View UIs

    You're welcome.

    ECOMMERCE-5678
    Curt Howard

*   Make the active field localized

    This allows more flexibility when setting up sites per-locale.

    There's a feature flag to turn this off if you want to avoid a MongoDB
    migration in an upgrade scenario.

    ECOMMERCe-5670
    Ben Crouse

*   Add append points to search and category product grids

    * index added to category iterator to allow for inserting content at a given position within the product grid

    ECOMMERCE-5721
    Jake Beresford

*   Improve regex used for detecting PO Boxes, add negative tests

    ECOMMERCE-5703
    Dave Barnow

*   Allow admins to browse the storefront and checkout as guest

    ECOMMERCE-5666
    Matt Duffy

*   Document breakPoints.currentlyLessThan() param type

    ECOMMERCE-5708
    Tom Scott

*   Allow admin to view undisplayable products on product rules preview

    ECOMMERCE-5104
    Matt Duffy

*   Normalize product rules

    If a boolean category product rule is set to "TRUE" or "FALSE", they
    won't be considered as the true/false values and cause an error down the
    line. Look for normalized matches of the value to "true" and "false"
    rather than the raw value the user typed in.

    ECOMMERCE-4070
    Tom Scott

*   Mark version as 3.3.0.pre

    Curt Howard

*   Update Configs guide for Workarea 3.2

    Add to the Configs guide the additional configs introduced in Workarea
    3.2, and note a config that is deprecated in Workarea 3.2.

    ECOMMERCE-5660
    Chris Cressman

*   Remove documentation URLs from generator files

    The help text and boilerplate comments for the discount and pricing
    generators includes references to specific guides. The references are
    out of date. Updating them will lead to the same problem in the future.

    Remove these references altogether, or replace them with more generic
    references.

    ECOMMERCE-5651
    Chris Cressman

*   Pass product detail params when SKU option changes

    When the SKU option changes on the generic template, collect product
    details together and pass them along as query parameters to simulate
    hitting that product's direct URL. This allows images to change based on
    the current SKU selection.

    ECOMMERCE-5226
    Tom Scott

*   Make PO Box acceptence configurable for Addresses

    ECOMMERCE-5664
    Matt Duffy

*   Add sellable field to inventory skus, use for new low inventory report

    ECOMMERCE-5665
    Matt Duffy

*   Rewrite the "Release a Plugin" guide

    * Clarify the need for the credentials file
    * Provide commands to create the credentials file
    * Provide an example of specifying credentials on the command line
    * Simplify the whole guide
    * Update to current whitespace/style conventions

    ECOMMERCE-5659
    Chris Cressman

*   Fix an error running db:seed when RAILS_ENV is not development

    ECOMMERCE-5682
    Thomas Vendetta



Workarea 3.2.6 (2018-04-03)
--------------------------------------------------------------------------------

*   Convert IDs in .find_ordered to String

    If `String` IDs are passed into `Mongoid::Document.find_ordered`,
    comparisons might fail because they are not equal to the
    `BSON::ObjectId` that `Mongoid::Document#id` returns. Make sure that
    both values are converted to `String` before comparing them.

    ECOMMERCE-5011
    Tom Scott

*   Fix argument order for SETEX command

    We were previously using the wrong order here, which caused some errors
    on the Redis server. Fix the order of arguments to `Redis::Store#setex`
    (which maps to the same order of arguments as Redis' `SETEX` command).

    ECOMMERCE-5927
    Tom Scott

*   Ignore unsaved changes on initial select2 element

    A `.select2` tag will always trigger the `unsavedChanges` module on page
    load due to the way it loads data into the new element it creates.
    Prevent this from happening by adding `data-unsaved-changes-ignore` to
    the `select` tag causing the issue.

    ECOMMERCE-5219
    Tom Scott

*   Return promise with WORKAREA.currentUser.refresh

    The return values of the `gettingUserData` and `refresh` methods differ,
    causing the potential for race conditions.

    ECOMMERCE-5928
    Curt Howard

*   Add "Orders & Items" guide

    ECOMMERCE-5860
    Chris Cressman

*   Add "Error Pages" guide

    ECOMMERCE-5862
    Chris Cressman

*   Fix incorrect display of default region data to user

    When regions in an optgroup are displayed to the user in the addresses
    step of checkout, we were mistakenly visually selecting the first region
    in the `<optgroup>` for the selected country but still keeping the value
    of the field blank. This caused an somewhat confusing validation error
    as the user didn't believe they needed to manually select the first region
    in the list for their country.

    This solution was discovered by @ddavis [in her fix for LCMAINT-861](https://stash.tools.weblinc.com/projects/NS/repos/lime-crime/pull-requests/2264/overview)
    on LimeCrime. We ported over her changes to match the new names of
    modules in v3.

    ECOMMERCE-5640
    Tom Scott

*   Restore Time.now in plugin template

    When we converted remaining `Time.now` references to `Time.current`,
    this broke the plugin template because `ActiveSupport::TimeWithZone`
    isn't available quite yet. Restore this one reference back to `Time.now`
    so plugins can be generated again.

    ECOMMERCE-5907
    Tom Scott

*   Execute featured product query before looping through ids to sort

    ECOMMERCE-5905
    Matt Duffy

*   Update Workarea::Plugin to have a method for its version

    Add a method on a plugin module to get the version.

    ECOMMERCE-5522
    Eric Pigeon

*   Async all Sidekiq callbacks for featured product editing

    Changing featured products can cause lots of reindexing, which can result in requests timing out.

    ECOMMERCE-5850
    Ben Crouse

*   Use strong passwords for all tests

    Ensure tests continue to pass regardless of the configured
    application password strength.

    ECOMMERCE-5847
    Matt Duffy



Workarea 3.2.5 (2018-03-20)
--------------------------------------------------------------------------------

*   Scroll test browser to bottom of the page in pagination tests

    The pagination system tests have the ability to fail due to the
    configuration of the grid on either categories#show or searches#show.
    Scrolling the browser to the bottom of the test should ensure that, no
    matter the configuration, the waypoints controlling the pagination
    functionality will still operate as expected.

    ECOMMERCE-5880
    Curt Howard

*   Fix WORKAREA.string.dasherize to replace all spaces

    Update the regular expression to be global to replace all ocurrences of
    spaces with a dash, not just the first group.

    ECOMMERCE-5886
    Eric Pigeon

*   Document Order configs

    * Add descriptions for active order configs
    * Remove config that is unused since v3.2
    * Remove (old) order configs guide
    * Update metadata to account for removing guide

    ECOMMERCE-5859
    Chris Cressman

*   Resore browser-default focus styling

    In v2.x we applied a custom focus-ring to all focusable elements. In
    v3.x we abandoned this approach and offered a focus-ring only to custom
    UIs. Some cruft was left over, resulting in browser-default focus styling
    to be removed erroneously.

    ECOMMERCE-5872
    Curt Howard

*   Handle malformed facet param

    If a filter is specified in the URL as a String rather than an Array
    (`?color=Maroon` for example), combining more filter values for the same
    filter results in the values getting concatenated rather than specified
    as multiple elements of an Array. Ensure that we're always dealing with
    an Array before calling `<<` to shovel in new values to the param so
    that links on the filter sidebar combine more values rather than
    concatenate a single one.

    ECOMMERCE-5839
    Tom Scott

*   Update implementation to be more direct.

    ECOMMERCE-5874
    Jake Beresford

*   Update Ruby version requirement in "Development Environment" guide

    ECOMMERCE-5858
    Chris Cressman

*   Remove obsolete and worthless guides

    Remove guides that have become obsolete, either due to platform changes
    or newer guides that cover the topic better. In a few instances, remove
    guides that are correct but provide no value.

    Update all cross references and relationship metadata.

    ECOMMERCE-5775
    Chris Cressman

*   WORKAREA.image.get(undefined) updated to fire rejectPromise

    Previously the Deferred would not resolve if passed undefined as src, this
    prevented other code in the application from executing.

    * Sets default value for src to an empty string

    ECOMMERCE-5874
    Jake Beresford

*   Replace Time.now calls with Time.current

    There were a few more instances of `Time.now` being used, replaced these
    with calls to `Time.current` and added the `Rails/TimeZone` cop to our
    style guide enforcement.

    ECOMMERCE-5824
    Tom Scott

*   Add "Orders" guide

    ECOMMERCE-5771
    Chris Cressman

*   Fix on-page value__error styling

    ECOMMERCE-5764
    Curt Howard

*   Fix help articles route in the activity feed

    When help articles are edited or created, a 500 error occurred on the
    admin homepage because we were calling the non-existant route helper
    method `help_articles_path`. This has been replaced by the route
    helper's real name, `help_path`, and prevents errors on admin homepage
    after saving or updating help articles.

    ECOMMERCE-5846
    Tom Scott

*   Fix incomplete test setup for view tests

    Depending on the order in which tests run, this can cause errors by not properly resetting the test environment.

    ECOMMERCE-5867
    Ben Crouse

*   Prevent double-submits on checkout forms

    We are now preventing double form submissions during checkout by applying
    the `data-disable-with` jQuery UJS hook to each of the form submit buttons.

    This commit includes jQuery UJS in the Storefront application manifest.

    ECOMMERCE-5088
    Curt Howard

*   Add links to release notes. No changelog ECOMMERCE-5829

    Tom Scott

*   Render category name instead of ObjectID in timeline

    When creating product rules that key off of a `Catalog::Category`,
    ensure that the category name is being found and rendered rather than
    its `BSON::ObjectId`. Improves clarity of the Timeline view.

    ECOMMERCE-5688
    Tom Scott

*   Fix CSS selectors in email layout

    Now they should actually do something :|

    ECOMMERCE-5828
    Curt Howard

*   Fix dialog display on iOS Safari

    On some devices, with MobileSafari only, dialogs that take up the whole
    page (such as "Add An Address") will appear midway down in the viewport,
    not at the top where it is expected. Add some CSS to properly position
    the element.

    ECOMMERCE-5191
    Tom Scott

*   Support custom anchors in style guide links

    When we moved modifier style guides inside their parent blocks, we
    didn't update the `link_to_style_guide` helper for generating these
    links, breaking links and causing some style guides to effectively not
    be navigable.

    ECOMMERCE-5687
    Tom Scott



Workarea 3.2.4 (2018-03-06)
--------------------------------------------------------------------------------

*   Update Ruby version requirement

    Fixes problems with bugs in underlying gems on earlier versions.

    ECOMMERCE-5825
    Ben Crouse

*   Truncate :return_to cookie to prevent overflow

    We experienced an `ActionDispatch::Cookies::CookieOverflowError` when
    attempting to add a `:return_to` URL that had more than 4096 bytes in
    it. To remedy this, we're trimming query parameters off the full URL if
    `like_text` is present anywhere in the String.

    ECOMMERCE-5387
    Tom Scott

*   Fix recommendations tests related to order expiration period.

    Because of our use of `3.months` in the order expiration period instead
    of `90.days` (which is easier to add `1.day` to), a few
    recommendations-related tests failed on February 28th, 2018, and
    probably will fail in future years.

    ECOMMERCE-5810
    Tom Scott

*   Update styleguide path method to use slug rather than mount point

    ECOMMERCE-5446
    Jake Beresford

*   Update styleguide helper to include plugin files

    * Add method to Workarea::Plugins to return installed plugins excluding admin, storefront, and core
    * Render components from plugins in styleguide navigation
    * Render SVG icons from plguins in svg-icon component
    * Update style_guide_icons path to display only relevant (storefront vs. admin) icons coming from a plugin

    ECOMMERCE-5446
    Jake Beresford

*   Add extra characters to randomly generated admin passwords to pass PCI compliance

    ECOMMERECE-5758
    Dave Barnow

*   Translate address fields partial

    ECOMMERCE-5781
    Curt Howard

*   Only set default admin permissions when user becomes admin

    Previously, these permissions were defaulting to `true`, and it looked
    odd on the front-end to have users who were clearly not admins have
    "permission to publish releases". This resolves that by only setting the
    defaults for `can_publish_now` and `can_restore` when a user becomes an
    admin.

    ECOMMERCE-5591
    Tom Scott



Workarea 3.2.3 (2018-02-23)
--------------------------------------------------------------------------------

*   Release version 3.2.3

    Curt Howard



Workarea 3.2.2 (2018-02-21)
--------------------------------------------------------------------------------

*   Revert before_action refactor to restore original behavior

    This caused issues in the clothing template when tests were run against
    3.2

    ECOMMERCE-5749
    Tom Scott

*   Fix potential duplicates in recommendations view models

    ECOMMERCE-5743
    Ben Crouse

*   Fix typecasting in boolean content fields

    When a boolean content field is saved once into the database, then
    its data is re-validated, the `Content::Fields::Boolean` class would
    accidentally typecast a Boolean value that already exists. Since `false
    != 'false'`, the type is always casted to `true`, rather than `false`.
    We're now ensuring the argument passed into
    `Content::Fields::Boolean#typecast` is actually a String before
    comparing it as such.

    ECOMMERCE-5722
    Tom Scott

*   Remove test for multiple assignment of tokens. ECOMMERCE-5073

    Tom Scott

*   URL-safe reading from document.cookie

    When `document.cookie` is parsed with the `WORKAREA.cookie.read()`
    function, we are failing to account for values which may have an "=" in
    them, resulting in truncated values of the cookie when read out. After
    splitting the cookie by ";" and then by "=", we're now reconstructing
    the value of the cookie if it contains any "=" characters by hand,
    which fixes an issue when using **workarea-compare** with v3.

    ECOMMERCE-4763
    Tom Scott

*   Dasherize content block name class modifier for BEM compliant classes

    ECOMMERCE-5730
    Jake Beresford

*   Ensure sidekiq is set as the ActiveJob queue_adapter

    ActionMailer is not using sidekiq when it should. It is currently using the default ActiveJob queue adapter of async. This generally doesn't exhibit any symptoms unless you are a multi-site where it will result in no emails getting sent out as the current site doesn't get properly set. See https://github.com/rails/rails/issues/19801

    ECOMMERCE-5724
    Matt Martyn

*   Add class modifier for block type to .content-block wrapper

    * Adds a new class modifier to the content block wrapper to be used as a styling hook for the container of a given blocktype

    ECOMMERCE-5730
    Jake Beresford

*   Add append point to alt images on product template

    * Allow plugins, such as product videos, to append alt images to the PDP

    ECOMMERCE-5720
    Jake Beresford

*   Fix plugin :changelog task to work when no tags exist

    When there are no tags on the current repo, the :changelog task
    now looks back to the initial commit of the project, assuming all of the
    commits pertain to the current (as-yet-unreleased) version.

    ECOMMERCE-4853
    Tom Scott

*   Cover Rails configuration in Configuration guide

    ECOMMERCE-5607
    Chris Cressman

*   Don't check password expiry when changing password

    This prevents a possible "loop" condition where an expired admin
    password cannot be changed to a new one, resulting in the admin no
    longer being able to log in. Refrain from checking password expiry on
    actions that are used in the periodic password reset workflow.

    ECOMMERCE-5554
    Tom Scott

*   Persist and check all shippings when updating addresses step

    ECOMMERCE-5705
    Matt Duffy

*   Remove references to specs within guides

    ECOMMERCE-5609
    Chris Cressman

*   Document methods for removing appends

    ECOMMERCE-5608
    Chris Cressman

*   Add patch release notes

    * Workarea 3.2.1
    * Workarea 3.1.12
    * Workarea 3.0.26

    ECOMMERCE-5661
    Chris Cressman

*   Add new action for viewing product details

    Rather than overloading the `workarea/storefront/products#show` action
    on XHR requests, an entirely separate action that can only be accessed
    with XHR is created for viewing just the product details of a specified
    SKU. This is technically an improvement, but fixes long-standing issues
    in a few separate plugins related to overriding
    `ProductsController#show` on XHR requests.

    ECOMMERCE-5663
    Tom Scott



Workarea 3.2.1 (2018-02-06)
--------------------------------------------------------------------------------

*   Enforce one authenticity_token input per form

    It's possible that multiple `authenticity_token` inputs were being added
    to the same `<form>` by the `WORKAREA.authenticityToken` module, because
    we were never checking whether an input existed for the CSRF token.
    We're now ensuring that an input tag doesn't already exist, and if it
    does, we're updating that input tag's value with that of the user's CSRF
    token from `/current_user.json`, in case it's cached for some reason.

    ECOMMERCE-5686
    Tom Scott

*   Validate :name instead of :field on product rules

    Product rules, originally called category rules, originally called the
    name of the attribute that we're filtering on a "field", but in v3.x
    that got changed to "name". Due to validations not getting updated,
    however, we were still validating on the `#field` method, which is
    defined further down and will always be present. We're now validating
    that the product rule has a name again.

    ECOMMERCE-5220
    Tom Scott

*   Query for products with variants when seeding discounts

    Prevents a race condition whereby a product with no SKUs can be
    retrieved, causing a validation error in seeding. We're now always
    looking for products that have at least one variant, and assuming the
    variant has a SKU since it's a validated field of
    `Workarea::Catalog::Variant`.

    ECOMMERCE-5684
    Tom Scott

*   Fix error when using Redis gem v4.x

    When `Workarea::AutoexpireCacheRedis` is called and v4.0 of the Redis
    gem is installed, an error will occur because the `Redis#[]` and
    `Redis#[]=` methods are no longer available. To remedy this, we're now
    using the more canonical `Redis#get` and `Redis#setex` to get the values
    of keys from the Redis server and to set key/value pairs on Redis with
    an attached TTL value.

    ECOMMERCE-5685
    Tom Scott

*   Show product rule changes in activity feed

    Add `Mongoid::AuditLog` functionality to `Workarea::ProductRule`. Track
    changes to product rules within the admin activity log.

    ECOMMERCE-5024
    Tom Scott

*   New append point for the top of checkout payments view

    ECOMMERCE-5655
    Dave Barnow

*   Configure new apps to run on Workarea Hosting out of the box

    When generating a new application it is now configured out of the box
    with proper `qa`, `staging`, and `production` settings for
    Workarea Hosting environments.

    ECOMMERCE-5654
    Thomas Vendetta

*   Fix double Dragonfly configuration issue

    Prevents `Workarea::Configuration::Dragonfly.load` configuration
    from being clobbered.

    ECOMMERCE-5656
    Thomas Vendetta

*   Correct return value of ImageOptimProcessor

    Originally, the `ImageOptimProcessor` returned either the optimized
    image or the original image if it couldn't be optimized, but not
    actually updating the image record in place with its new attributes.
    We're now running the `#update` method on the document passed into
    `ImageOptimProcessor` so that it doesn't need to be optimized on each
    request.

    ECOMMERCE-5653
    Tom Scott

*   Use proper class name for select addresses dropdown

    ECOMMERCE-5644
    Dave Barnow

*   Ability to initialize application without external services

    When the environment variable `WORKAREA_SKIP_SERVICES` is present,
    Mongoid and Redis will not be configured on application boot.

    ECOMMERCE-5648
    Thomas Vendetta

*   Ensure form controls receive the proper classes on submit

    This fixes an issue where the `--invalid` classes weren't being
    applied properly to invalid form controls on submit.

    ECOMMERCE-5639
    Curt Howard

*   Add patch release notes

    * Workarea 3.1.11
    * Workarea 3.0.25

    ECOMMERCE-5601
    Chris Cressman

*   Remove documentation URLs from generator files

    The help text and boilerplate comments for the discount and pricing
    generators includes references to specific guides. The references are
    out of date. Updating them will lead to the same problem in the future.

    Remove these references altogether, or replace them with more generic
    references.

    ECOMMERCE-5651
    Chris Cressman

*   Update Configs guide for Workarea 3.2

    Add to the Configs guide the additional configs introduced in Workarea
    3.2, and note a config that is deprecated in Workarea 3.2.

    ECOMMERCE-5660
    Chris Cressman

*   Rewrite the "Release a Plugin" guide

    * Clarify the need for the credentials file
    * Provide commands to create the credentials file
    * Provide an example of specifying credentials on the command line
    * Simplify the whole guide
    * Update to current whitespace/style conventions

    ECOMMERCE-5659
    Chris Cressman

*   Fix an error running db:seed when RAILS_ENV is not development

    ECOMMERCE-5682
    Thomas Vendetta

*   Enforce one authenticity_token input per form

    It's possible that multiple `authenticity_token` inputs were being added
    to the same `<form>` by the `WORKAREA.authenticityToken` module, because
    we were never checking whether an input existed for the CSRF token.
    We're now ensuring that an input tag doesn't already exist, and if it
    does, we're updating that input tag's value with that of the user's CSRF
    token from `/current_user.json`, in case it's cached for some reason.

    ECOMMERCE-5686
    Tom Scott

*   Validate :name instead of :field on product rules

    Product rules, originally called category rules, originally called the
    name of the attribute that we're filtering on a "field", but in v3.x
    that got changed to "name". Due to validations not getting updated,
    however, we were still validating on the `#field` method, which is
    defined further down and will always be present. We're now validating
    that the product rule has a name again.

    ECOMMERCE-5220
    Tom Scott

*   Query for products with variants when seeding discounts

    Prevents a race condition whereby a product with no SKUs can be
    retrieved, causing a validation error in seeding. We're now always
    looking for products that have at least one variant, and assuming the
    variant has a SKU since it's a validated field of
    `Workarea::Catalog::Variant`.

    ECOMMERCE-5684
    Tom Scott

*   Fix error when using Redis gem v4.x

    When `Workarea::AutoexpireCacheRedis` is called and v4.0 of the Redis
    gem is installed, an error will occur because the `Redis#[]` and
    `Redis#[]=` methods are no longer available. To remedy this, we're now
    using the more canonical `Redis#get` and `Redis#setex` to get the values
    of keys from the Redis server and to set key/value pairs on Redis with
    an attached TTL value.

    ECOMMERCE-5685
    Tom Scott

*   Add 3.2.0 release notes

    ECOMMERCE-5657
    Chris Cressman

*   Show product rule changes in activity feed

    Add `Mongoid::AuditLog` functionality to `Workarea::ProductRule`. Track
    changes to product rules within the admin activity log.

    ECOMMERCE-5024
    Tom Scott

*   New append point for the top of checkout payments view

    ECOMMERCE-5655
    Dave Barnow

*   Configure new apps to run on Workarea Hosting out of the box

    When generating a new application it is now configured out of the box
    with proper `qa`, `staging`, and `production` settings for
    Workarea Hosting environments.

    ECOMMERCE-5654
    Thomas Vendetta

*   Fix double Dragonfly configuration issue

    Prevents `Workarea::Configuration::Dragonfly.load` configuration
    from being clobbered.

    ECOMMERCE-5656
    Thomas Vendetta

*   Correct return value of ImageOptimProcessor

    Originally, the `ImageOptimProcessor` returned either the optimized
    image or the original image if it couldn't be optimized, but not
    actually updating the image record in place with its new attributes.
    We're now running the `#update` method on the document passed into
    `ImageOptimProcessor` so that it doesn't need to be optimized on each
    request.

    ECOMMERCE-5653
    Tom Scott

*   Use proper class name for select addresses dropdown

    ECOMMERCE-5644
    Dave Barnow

*   Ability to initialize application without external services

    When the environment variable `WORKAREA_SKIP_SERVICES` is present,
    Mongoid and Redis will not be configured on application boot.

    ECOMMERCE-5648
    Thomas Vendetta

*   Ensure form controls receive the proper classes on submit

    This fixes an issue where the `--invalid` classes weren't being
    applied properly to invalid form controls on submit.

    ECOMMERCE-5639
    Curt Howard



Workarea 3.2.0 (2018-01-26)
--------------------------------------------------------------------------------

*   Release version 3.2.0

    Curt Howard

*   Add support for unsubscribing email in the account area

    ECOMMERCE-5606
    Ben Crouse

*   Revert "Fix .value__error alignment when inside grid"

    This reverts commit 2fc8d01ca4cdade79219dfff04a32b777573d98a.
    Curt Howard

*   Enforce a default window size for system tests

    Curt Howard

*   Add off-page UI for mobile filters

    ECOMMERCE-5588
    Curt Howard

*   Add yaml to editorconfig

    Curt Howard

*   Reduce chance of desceptive performance test failures

    Scenarios arise where a performance test runs faster than average,
    causing future tests to compare to the anomaly and fail incorrectly.
    To minimize the chance of this happening, performance tests will drop
    the highest and lowest measurements from previous runs before comparing
    results.
    Matt Duffy

*   Add append point on products#show between description and recommendations

    Matt Duffy

*   Update password requirements for admins

    Per the PCI audit, we need to ensure that admin users are using passwords that
    contain both alpha and numeric values and at least 7 characters long.

    ECOMMERCE-5629
    Ben Crouse



Workarea 3.2.0.beta.4 (2018-01-25)
--------------------------------------------------------------------------------

*   Release version 3.2.0.beta.4

    Curt Howard

*   Override content block type fieldset name

    The name of a fieldset is used as a unique identifier, and we always
    attempt to find an existing fieldset to append to rather than create a
    new one. In some cases, however, a fieldset name must be changed but
    most of its internals need to be preserved. For that, we have a new
    keyword argument on the fieldset method: `replaces:`, which takes a
    String equal to the ID in which its replacing.

    ECOMMERCE-5624
    Tom Scott

*   Fix admin search bar icon's disabled state

    ECOMMERCE-5636
    Curt Howard

*   Include store credit field in customer creation form in the admin

    ECOMMERCE-4843
    Matt Duffy

*   Bump per_page of recommendation index workers, make number configurable

    ECOMMERCE-5642
    Matt Duffy

*   Prepend saved addresses dropdown to address-fields and use the same classes as other checkout fields

    ECOMMERCE-5644
    Dave Barnow

*   Add rack attack throttle on signup requests by ip address

    Prevent users from abusing the signup form to determine email
    addresses that are associated to existing accounts.

    ECOMMERCE-5641
    Matt Duffy

*   Add patch release notes

    * Workarea 3.1.11
    * Workarea 3.0.25

    ECOMMERCE-5601
    Chris Cressman

*   Release version 3.1.11

    Curt Howard

*   Release version 3.0.25

    Curt Howard

*   Modify plugin template to allow generators to run within plugins

    ECOMMERCE-5343
    Matt Duffy

*   Fix admin recent searches XSS vulnerability

    In the admin recent searches dashboard widget, we were previously using
    jQuery's `.html()` method to add recent query strings to the page. This
    had the unintended consequence of evaluating each string as HTML, which
    permits cross-site scripting attacks to occur from the storefront to
    admin users of the application. We're now using jQuery's `text()`
    method, which escapes HTML by way of setting the element's `innerText`
    rather than its `innerHTML`.

    ECOMMERCE-5638
    Tom Scott

*   Add patch release notes

    * Workarea 3.1.10
    * Workarea 3.1.9
    * Workarea 3.0.24
    * Workarea 3.0.23

    ECOMMERCE-5601
    Chris Cressman

*   Release version 3.1.10

    Curt Howard

*   Release version 3.0.24

    Curt Howard

*   No need to specify fallbacks to fix I18n JS bloat

    The various ways to define fallbacks mean choosing one ahead of time can
    cause problems. Specifying fallbacks also doesn't relate to the fix of
    the original problem anyways.

    ECOMMERCE-5632
    Ben Crouse

*   No need to specify fallbacks to fix I18n JS bloat

    The various ways to define fallbacks mean choosing one ahead of time can
    cause problems. Specifying fallbacks also doesn't relate to the fix of
    the original problem anyways.

    ECOMMERCE-5632
    Ben Crouse

*   No need to specify fallbacks to fix I18n JS bloat

    The various ways to define fallbacks mean choosing one ahead of time can
    cause problems. Specifying fallbacks also doesn't relate to the fix of
    the original problem anyways.

    ECOMMERCE-5632
    Ben Crouse

*   Release version 3.1.9

    Curt Howard

*   Release version 3.0.23

    Curt Howard

*   Add messaging to admin featured product pages when in a release

    Featured product changes are not reflected in release previewing. Adding
    messaging on the admin pages ensures users are aware of this limitation.

    ECOMMERCE-5175
    Matt Duffy

*   Disable sending email in unit tests

    Because emails use Elasticsearch for recommendations, sending emails during unit
    tests causes unreliability in builds. Since we're almost never asserting against
    email in them, disable emails in unit tests by default.

    ECOMMERCE-5633
    Ben Crouse

*   Close mobile-nav when click originates from outside nav

    ECOMMERCE-5587
    Curt Howard

*   Move problematic CSS

    Curt Howard



Workarea 3.2.0.beta.3 (2018-01-22)
--------------------------------------------------------------------------------

*   Release version 3.2.0.beta.3

    Curt Howard

*   Update development environment guide

    * Note the incompatibility of MongoDB 3.6
    * Suggest Node.js as a JavaScript runtime
    * Update the minimum Ruby version for Workarea 3.2
    * Suggest keeping Bundler up to date

    ECOMMERCE-5604
    Chris Cressman

*   Fix I18n translation JS bloat

    Production JS files can be huge to due lots of unused locale translations being
    included. the fix is to specify your locales in Rails config, then only those
    will be used in rendering the JS translations.

    In base, we can fix this by specifying a default locale (en) before
    configuration, ensuring that even if an app doesn't specify a locale we'll
    always have a default.

    ECOMMERCE-5632
    Ben Crouse

*   Add missing to_json/html_safe to insights charts

    ECOMMERCE-5540
    Dave Barnow

*   Reinitialize js modules when shipping option changes

    ECOMMERCE-5616
    Dave Barnow

*   Update fixture markup to fix failing test

    ECOMMERCE-5394
    Jake Beresford

*   Update JS to allow changes in address field markup

    * Allows for address fields markup to be re-structured while maintaining functionality
    * Add common ancestor to the shared_addresses view so this functionality works easily on forms with multiple addresses

    ECOMMERCE-5394
    Jake Beresford

*   Lock down Mongo gem version to 2.4.3

    ECOMMERCE-5620
    Curt Howard

*   Fix duplicate ID errors in the Admin's dashboards

    ECOMMERCE-5618
    Curt Howard

*   Lock down Mongo gem version to 2.4.3

    ECOMMERCE-5620
    Curt Howard

*   Add CSRF param/token to current_user.json

    When user information is requested from the server, include their
    personal CSRF param and token to be used for any form submissions that
    occur on cached pages, such as the PDP with one-click checkout. Avoids
    using expired or invalid authenticity tokens due to `Rack::Cache`
    caching older tokens from past requests.

    ECOMMERCE-5583
    Tom Scott

*   Add append points for pricing skus in the admin

    ECOMMERCE-5614
    Eric Pigeon


Workarea 3.2.0.beta.2 (2018-01-19)
--------------------------------------------------------------------------------

*   Release version 3.2.0.beta.2

    Curt Howard

*   Update configs guide for Workarea 3.2

    Add and remove config keys to reflect the changes introduced in
    Workarea 3.2.

    ECOMMERCE-5605
    Chris Cressman

*   Do not use light loading indicator for disabled buttons

    ECOMMERCE-5621
    Dave Barnow

*   Validate phone extension formatting on Storefront

    ECOMMERCE-4965
    Curt Howard

*   Fix duplicate ID errors in the Admin's dashboards

    ECOMMERCE-5618
    Curt Howard

*   Lock down Mongo gem version to 2.4.3

    ECOMMERCE-5620
    Curt Howard

*   Remove v3.1 deprecations

    * Remove Search::StorefrontSearch::AutoFilter
    * Remove OrderFulfillmentStatus
    Matt Duffy

*   Add created_by_id field to user to track creation of accounts through admin

    ECOMMERCE-4844
    Matt Duffy

*   Group product's categories by featured/rules on products#show card

    ECOMMERCE-4449
    Matt Duffy

*   Give form controls a clear disabled state

    In the admin, when a form control was disabled, it didn't actually look
    disabled. In the storefront the form control was bizarrely 50% opacity.

    This commit also styles readonly elements the same as disabled elements.

    ECOMMERCE-5255
    Curt Howard

*   Add email address to Order Confirmation page

    Per Baymard.com:

    On the confirmation page, the wording of the text that alerts users to the fact that a confirmation email has been sent is especially important. This text should include the email address to which the confirmation email was sent, to provide users the opportunity to verify that it’s the correct email address. This is useful not just for those users who may have a typo in their order email, but also to prevent impatient users from worrying if they might have made a typo. Similarly, users who have completed the checkout using a previously created account, may now use a different email address than the one originally tied to the account – as it occurred during testing.

    ECOMMERCE-5042
    Curt Howard

*   Validate phone number formatting on Storefront

    Now phone numbers can only be numerals and dashes.

    ECOMMERCE-4965
    Curt Howard

*   Add a text-box--full modifier

    Curt Howard

*   Fix .value__error alignment when inside grid

    Since `.value__error` is typically injected via jQuery Validation, if
    the form field validated is within a grid, there was a good chance that
    the injected error will break layout.
    Curt Howard

*   Clean up todos

    * Remove Admin::OrderViewModel#status which would fall back to fullfillment
    status. These are now explicitly two separate statuses.
    * Move catalog product bulk action options to a helper method to clean up
    view and allow for easier addition of options
    * Update Fulfillment.find_statuses to clarify intent of logic
    * Fix grammar on todo
    Matt Duffy



Workarea 3.2.0.beta.1 (2018-01-15)
--------------------------------------------------------------------------------

*   Release version 3.2.0.beta.1

    Curt Howard

*   Revert "Add CSRF param/token to current_user.json"

    This reverts commit 86de76b4c93c0510099d97786b1d5e505ac03c3c.
    Ben Crouse

*   Prevent delay as the admin-toolbar loads

    ECOMMERCE-5593
    Curt Howard

*   Clean up release admin management

    ECOMMERCE-5498
    Matt Duffy

*   Add Visit Storefront link to user menu in admin

    ECOMMERCE-5596
    Curt Howard

*   Add CSRF param/token to current_user.json

    When user information is requested from the server, include their
    personal CSRF param and token to be used for any form submissions that
    occur on cached pages, such as the PDP with one-click checkout. Avoids
    using expired or invalid authenticity tokens due to `Rack::Cache`
    caching older tokens from past requests.

    ECOMMERCE-5583
    Tom Scott

*   Set autocomplete="off" on all storefront password fields

    By default, browsers can save the information typed into form fields
    that have `autocomplete="on"`, which is default for password fields.
    We don't ever want password data to be saved unexpectedly on users'
    machines, so in order to retain PCI compliance we're applying
    `autocomplete="off"` to each password field on the storefront. The
    Alertlogic web application firewall does this as well as a fallback,
    therefore Workarea customers on past versions will not need to manually
    make this change.

    ECOMMERCE-5590
    Tom Scott

*   Add descripitions of several configs to the "Configs" guide

    * address_attributes
    * allowed_login_attempts
    * lockout_period

    ECOMMERCE-5487
    Chris Cressman

*   Explicitly require countries mongoid extension

    The countries/global file is required, and tests whether `Mongoid` is
    defined prior to inserting its extensions allowing direct persistence
    of a `Country` object. This can cause an issue if, for some reason, the
    countries gem is required *before* Mongoid, in which case this extension
    will not be loaded, because Ruby's `require` does not attempt to load
    something a second time if it knows the filepath has already been
    required. The result of this is that the country field is not
    serialized out of a String if that was the type that it was sent in as
    (e.g., a v2.x project's data). To remedy this issue, we're now
    explicitly requiring `countries/mongoid` in core, so that the mongoid
    extension is always available if you `require 'workarea/core'` in your
    project.

    ECOMMERCE-5582
    Tom Scott

*   Further improve the order summary partial

    ECOMMERCE-5526
    Curt Howard

*   Improve Style Guide presentation

    - Use an empty layout
    - Fix sneaky placeholder issue
    - Remove cruft from .scss files

    ECOMMERCE-5474
    Curt Howard

*   Properly report success of performance test to output

    Reporting of performance tests is currently output before the failure
    of an assertion is recorded, leaving all runs reporting as passed.

    ECOMMERCE-5589
    Matt Duffy

*   Add placed_at to admin search index

    Queries run on a fresh admin index that has no orders can throw errors
    if attempting to sort by placed_at if the field is not defined in the
    mapping

    ECOMMERCE-5585
    Matt Duffy

*   Remove rspec gem and tasks

    ECOMMERCE-5292
    Matt Duffy

*   Add performance test base class, add storefront performance tests

    ECOMMERCE-5414
    Matt Duffy

*   Convert remaining model specs

    ECOMMERCE-5292
    Matt Duffy

*   Add append point for order index icons

    Ben Crouse

*   Convert core model specs

    ECOMMERCE-5292
    Matt Duffy

*   Convert remaining core services, workers, and request specs

    ECOMMERCE-5292
    Matt Duffy

*   Add 3.1.8 and 3.0.22 release notes

    Chris Cressman

*   Improve copied product ID UX in first step of flow

    The system-default copied product ID was causing strange behavior in
    the recommendations functionality, since both the product ID and copied
    ID were so similar.

    The flow has been reworked to not be assumptive. A user is prompted to
    choose a new ID. Additionally, two buttons are offered. One to copy the
    original (restoring the previous behavior) and one to totally randomize
    the product ID.

    ECOMMERCE-4855
    Curt Howard

*   Release version 3.0.22

    Curt Howard

*   Convert remaining lib specs to tests

    ECOMMERCE-5292
    Ben Crouse

*   Convert validator specs to tests

    ECOMMERCE-5292
    Ben Crouse

*   Convert lint specs to tests

    ECOMMERCE-5292
    Ben Crouse

*   Convert mongoid extension specs to tests

    ECOMMERCE-5292
    Ben Crouse

*   Adjust Order Summary partial layout

    ECOMMERCE-5526
    Dave Barnow

*   Convert remaining storefront view model specs to tests

    Also remove the spec dir now that we don't need it for anything

    ECOMMERCE-5292
    Ben Crouse

*   Changes for order fulfillment dashboard

    Matt Duffy

*   Convert content block view model specs to tests

    ECOMMERCE-5292
    Ben Crouse

*   Convert checkout view model specs to tests

    ECOMMERCE-5292
    Ben Crouse

*   Make tax price adjustments on shipping more descriptive

    ECOMMERCE-5530
    Matt Duffy

*   Add personalized recommendations to empty cart page

    ECOMMERCE-5468
    Ben Crouse

*   Add recommendations to order confirmation page

    ECOMMERCE-5467
    Ben Crouse

*   Add recommendations to the added-to-cart dialog

    ECOMMERCE-5466
    Ben Crouse

*   Correct TaxApplier item tax calculation for partial shippings

    ECOMMERCE-5534
    Matt Duffy

*   Save state of the bulk action select

    ECOMMERCE-5546
    Ben Crouse

*   Replace release calendar with regular index view

    ECOMMERCE-5498
    Curt Howard

*   Add item count to workflow bar for bulk action flows

    ECOMMERCE-5264
    Curt Howard

*   Add low inventory alert to admin toolbar, email reports

    ECOMMERCE-5536
    Dave Barnow

*   Improve checkout layout display for medium viewports

    ECOMMERCE-5535
    Dave Barnow

*   Add tracking numbers to Order search in the admin

    ECOMMERCE-5499
    Curt Howard

*   Prevent cart clearing when checkout is abandoned

    Carts were being cleared when checkout was entered, presumably because
    they get saved so we can begin saving data on the `Order`. Attempt to
    find the most recent previous order that has not been abandoned in
    `Order.find_current` to return back to the expected behavior.

    ECOMMERCE-5472
    Tom Scott

*   Add search indexing to test that depends on it

    Ben Crouse

*   Add refund email

    ECOMMERCE-5510
    Matt Duffy

*   update app template to allow pointing at latest master

    ECOMMERCE-5496
    Matt Duffy

*   Rework tests the manipulate country config to avoid issues on failure

    ECOMMERCE-5496
    Matt Duffy

*   Switch the warning color orange

    Orange has much closer associations to warning than black
    Ben Crouse

*   Add Back To Top Button to searches#show, categories#show

    ECOMMERCE-5497
    Curt Howard

*   Add system page for internal server error

    ECOMMERCE-5519
    Dave Barnow

*   Update user#orders to use index table view

    ECOMMERCE-5511
    Curt Howard

*   Add confirmation when deleting product images

    ECOMMERCE-5188
    Dave Barnow

*   Enhance extensibility of checkout summary shipping section, add shipping append points

    Matt Duffy

*   Add bogus carrer and service codes to shipping services seeds

    ECOMMERCE-5119
    Dave Barnow

*   Clean up output of payment methods on order summary views, move order totals table inside of box

    ECOMMERCE-5506
    Dave Barnow

*   Update order seeds to capture payment on seeded orders

    ECOMMERCE-5493
    Matt Duffy

*   Remove references to product sharing

    ECOMMERCE-5215
    Dave Barnow

*   Add supporting changes for OMS bulk fulfillment

    This includes:
    * Make order bulk actions decoratable
    * Add iteration over each item in a bulk action
    * Don't try to send fulfillment emails w/o transactional email
    * Add mongoizing to GlobalID
    Ben Crouse

*   Minor enchancements for better split shipping support

    Matt Duffy

*   Indicate user is being impersonated in the Admin

    ECOMMERCE-5436
    Curt Howard

*   Take partial shipping quantities into account for packaging

    Matt Duffy

*   Add searching payment transactions by order ID

    ECOMMERCE-5475
    Ben Crouse

*   Improve Content Editor new-block-button UI

    - Increase size of new-block-button UI
    - Display content block description in tooltip

    ECOMMERCE-5348
    Curt Howard

*   Improve relationship between captures and purchases

    Exposing these transactions separately allows easier determination of
    the correct amounts of current states.

    These changes discovered in OMS plugin testing, and will be made use of
    there.
    Ben Crouse

*   Restore global state after mutating it. No changelog ECOMMERCE-5094

    Tom Scott

*   Adding rake task to run all installed workare plugin tests

    ECOMMERCE-5470
    Komaron James

*   Remove paths assigned to append points

    Append points cannot currently be removed without diving into the
    appends hashes on `Workarea::Plugin`. Add methods for removing file
    paths from append points in javascripts, stylesheets, or partials.

    ECOMMERCE-5094
    Tom Scott

*   Fix graph data not displaying

    In Rails 5.1, `#to_json` was not HTML-safe by default, and so would
    escape characters like quotes, causing the graphs for products,
    categories, and search customizations insights to not display. We're now
    attaching `#html_safe` to the end of all `to_json` method calls so that
    the data contained within renders properly.

    ECOMMERCE-5437
    Tom Scott

*   Assign disabled text to create button when uploading images

    ECOMMERCE-5187
    Dave Barnow

*   Render navigation on style_guides#show pages

    - Make Style Guide navigation active state obvious

    ECOMMERCE-4603
    Curt Howard

*   Add append points for checkout and order mailer

    Matt Duffy

*   Add append points to dashboard navigations

    ECOMMERCE-5444
    Dave Barnow

*   Add low inventory issue filter for admin product index

    ECOMMERCE-5442
    Matt Duffy

*   Add personalized recommendations to user account page

    ECOMMERCE-5439
    Matt Duffy

*   Update dependency gems

    ECOMMERCE-5440
    Ben Crouse

*   Make style guide navs sticky

    ECOMMERCE-4601
    Curt Howard

*   Clean up Storefront

    The goal here is to help SEs in demoing while helping developers have a
    better starting point with styling their account views.

    - Add `$light-gray` color
    - Mute default table styles
    - Add `.box` component
    - Use `.box` component on users#account and orders#summary
    - Add `grid--large` modifier

    ECOMMERCE-5356
    Curt Howard

*   Bump image_optim versions

    Fixes Fixnum warnings, and gets us the other improvements from their
    newer versions.

    ECOMMERCE-5434
    Ben Crouse

*   Ensure default category selected is active. Fix typo

    ECOMMERCE-5360
    Matt Duffy

*   Fix use of deprecated Fixnum, require ruby >= 2.4

    ECOMMERCE-5424
    Ben Crouse

*   Bump version for sidekiq-unique-jobs

    There are several important bugs that have been fixed in newer versions of
    sidekiq-unique-jobs. Given that the bumping the gem won't break anything,
    bump the major version to ensure we don't get tripped up by them.

    ECOMMERCE-5427
    Ben Crouse

*   Add job to verify release sidekiq jobs that should exist do, add if missing

    ECOMMERCE-5419
    Matt Duffy

*   Add append point for order cards

    REVIEWS-1
    Ben Crouse

*   Fix bug in upcoming releases for search customizations

    ECOMMERCE-5400
    Curt Howard

*   Improve the Release Reminder UI

    This UI didn't fit well with the overall branding of the Admin and was
    something that was slated for a refactor during the initial v3
    development.

    The reworking of this UI now offers user a very bold and eye-catching
    interface that fits much more closely with the vision upheld throughout
    the Admin's design.

    ECOMMERCE-5423
    Curt Howard

*   Abstract Changelog task for general use

    ECOMMERCE-5354
    Curt Howard

*   Fix tests following change to card issuer icons.

    ECOMMERCE-5406
    Jake Beresford

*   Improve performance of promo code list generation

    Skip the N+1 queries to check if a code exists, rely on a unique index
    instead.

    ECOMMERCE-5390
    Ben Crouse

*   Add testing support for OMS and returns functionality

    This is fulfillment-related testing support code shared by OMS and
    returns plugins.

    ECOMMERCE-5410
    Ben Crouse

*   Add helper for standardizing text display of details in mailers

    ECOMMERCE-5409
    Ben Crouse

*   Improve order lookup to be session based

    This makes it a whole lot easier to plugins/builds to add sub-sections
    to order lookup (e.g. returns).

    Preserves backward-compatible functionality

    ECOMMERCE-5408
    Ben Crouse

*   Add amount allocation to payment processing

    This functionality gets used by both the OMS and returns plugin, and
    could be useful on builds that do capturing.

    ECOMMERCE-5407
    Ben Crouse

*   Add fallback to product inisght blocks to improve output

    If selected type does not hit configured number of products, attempt
    to meet the limit with products from the other type. If together the
    insight products do not hit the limit, look to newest products to
    fill in the remaining spots.

    ECOMMERCE-5376
    Matt Duffy

*   Adds class modifier for payment icon issuer

    * This change allows card icons to be targeted and styled for a specific issuer

    ECOMMERCE-5406
    Jake Beresford

*   Fix duplicate ID attribute values in Admin

    ECOMMERCE-5347
    Curt Howard

*   Set credit card from order to default if user has no other saved cards

    ECOMMERCE-5393
    Matt Duffy

*   Update plugin template to just use Time.now.year

    Active support time extensions aren't loaded at the time the plugin
    template is executing.  Change it to just use plain ruby methods

    ECOMMERCE-5404
    Eric Pigeon

*   Add append point for admin order attribute item details

    (minor)
    Matt Duffy

*   Update JS to allow changes in address field markup

    * Allows for address fields markup to be re-structured while maintaining functionality

    ECOMMERCE-5394

    * use event.delegateTarget for $textBox selector per PR feedback
    * Resolve a similar issue caused by the need for country and region to be direct siblings

    ECOMMERCE-5394
    Jake Beresford

*   Add stateful timeline & comment icons to Admin indexes

    ECOMMERCE-5347
    Curt Howard

*   Allow setting of default category on a product

    ECOMMERCE-5360
    Matt Duffy

*   Add Redis locking mechanism, replace order locking

    ECOMMERCE-5361
    Matt Duffy

*   Add link--no-underline modifier

    Curt Howard

*   Add svg-icon--link-color to svg-icon component

    ECOMMERCE-5375
    Curt Howard

*   Improve Index tables Admin-wide

    ECOMMERCE-5303
    Curt Howard

*   Ensure saved credit cards are stored on the gateway

    If the #store operation on the credit card gateway failed when adding a
    credit card under the users account, a Payment::SavedCreditCard was
    still persisted as if the operation was successful.  Change the store
    operation to be called before validation and validate the token is set
    on the SavedCreditCard.  Change Payment::StoreCreditCard#perform!
    to be the gatewa store response #success? and #save! to be the
    conjuction of the gatway operation and saving to the database.

    ECOMMERCE-5339
    Eric Pigeon

*   Disallow Release Select UI from refreshing Content Editor

    ECOMMERCE-5202
    Curt Howard

*   Add publish with new release functionality to new content blocks

    ECOMMERCE-5202
    Curt Howard

*   Fix publishing to new release from Content Editor

    Due to a duplicate ID in the admin's publish with menu, tooltipster was
    uninitializing itself on these fields.

    ECOMMERCE-5202
    Curt Howard

*   Add Product Insights Content Block

    Encapsulates:

    1. Top Products
    2. Trending Products

    ECOMMERCE-5203
    Curt Howard

*   Remove redundant content block teaspoon test

    Curt Howard

*   Convert payment refund spec to minitest

    ECOMMERCE-5327
    Eric Pigeon

*   Fix asserts in cancel order test

    assert_equal parameters are expected, actual.  cancel_order_test had
    them in the opposite order and will cause incorrect failure messages

    ECOMMERCE-5326
    Eric Pigeon

*   Fix save user order details test

    set the payment address before attempting to store the credit card on
    the gateway so the model is valid and is persisted.

    ECOMMERCE-5325
    Eric Pigeon

*   Port find_by_sku test from Rspec to MiniTest

    ECOMMERCE-5046
    Curt Howard

*   Update email order summary templates to display multiple shippings

    ECOMMERCE-5319
    Matt Duffy

*   Add append points for order item details

    Matt Duffy

*   Add time zone output to releases calendar

    ECOMMERCE-5237
    Ben Crouse

*   Output timezone on settings dashboard

    ECOMMERCE-5311
    Dave Barnow

*   Turn off fulfillment email to improve test reliability

    Ben Crouse

*   Rename JavaScript and SCSS feature_spec_helpers

    Includes a deprecation warning, prompting builds to immediately update
    their application manifests to use the renamed files. These old files
    are targeted for deletion in v3.3.0.

    ECOMERCE-4772
    Curt Howard

*   Rely on ajax for all release menu UI operations

    After noticing an issue in PhanomJS regarding the submission of a
    hidden form and the resulting need for an exceptional timeout in
    order to get the tests to pass, the `WORKAREA.publishWithReleaseMenus`
    module has been rewritten to _only_ use AJAX requests.

    This gives us a more predictable experience and allows us to use
    wait_for_xhr in the proper way inside the system tests.

    A number of system tests corresponding to releases needed to be
    rewritten for revalidation purposes after this change.

    ECOMMERCE-5202
    Curt Howard

*   Add rack attack protection for promo code endpoints

    We don't want to allow people to attempt to brute force promo codes.

    ECOMMERCE-5307
    Ben Crouse

*   Show refunds in order history

    Since plugins or builds can implement refunding, we should be showing
    the customer this information when they look at their orders.

    ECOMMERCE-5301
    Ben Crouse

*   Add raising an error if the create_placed_order factory fails

    ECOMMERCE-5308
    Ben Crouse

*   Add button to card for empty states of timelines, release planned changes

    - Make formatting of markup consistent with other cards
    ECOMMERCE-4972
    Dave Barnow

*   Add Order column to Payment Transactions index

    ECOMMERCE-5147
    Curt Howard

*   Allow releases to be created asynchronously

    Now, while editing a releasable object, a user can create a new
    release immediately before saving their work. This is handled
    asynchronously so that a user would not lose their progress when
    creating and switching to their new release.

    This work does not affect the release menu UI in the top-left of
    the Admin, as that UI's intended purpose is to contextually change
    the release that you are currently editing.

    ECOMMERCE-5202
    Curt Howard

*   Improve presentation of new release option UI

    - Require release name in form
    - Focus input when a user interacts with the UI

    ECOMMERCE-5271
    Curt Howard

*   Use tables on Admin indexes

    There was a lot of negative feedback around the summary-based display
    used on the index views throughout the Admin when v3.0 launched.

    This commit uses a table-based UI, instead of the summary-based UI,
    on said index views.

    For mixed results, such as search and releasable objects, the summary-
    based UI is retained.

    ECOMMERCE-5201
    Curt Howard

*   Don't show complex data types in settings dashboard

    This will prevent things like payment gateways from revealing secrets
    and clean up display.

    ECOMMERCE-5238
    Ben Crouse

*   Support pricing and display for orders with multiple shippings

    ECOMMERCE-5254
    Ben Crouse

*   Add deprecation note to WORKAREA.singleSubmitForms

    Curt Howard

*   Add append points for add to cart form and cart item details

    ECOMMERCE-5252
    ECOMMERCE-5253
    Matt Duffy

*   Use the same ordering of order items in admin as used in storefront

    ECOMMERCE-5262
    Matt Duffy

*   Standardize use of general Rails timezone config

    Establish use of standard guidelines from this post:
    https://robots.thoughtbot.com/its-about-time-zones

    We can dramatically simplify timezone code in the admin for this, but to
    prevent breaking in upgrades we'll want to wait for v4 (or meter it out
    slowly over the next few minor releases). I think this is enough
    breaking changes for one release.

    ECOMMERCE-5237
    Ben Crouse

*   Add new append point for within account grid, moves existing append point to original position in DOM

    ECOMMERCE-5208
    Jake Beresford

*   Returns dialog collection after creating it

    ECOMMERCE-5247
    Ivana Veliskova

*   Use pointer cursor for header action links

    ECOMMERCE-5257
    Dave Barnow

*   Improve keyword matching in admin searches

    Due to full text analysis, you could get missing or unexpected results.

    ECOMMERCE-5239
    Ben Crouse

*   Add input to refine terms for admin searches

    ECOMMERCE-5157
    Ben Crouse

*   Add rel=“noopener” to links that open in a new window

    This helps with performance and security. See: https://developers.google.com/web/tools/lighthouse/audits/noopener

    ECOMMERCE-5116
    Dave Barnow

*   Fix version to 3.2.0.pre

    Curt Howard

*   Add inventory restocking

    This is primarily to support OMS, specifically cancelling part of an
    order.

    ECOMMERCE-5249
    Ben Crouse

*   Add payment status for orders that do not require a tender

    ECOMMERCE-5222
    Matt Duffy

*   Add source field to Order

    ECOMMERCE-5198
    Matt Duffy

*   Fix logic that updates taxon navigable_slug when a navigable slug changes

    ECOMMERCE-5224
    Matt Duffy

*   Convert rspec tests to minitest

    Matt Duffy

*   Update slug generation behavior for navigable creation workflows

    Remove setting slug manually on setup of Page and Category workflows,
    and generate a unique slug based on position in taxonomy after selecting
    taxonomy position. Also extract unique slug logic fron Navigable for
    reuse with taxonomy slug generation.

    ECOMMERCE-5199
    Matt Duffy

*   Make use of the Elasticsearch collate functionality for suggestions

    This is a better way to acheive the same results because it will include
    all product display rules (not just active).

    ECOMMERCE-5183
    Ben Crouse

*   Ensure search customization insights test waits for xhr

    ECOMMERCE-5218
    Curt Howard

*   Improve search suggestions

    A few changes to improve the quality of search suggestions:
    * Exclude SKUs for suggestions since keywords are too fragile
    * Switch mapping to allow full word tokens for correction
    * Switch to phrase suggest for more contextual suggestions
    * Filter out suggestions from inactive products

    A reindex of storefront would be required to get the most out of these
    changes, but it should continue to function without erroring otherwise.

    ECOMMERCE-5183
    Ben Crouse

*   Improve exact matching and redirecting in search

    Redirect to a product if it's an exact match on ID, SKU, or name.
    Otherwise, render search results as normal. This should clear up some of
    the confusion around the previous product redirect functionality.

    The implementation uses a trick with scoring to avoid having to do extra
    queries (either in MongoDB or Elasticsearch).

    To get the full effect, you'll want to reindex but if you choose not to
    reindex the site will continue to function normally.

    ECOMMERCE-5184
    Ben Crouse

*   Add configuration to allow disabling of transactional emails

    ECOMMERCE-5200
    Matt Duffy

*   Automate taxonomy-based slugs when creating a new navigable resource

    ECOMMERCE-5199
    Matt Duffy

*   Restructure release notes guides by minor

    Chris Cressman

*   Add v3.0.14 release notes

    Chris Cressman

*   Update storefront user account show page for easier extension in plugins.

    * Moved append point inside of grid to make it possible to add a .grid__cell from a plugin when extending this view

    ECOMMERCE-5208
    Jake Beresford

*   Tweak search suggestion logic to improve spelling corrections

    ECOMMERCE-5182
    Matt Duffy

*   Hack to eliminate development error when app reloads

    ECOMMERCE-5115
    Matt Duffy


Workarea 3.1.8 (2018-01-09)

*   Fix credit card validation console error

    Since jQuery Validation was upgraded in v3.0.0 we've been missing true
    front-end validation on credit card fields. The
    `jquery-validation-rails` gem has compartmentalized these additional
    validations into its own file, which is now included in the Storefront
    by default.

    This commit also removes the broken and problematic `pattern` attribute in
    `postal_code` fields.

    ECOMMERCE-5533
    Curt Howard

*   Fix error messages for invalid bulk actions

    ECOMMERCE-5547
    Ben Crouse

*   Use fully-qualfied canonical URLs

    When providing URLs for `<link rel="canonical">` tags, we're not
    including the full domain and protocol, and that causes issues during
    SEO audits. Make sure that all canonical tags use the `_url` path
    helpers, and 'https' as the protocol.

    ECOMMERCE-5484
    Tom Scott

*   Fix logout problems in Safari

    Safari will pre-fetch "paused" (cached) pages and start running JS ahead
    of time as the page "unpasuses". This running JS ahead of time causes a
    request to current_user.json, which sets the auth cookie. A race
    condition then starts between the logout request and the current_user
    request which sometimes leaves the auth cookie after logging out.

    The solution is to switch this to a DELETE method which it probably
    should have been the whole time, since this request isn't idempotent.

    ECOMMERCE-5476
    Ben Crouse

*   Extend dependent selector of WORKAREA.checkoutShippingServices

    With the release of v3.2 some plugins should be making use of the base
    module `WORKAREA.checkoutShippingServices`, whose dependent CSS selector
    was too strict.

    ECOMMERCE-5525
    Curt Howard

*   Whitelist benign HTML attributes

    Tag attributes like `style`, `href`, and `alt` might actually be added by
    developers, but are currently parsed out of the final result in
    wysihtml. Add the previously mentioned attributes to the whitelist so
    that wysihtml will display content properly.

    ECOMMERCE-5445
    Tom Scott

*   Fix view template resolution problems

    Rails doesn't cache template paths in development within a request or in
    the test environment whatsoever. Fix that.

    Also increase Capybara wait time depending on number of plugins to help.

    ECOMMERCE-5532
    Ben Crouse

*   Define self-assignment methods for SwappableList

    Calling `SwappableList#+=` previously returned an `Array`, causing the
    value to possibly become mutated in place using Ruby's `+=` syntax
    sugar. SwappableList now defines the `#+` and `#-` methods so that any
    mutation in place using `+=` and `-=` will no longer change the type of
    `Workarea.config.seeds`.

    ECOMMERCE-5531
    Tom Scott

*   Change VCR Cassette Persister to handle nested cassettes

    When creating a new cassette if there's a folder in the use_cassette
    call, the Workarea cassette persister won't attempt to create it for the
    developer.  Change the Workarea cassette persister to create all
    directories for the current cassette.

    ECOMMERCE-5528
    Eric Pigeon

*   Use Workarea.config when duplicating for temporary modification in .with_config

    Plugins like multi-site can modify the value of `Workarea.config`. To ensure
    consistent behavior, that method is now used when copying the configuration
    temporarily rather than looking to the original source of
    `Workarea::Configuration.config` which may not always be the current version
    of the configuration.

    ECOMMERCE-5523
    Matt Duffy

*   Fix decoration reporter error on failing decorated tests in plugins

    ECOMMERCE-5514
    Ben Crouse

*   Fix bulk actions not being marked completed

    ECOMMERCE-5521
    Ben Crouse

*   Add 3.1.7 and 3.0.21 release notes

    ECOMMERCE-5488
    Chris Cressman

*   Rename category_seeds.rb to categories_seeds.rb

    This fixes an error when trying to decorate the CategoriesSeeds method

    ECOMMERCE-5517
    Dave Barnow

*   Fix address regions UI

    Due to "a difference of opinion" (let's say) between Safari, IE, and the
    rest of the sane web development world a significant change was required
    to the way we were conditionally displaying regions for a chosen
    country.

    Whereas before we were simply `display: none`ing the child `optgroup`s
    underneath the region select, we now must completely remove them and
    replace them with only the matching `optgroup`. This is because Safari
    and IE disallow styles being applied to form elements in this manner.

    ECOMMERCE-5516
    Curt Howard


Workarea 3.1.7 (2017-12-12)

*   Escape help page markdown HTML

    The Markdown body of help pages is marked as a safe string for Rails,
    but any raw HTML code within that Markdown is not going to be. We need
    to mark the entire result string as HTML-safe so that when it is
    rendered, we are seeing actual formatting rather than HTML tags.

    ECOMMERCE-5481
    Tom Scott

*   Update redis-rack-cache to v2.0.2

    Unlike redis-rails, redis-rack-cache had a bad dependency in its gemspec
    that forced redis-store to be locked in at 1.3.0, which at that version
    can allow for remote code execution in very specific circumstances.
    Although we're not affected due to the way we deploy our applications,
    this patch is still necessary in order to appease security audits in the
    future.

    ECOMMERCE-5513
    Tom Scott

*   Fix boosts for products with no views scores

    In the "field_value_factor" part of the "function_score" we are using the
    modifier log1p. When the views_score is 0, log(1) = 0, and the boosts
    essentially get nullified resulting in all returned documents (with views_score
    of 0) having the same score.

    Changing the modifier to "log2p" or ensures the minimum value isn't 0, so boosts
    multiplication still has an effect.

    ECOMMERCE-5508
    Ben Crouse

*   Fix element class name in .checkout-progress component

    ECOMMERCE-5490
    Curt Howard

*   Fix category product rule field duplication

    The usage of turbolinks causes unnecessary inputs to be rendered on the
    screen even though select2 has already rendered them. This is because
    our `initModules` function was typically called once, maybe twice per
    run, but is now being called indefinitely since each `turbolinks:load`
    event must reinitialize all modules (since we could be dealing with very
    different markup). We're now binding to the `turbolinks:load` event in
    the remoteSelects module, as well as initializing select2 on any
    elements that it doesn't already have binding to. This is so we don't
    accidentally re-init the same element, but we also initialize any new
    select2 elements on the page.

    ECOMMERCE-5332
    Tom Scott

*   Fix generic template first option selection

    Users were reporting that the first `<option>` in the generic template
    could not be selected in any environment which has caching enabled. This
    is because the cache key of the product without any option selected was
    incorrect, we were choosing the first variant's SKU as the "current_sku"
    in `Storefront::ProductViewModel::CacheKey`, and since option selection
    now updates the entire HTML of the generic template, it looked like the
    JS was having trouble selecting the proper `<option>` tag for the page,
    but in reality it was because the wrong SKU was set on the view model.

    ECOMMERCE-4886
    Tom Scott

*   Fix inline SVGs not appearing in production

    Configure a new asset finder for SVGs that inherits from the
    `InlineSvg::StaticAssetFinder`, but also looks up raw paths from engines
    in case the paths in the manifest cannot be found.

    ECOMMERCE-5331
    Tom Scott

*   Fix exception thrown on bulk editing with an empty selection

    Instead of a failed validation, the user would see an exception being
    thrown when a selection of 0 items was made during bulk editing. Rather
    than show this ugly error, we now have a validation condition requiring
    some IDs to be selected and are permitting explicit parameters related
    to the bulk action in the `create` action.

    ECOMMERCE-5306
    Tom Scott


Workarea 3.1.6 (2017-11-28)
--------------------------------------------------------------------------------

*   Fix graph data not displaying

    In Rails 5.1, `#to_json` was not HTML-safe by default, and so would
    escape characters like quotes, causing the graphs for products,
    categories, and search customizations insights to not display. We're now
    attaching `#html_safe` to the end of all `to_json` method calls so that
    the data contained within renders properly.

    ECOMMERCE-5437
    Tom Scott

*   Add index to support order reminder email

    ECOMMERCE-5453
    Ben Crouse

*   Update CategorySummaryViewModel to merge locals with super

    * Makes view_model available as local within the view.

    ECOMMERCE-5441
    Jake Beresford

*   Fix using canceled transactions

    In a bunch of places, we are forgetting to exclude canceled transactions
    from consideration when calculating payment amounts and operations. This
    fixes that.

    ECOMMERCE-5402
    Ben Crouse

*   Add 3.1.5 and 3.0.19 release notes

    ECOMMERCE-5417
    Chris Cressman

*   Fix checkout autocomplete

    ECOMMERCE-5438
    Ben Crouse

*   Remove outer brackets from cart inventory errors

    When inventory is checked upon adding new items to cart, we are
    returning the value of the `Workarea::InventoryAdjustment#errors` method, which
    is an Array. Convert this Array into a String by way of the immensely
    useful `#to_sentence` method, which converts it into a comma-separated
    sentence.

    ECOMMERCE-5075
    Tom Scott


Workarea 3.1.5 (2017-11-14)
--------------------------------------------------------------------------------

*   Fix mapping errors on category percolations

    Grab at least one product with every filter before indexing categories
    to ensure any category percolations don't error due to references to
    unmapped fields.

    ECOMMERCE-5435
    Ben Crouse

*   Add a warning if notablescan is enabled in non-test environments

    Includes instructions for how to resolve.

    ECOMMERCE-5389
    Ben Crouse

*   Fix loading related issues with Content Editor UI

    The MutationObserver error thrown in development will now throw a
    warning, indicating which iframe has failed and display steps to remedy

    This also fixes an issue found when navigating between two different
    pages with the Content Editor UI, where the loading indicator would fail
    to re-display on the second request.

    ECOMMERCE-5385
    Curt Howard

*   Document new config: bulk_action_per_page

    Add bulk_action_per_page to the list of Ruby configs. This config is new
    in Workarea 3.0.19.

    ECOMMERCE-5418
    Chris Cressman

*   Document default behavior of `bin/rails test`

    When run without additional arguments, `bin/rails test` excludes system
    tests, which may be surprising to developers since Workarea has had a
    concept of system tests that pre-dates Rails' own system tests.

    Document this behavior and provide an example that runs all tests.

    ECOMMERCE-5415
    Chris Cressman

*   Remove broken link and outdated references from old guide

    ECOMMERCE-5418
    Chris Cressman

*   Touch auth cookie the first time current_user is called on each request

    ECOMMERCE-5344
    Matt Duffy

*   Correct product rule preview when updating an existing rule

    ECOMMERCE-5420
    Matt Duffy

*   Use a larger page size for bulk actions

    This should increase performance by lowering the number of db queries
    for a given bulk action. If after this change you find your bulk action
    workers are using too much memory, reduce the value.

    ECOMMERCE-5390
    Ben Crouse

*   Add tests for fixed functionality in addressRegionFields module ECOMMERCE-5324
    Tom Scott

*   Use jQuery#filter() for mapping through region options to find the actual selected region option ECOMMERCE-5324
    Tom Scott

*   Select the current region scoped within the current country's optgroup

    When two countries are available that have regions using the same
    2-digit codes (such as "Pennsylvania" from USA and "Palauli" from
    American Samoa), it's possible for the browser to not be able to
    differentiate between both `<option>` tags. The JS for selecting the
    proper region has been modified to *always* be scoped under the
    `<optgroup>` that represents the country, otherwise we can accidentally
    select the wrong `<option>` from another country's `<optgroup>`.

    ECOMMERCE-5324
    Tom Scott

*   Skip saving user order details when user email does not match order

    ECOMMERCE-5392
    Matt Duffy

*   Add 3.1.4 and 3.0.18 release notes

    ECOMMERCE-5349
    Chris Cressman

*   Expand "Testing" guide

    * Add strong text about filesystem and ruby path alignment for test decorators
    * Suggest using 'skip' within decorators
    * Demonstrate conditional test definitions

    ECOMMERCE-5352
    Chris Cressman

*   Expand "Appending" documentation

    * Add "Limitations & Workarounds" section w/recipes
    * Update some content and screenshots to account for changes in Workarea Share

    ECOMMERCE-5351
    Chris Cressman

*   Delete completed_order cookie when user logs out

    ECOMMERCE-5392
    Matt Duffy


Workarea 3.1.4 (2017-10-31)
--------------------------------------------------------------------------------

*   Add JS configs to "Configs" guide

    ECOMMERCE-5350
    Chris Cressman

*   Fix margin below Help Search UI in Admin

    ECOMMERCE-5388
    Curt Howard

*   Fix WORKAREA.environment.isTest in Teaspoon

    `WORKAREA.environment.isTest` has been returning `false` when run in
    the Teaspoon test environment.

    (facepalm)

    ECOMMERCE-5347
    Curt Howard

*   Upgrade sidekiq-cron to latest minor

    ECOMMERCE-5358
    Matt Duffy

*   Improve reporting from WORKAREA.duplicateId module

    Now `WORKAREA.duplicateId` will throw a true Error in the test environment
    and log a console.error in development.

    Reporting has further been improved to display:

    - the current path of the route that contains duplicate IDs, helping
    with debugging in the test environment
    - real HTMLElements via the console in development

    ECOMMERCE-5381
    Curt Howard

*   Fix WORKAREA.environment.isTest in Teaspoon

    `WORKAREA.environment.isTest` has been returning `false` when run in
    the Teaspoon test environment.

    (facepalm)

    ECOMMERCE-5347
    Curt Howard

*   Add svg-icon--link-color to svg-icon component

    ECOMMERCE-5375
    Curt Howard

*   Add configs guide

    ECOMMERCE-5300
    Chris Cressman

*   Remove caching from 404s

    ECOMMERCE-5359
    Matt Duffy

*   Update method of asset id lookup in content recipe

    Document the availability of find_asset_id_by_file_name in Workarea 3.1
    within recipe for adding a content block type.

    ECOMMERCE-5299
    Chris Cressman

*   Add boolean content field to content guide

    Add the boolean content field type, which was introduced in Workarea
    3.1, to the list of content field types in the content guide.

    ECOMMERCE-5299
    Chris Cressman

*   Adds z-index to browsing controls filter dropdown

    ECOMMERCE-5268
    Ivana Veliskova

*   Support multiple "Category" product rules

    When selecting multiple categories in a product rule for "Category
    equals", all rules are combined together and only show products matching
    every rule. We needed searches to return results that match any of the
    category rules, not all of them, so we're wrapping the combined category rules
    query in a "should" (which is the way Elasticsearch spells "OR") clause.
    Multiple categories can be specified by separating their IDs with commas.

    ECOMMERCE-5263
    Tom Scott


Workarea 3.1.3 (2017-10-17)
--------------------------------------------------------------------------------

*   Change health_check to render plain

    render :text was removed in rails 5.1, change to render plain instead.

    ECOMMERCE-4692
    Eric Pigeon

*   Change health_check to render plain

    render :text was removed in rails 5.1, change to render plain instead.

    ECOMMERCE-4692
    Eric Pigeon

*   Add extension guides

    ECOMMERCE-5231
    Chris Cressman

*   Prevent Catalog::Product.find_by_sku from returning unexpected products

    It's possible for `Catalog::Product.find_by_sku` to return a product you
    may not expect when passing in `nil` or an alternative blank value.
    Instead of attempting a query when the SKU passed in is `nil`, we are
    now returning `nil` and short-circuiting the query altogether.

    ECOMMERCE-5046
    Tom Scott

*   Only refresh release select tooltip when form invalid

    ECOMMERCE-5271
    Curt Howard

*   Fix quoted release name in Release Select

    ECOMMERCE-4445
    Brian Berg

*   Fix error in divider content blocks for upgrades

    Migrating from v3.0 to v3.1 will throw an error due to the divider
    content block adding new fields to the database. This fix determines
    if the fields are set or not before trying to render the template.

    This is not an issue for projects that run migrations after the
    upgrade is complete. Nor is it an issue for projects beginning
    development on v3.1.0 or higher.

    ECOMMERCE-5228
    Curt Howard

*   Don't show complex data types in settings dashboard

    This will prevent things like payment gateways from revealing secrets
    and clean up display.

    ECOMMERCE-5238
    Ben Crouse

*   Improve presentation of new release option UI

    - Require release name in form
    - Focus input when a user interacts with the UI

    ECOMMERCE-5271
    Curt Howard

*   Rewrite takeover management test in content_blocks_spec.js

    PhantomJS is a real fickle mistress. Previously we had been testing
    the functionality of the removal of the takeover on iframe load, which
    is one of the two usecases for the removal. PhantomJS, in Bamboo, just
    started randomly failing this test, probably because of the way we
    we were forced to construct the test iframe in the first place.

    This test has been rewritten to support the other type of management,
    the defacto time-based removal, which previously had been untested.

    (shrug)

    ECOMMERCE-5256
    Curt Howard

*   Add dragonfly-s3_data_store to app template

    In most deployment setups, S3 is used as a data store for Dragonfly.
    While this is not a requirement of the platform (and therefore does not
    qualify it for a Workarea dependency), we are adding it to Gemfile as a
    "suggested" dependency to make it easier for developers to configure
    their real-world deployed applications.

    ECOMMERCE-5269
    Tom Scott

*   Improve mobile experience select elements in storefront

    This change let the select elements to truncate theirs content gracefully
    on mobile and avoid the select to take more space than the viewport

    ECOMMERCE-5190
    Jeremie Ges

*   Don't include CSRF tokens in response bodies for HTTP cached Requests

    ECOMMERCE-5250
    Ben Crouse

*   Patch to bump widths of i18n textboxes in the admin.

    Localized inputs bring a globe icon which reduce the fillable size for the user.
    This change handles this side-effect by adding more width on the i18n textboxes.

    ECOMMERCE-5192
    Jeremie Ges

*   Fix duplicate $scope initialization for PDP sku selects

    When changing skus on a generic PDP template, the new product details partial is requested via AJAX. It then replaces the existing partial in the DOM with the response form the server. The method of DOM replacement was throwing an error when attempting to reinit modules on the new DOM. The DOM replacement method has been changed to correct this.

    ECOMMERCE-5221
    Brian Berg


Workarea 3.1.2 (2017-10-03)
--------------------------------------------------------------------------------

*   Allow toggle buttons to have unique DOM IDs

    ECOMMERCE-5248
    Curt Howard

*   Search pages w/ no results should return 404 instead of 200

    This is an SEO recommendation made by Google:
    https://support.google.com/webmasters/answer/181708?hl=en

    ECOMMERCE-4889
    Ben Crouse

*   Update "Testing" guide with Workarea 3.1 changes

    * List additional test runners (per-plugin)
    * List additional factories
    * Update descriptions of test types to reflect adoption of Rails 5.1
    system tests

    ECOMMERCE-5235
    Chris Cressman

*   Document the only_if Sidekiq option for callbacks workers

    Update the Workers guide to cover the only_if Sidekiq option for
    callbacks workers, which was added in Workarea 3.1.

    ECOMMERCE-5236
    Chris Cressman

*   Include option to skip Active Record in all app template examples

    IT reported some Production apps were depending on Active Record because
    the person who created them did not include the option to skip Active
    Record. Although the app template guide has always implicitly encouraged
    the use of this option, this change makes it explicit and pervasive.

    ECOMMERCE-5232
    Chris Cressman

*   Fix search indexes section of "Configure Locales" guide

    Remove code example specific to Workarea 2 and generalize the advice
    for updating search after adding a locale.

    ECOMMERCE-5234
    Chris Cressman

*   Fix enforce hosts for paths that don't match routes

    Discovered in Harriet Carter, where it manifested as 404s without the
    proper host redirection kicking in.

    When a request is made to the app that doesn't have the right host, the
    enforce host kicks in too late to have effect. This updates the logic to
    enforce hosts to middleware so that can kick in regardless of Rails'
    routing.

    ECOMMERCE-5246
    Ben Crouse


Workarea 3.1.1 (2017-09-26)
--------------------------------------------------------------------------------

*   Fix credit card tests stubbing ActiveMerchant::Responses

    ActiveMerchant::Response has an attr_reader for #authorization expecting
    it to be passed in the options, but the test suite has been passing it
    in the params and accessing it through the params.  Move the
    authorization into the options and use the attr_reader to access it.

    ECOMMERCE-5229
    Eric Pigeon

*   Tweak search suggestion logic to improve spelling corrections

    ECOMMERCE-5182
    Matt Duffy

*   Hack to eliminate development error when app reloads

    ECOMMERCE-5115
    Matt Duffy

*   Fixes host app style guide partials not being added to style guide

    ECOMMERCE-5166
    Brian Berg

*   Delete eslintingore, add test methods to eslintrc

    A few points:
    - `.eslintignore` didn't work on unix systems, only BSD
    - the tests were being ignored out of convenience, which was the wrong
    call. Tests are every bit as important to lint as their module
    counterparts.
    - Teaspoon fails completely silently when a syntax error is encountered,
    which is the strongest reason to use linting on these files.

    This commit also
    - Fixes url_spec.js test that was failing, silently.

    ECOMMERCE-5206
    Curt Howard

*   Delete eslintingore, add test methods to eslintrc

    A few points:
    - `.eslintignore` didn't work on unix systems, only BSD
    - the tests were being ignored out of convenience, which was the wrong
    call. Tests are every bit as important to lint as their module
    counterparts.
    - Teaspoon fails completely silently when a syntax error is encountered,
    which is the strongest reason to use linting on these files.

    This commit also
    - Fixes url_spec.js test that was failing, silently.

    ECOMMERCE-5206
    Curt Howard

*   Correct logic that updates navigable_slug

    ECOMMERCE-5224
    Matt Duffy

*   Correct logic that updates navigable_slug

    ECOMMERCE-5224
    Matt Duffy

*   Fixes host app style guide partials not being added to style guide

    ECOMMERCE-5166
    Brian Berg

*   Ensure search customization insights test waits for xhr

    ECOMMERCE-5218
    Curt Howard

*   Ensure search customization insights test waits for xhr

    ECOMMERCE-5218
    Curt Howard

*   Tweak search suggestion logic to improve spelling corrections

    ECOMMERCE-5182
    Matt Duffy

*   Fix parsing bug in WORKAREA.url.parse

    Given the parameter string `?foo[]=bar&foo[]=baz` you would assume
    that WORKARE.url.parse would return an array named `foo` with two
    items, `bar` and `baz`, as it's value. Now it does!

    ECOMMERCE-5206
    Curt Howard

*   Fix analytics timezones

    Although server-side everything else is in UTC, to align with admin
    expectations, we'll need to configure a timezone for the time series
    data. This should be set to whatever the retailer requests.

    In a future version, we'll want to consolidate timezone management to a
    single config option (probably relying on the Rails config) so this is a
    temporary fix.

    ECOMMERCE-5167
    Ben Crouse


Workarea 3.1.0 (2017-09-15)
--------------------------------------------------------------------------------

*   Fix test that can fail due to timing problems

    ECOMMERCE-5207
    Ben Crouse


Workarea 3.1.0.beta.3 (2017-09-13)
--------------------------------------------------------------------------------

*   Add add to cart confirmation analytics event

    ECOMMERCE-5140
    Curt Howard

*   Render search message directly on search results page for visibility

    ECOMMERCE-5181
    Matt Duffy

*   Add only_if option for enqueuing sidekiq callbacks

    add the opposite of ignore_if as syntactic sugar for sidekiq callbacks

    ECOMMERCE-5079
    Eric Pigeon

*   Disable publish and undo buttons for user who can not publish now

    ECOMMERCE-5171
    Matt Duffy

*   Convert query-based bulk actions to ids to perserve dataset

    ECOMMERCE-5155
    Matt Duffy

*   Add favicon to admin layout

    ECOMMERCE-5163
    Dave Barnow


Workarea 3.1.0.beta.2 (2017-09-06)
--------------------------------------------------------------------------------

*   Deprecate search auto filter

    This has caused too many problems, and continues to do so despite toning
    it down a lot in v3. Render a deprecation warning if this is used, and
    then remove in v3.2

    ECOMMERCE-5170
    Ben Crouse

*   Improve quality of search reporting

    A few fixes/improvements here:
    * Don't include queries less than 3 characters
    * Only use top 3% of searches for top searches (long tail)
    * Ignore searches with abandonment > 100%
    * Make more attempts to prevent searches with abandonment > 100%

    ECOMMERCE-5169
    Ben Crouse

*   Redirect to order admin page after placing order as an admin

    (and you have permissions to view orders)

    ECOMMERCE-5161
    Ben Crouse

*   Handle taxonomy block when starting taxon has been deleted.

    ECOMMERCE-4795
    Matt Duffy

*   Add option to send creation email in admin account creation

    ECOMMERCE-5120
    Ben Crouse

*   Set menu to inactive when deleted in a release

    ECOMMERCE-4796
    Matt Duffy

*   Show not-allowed cursor for disabled buttons

    ECOMMERCE-5162
    Dave Barnow

*   Correct logic to determine featured products that need indexing

    ECOMMERCE-4839
    Matt Duffy

*   Update Heap account number for new Workarea account

    ECOMMERCE-5138
    Ben Crouse

*   Remove deleted products from recommendations

    ECOMMERCE-5137
    Ben Crouse

*   Clean up workflow actions in disabled states

    Clean these up with a tooltip so we provide familiar, disabled buttons
    with help tooltips describing why they're disabled.

    ECOMMERCE-5159
    Ben Crouse

*   Default permission checkboxs in admin creation workflow to checked

    ECOMMERCE-5156
    Matt Duffy

*   Touch payment when payment transactions are saved for accurate update_at

    ECOMMERCE-5150
    Matt Duffy

*   Add absolute_path_to_file to cassette persister

    When vcr finds a cassette but it doesn't match the url currently being
    requested it will use absolute_path_to_file to give an error message
    about the cassette it is trying to use.

    ECOMMERCE-5151
    Eric Pigeon

*   Return false from ShippingOptions#valid? if there is no selected service

    ECOMMERCE-5153
    Matt Duffy

*   Supportive changes for OMS-41 and v3.1.0 Front-End Cleanup

    - Beef up text-button style guide
    - Add a icon to core for general style_guide use
    - Restyle text-button component
    - Add Trash link & append point to Settings Dashboard
    - Only apply a top margin to properties that are adjascent

    ECOMMERCE-5131
    Curt Howard

*   Add expiration for content block caches

    ECOMMERCE-5148
    Matt Duffy

*   Correct search customization activity views

    ECOMMERCE-5125
    Matt Duffy

*   Update homebase pings to handle nested plugins

    Change the homebase ping to account for plugins nested deeper than just
    under ::Workarea.  Change the ping to load the constant defined under
    the plugin constant without looking at the Workarea::VERSION and just
    send 0.0.0 if the version isn't defined.

    ECOMMERCE-5080
    Eric Pigeon

*   Do not force eager loading in development

    ECOMMERCE-5115
    Matt Duffy

*   Display first_displayable_value of content block only if it's a String, adds unit test.

    Fixes: ECOMMERCE-5047
    mdelrossi

*   Ignoring 404's when deleting documents from elastic search

    If an item isn't in elastic search when it is being updated, it first gets deleted and then readded. If it doesn't exist it throws an error.

    ECOMMERCE-5132
    Matt Martyn

*   Change logo from SVG to PNG

    Open Graph tags do no support SVG formatted images. There were a few possible ways to solve this:

    1. Add an additional png formatted image for use within the Open Graph tags, while keeping the main logo an svg
    2. Converting the main svg logo to a png when used within the Open Graph tag
    3. Convert the svg logo with a png format in all instances

    __Option 1__ creates an issue for implementers to know/remember to update multiple logo images. Otherwise, in their
    social shares, the Workarea logo would be shown instead of the brand.

    __Option 2__ has a few technical challenges. Since the logo does not exist in Dragonfly, but just sits in the asset pipeline,
    solutions to these challenges do not justify the effort.

    __Option 3__ was the simplest, most effective way to solve the issue. There wasn't much gained for SIs by having the logo
    be svg format in base, as svg is not always the best format for an image. So every implementation already naturally addresses
    the choice of logo format based on their needs.

    ECOMMERCE-5019
    Brian Berg

*   Provide loading indicator on buttons using UJS data_disable_with

    - Create white-alpha-50 color variable
    - Create loading—inline component modifier
    - Create loading—light component modifier
    - Modify style guides
    - Add loading indicator to PDP add to cart and checkout step buttons
    - Add data-remote attribute to PDP add to cart form
    - Add helper for rendering the loading markup

    ECOMMERCE-5095
    Dave Barnow

*   Index admin order updated at as most recent time between order, payment & fulfillment

    ECOMMERCE-5122
    Matt Duffy

*   Improve accessibility of PDP image alt tag

    ECOMMERCE-3875
    Brian Berg


Workarea 3.1.0.beta.1 (2017-08-28)
--------------------------------------------------------------------------------

*   Overhaul state component

    ECOMMERCE-5109
    Curt Howard

*   Convert payment transaction index to a table for easier scanning

    ECOMMERCE-5123
    Matt Duffy

*   Opening tracking link in admin in a new window

    ECOMMERCE-5124
    Ben Crouse

*   Add ability to ignore certain fields for unsaved changes prompt

    ECOMMERCE-5113
    Matt Duffy

*   Make admin orders index into a table

    * Tableize index page
    * Show payment/fulfillment status on index
    * Index updated at as time last indexed to reflect time since last change
    * Update bulk action selection to work with table

    ECOMMERCE-5107
    Matt Duffy

*   Convert credit card operation tests to minitest

    ECOMMERCE-5110
    Eric Pigeon

*   Fixes teaspoon tests when running in a timezone other than EST.

    ECOMMERCE-4650
    Jake Beresford

*   Add out-of-the-box mappings to prevent indexing errors

    This is to reduce the number of "no field mapping" errors that can
    happen during category percolation on an empty index.

    ECOMMERCE-4883
    Ben Crouse

*   Add a title to summary card types in case the text overflows beyond the container

    ECOMMERCE-5085
    Dave Barnow

*   Remove new_framework_defaults.rb from plugin_template.

    File does not exist and was causing errors with creating new plugins

    ECOMMERCE-5099
    Jake Beresford

*   Fix category rule changes requiring reindexing

    Note that this is a semi-breaking change, but is necessary to fix the
    bug. It will require a full reindex of the storefront to fully take
    effect (but this is not required, the site will continue to work).

    ECOMMERCE-4883
    Ben Crouse

*   Add module for guarding against duplicate IDs

    In the test and development environments errors will now be thrown if
    a developer accidentially duplicates an ID somewhere in the document.

    ECOMMERCE-4808
    Steve Perks

*   Add asset id lookup method to content block definition api

    Eliminates the need for a lambda to be duplicated whenever defining
    content blocks, and provides a resuable method to look up assets by
    their file name.

    ECOMMERCE-5048
    Matt Duffy

*   Separate Order and fulfillment statues in admin, update status display

    ECOMMERCE-5037
    Matt Duffy

*   Add factory method to complete checkout

    Helper to make getting various placed-order scenarios easier in tests

    ECOMMERCE-5093
    Ben Crouse

*   Display template type on Product card UI

    ECOMMERCE-5085
    Curt Howard

*   Prevent double-submits on checkout forms

    We are now preventing double form submissions during checkout by applying
    the `data-disable-with` jQuery UJS hook to each of the form submit buttons.

    This commit includes jQuery UJS in the Storefront application manifest.

    ECOMMERCE-5088
    Curt Howard

*   Add tasks to run tests by plugin

    Allows running tests from a host app per-plugin.

    ECOMMERCE-5081
    Ben Crouse

*   typecast data on block drafts for proper preview display

    ECOMMERCE-4958
    Matt Duffy

*   Extend Divider block to become a Spacing block

    By allowing a user to toggle the applied border of a Divider block on
    and off the block can effectually become a simple spacing block, used
    for creating visual separation between other blocks.

    This feature adds the ability to increase the height of the divider as
    well.

    ECOMMERCE-4958
    Curt Howard

*   Fix svg precompile path

    ECOMMERCE-5068
    Curt Howard

*   Add object name & view on Storefront links to create flows

    ECOMMERCE-5038
    Curt Howard

*   Fix menu when help helper is active

    ECOMMERCE-3961
    Curt Howard

*   Update help helper text

    ECOMMERCE-5051
    Curt Howard

*   Disable http cache for admin users

    A max-age of 15 minutes was being set for the Cache-Control headers
    for admin users. This caused issues in dev environments where a page
    request would be rendered from the disk. This fix will prevent any
    upstream server caches from caching as well, for admin users.

    ECOMMERCE-5056
    Curt Howard

*   Fix minitest.rake_run error

    See: https://github.com/rails/rails/commit/0d72489b2a08487f71dd4230846c01a5d99ef35f

    ECOMMERCE-5054
    Dave Barnow

*   Throw error when modules are reinitialized on the same $scope

    This commit also reduces the scope of the initial `WORKAREA.initModules`
    call to `$('body')` and not `$(document)` to better emulate how
    Turbolinks actually works.

    ECOMMERCE-4386
    Curt Howard

*   Upgrade help helper

    ECOMMERCE-3961
    Curt Howard

*   Add comments and copies to order timeline

    ECOMMERCE-5035
    Ben Crouse

*   Move empty activities messaging into the results area of the activity feed

    ECOMMERCE-4606
    Dave Barnow

*   Add `text-transform: none !important` to feature_spec_helper to prevent test failure due to aesthetic changes.
    Adjust product image test to not be uppercase

    ECOMMERCE-4771
    Steve Perks

*   Raise error when missing discount application order config

    When Workarea.config.discount_application_order is missing a discount
    class, this will result in an unclear error. Instead, raise a custom
    error with helpful info on how to resolve the situation.

    ECOMMERCE-5031
    Ben Crouse

*   Handle visibility of publish tooltip on content editor

    ECOMMERCE-4980
    Matt Duffy

*   Make avatar in admin toolbar a link to user account edit page

    ECOMMERCE-4971
    Dave Barnow

*   Automatically generate navigation redirects when slugs change

    ECOMMERCE-4994
    Matt Duffy

*   Add payment status with admin index filter

    ECOMMERCE-4998
    Matt Duffy

*   Fix all_tags method from mongoid-simple-tags

    This is the result of the Mongoid upgrade. We should stop depending on
    this gem in a future release since it isn't maintained anymore.

    ECOMMERCE-5021
    Ben Crouse

*   Sanitize hyphenated synonyms
    ECOMMERCE-5010
    ryan tulino

*   Only prompt on unsaved changes for forms that enable it

    ECOMMERCE-4929
    Matt Duffy

*   Add publish selects for variants#new and content#advanced

    ECOMMERCE-4978
    fixes: ECOMMERCE-4979
    Matt Duffy

*   Add detail methods to Product from Variant

    Several builds have implemented detail manipulation
    to Product. This commit adds the methods that exist
    on Variant to Product.

    ECOMMERCE-5002
    Mark Platt

*   Integrate Rails 5.1 System Tests into existing system tests.

    ECOMMERCE-4993
    Matt Duffy

*   Update plugin_template to configure teaspoon

    ECOMMERCE-5001
    Jake Beresford

*   Handle restoration of items in trash without standard show pages

    ECOMMERCE-4950
    Matt Duffy

*   Upgrade to Rails 5.1

    ECOMMERCE-4993
    Matt Duffy

*   Reorder order cards in admin

    Groups read only and actionable cards together.

    ECOMMERCE-4925
    Ben Crouse

*   Add localization for order name
    ECOMMERCE-4938
    ryan tulino

*   Add new permissions to admin sample data

    ECOMMERCE-4969
    Dave Barnow

*   Convert remaining admin specs to tests

    ECOMMERCE-4989
    Ben Crouse

*   Resolve issues with conflicting js event targets

    ECOMMERCE-4929
    Matt Duffy

*   Scrub _uid from the end of field names for activity messages.

    ECOMMERCE-4976
    Matt Duffy

*   Always show user's current avatar on user edit page

    ECOMMERCE-4974
    Matt Duffy

*   Fix trash restores with validation errors

    ECOMMERCE-4957
    Ben Crouse

*   Don't destroy Dragonfly assets from the datastore

    This breaks restoring assets from trash

    ECOMMERCE-4955
    Ben Crouse

*   Add timeline to orders in the admin

    Consolidate order-related events to give admins a clear timeline of
    what's going on with an order.

    ECOMMERCE-4925
    Ben Crouse

*   Fix inconsistency in Redis config URL

    ECOMMERCE-4967
    Ben Crouse

*   Fix search customization destroy activity view

    ECOMMERCE-4951
    Matt Duffy

*   Add permission for restoring deleted items from trash

    ECOMMERCE-4952
    Matt Duffy

*   Fix display of active/inactive prices on price edit view

    Add system test for pricing sku prices coverage
    ECOMMERCE-4875
    Dave Barnow

*   Improve Form Fields to Provide a Better User Experience

    Update the form field tags to use the correct HTML5 attributes.
    These changes will allow the appropriate touch keyboards to appear, as
    well as create a smoother form filling experience for the user. The
    following form input attributes are being utilized: Autocorrect ,
    Autocapitalization, pattern,  and autocomplete. This change is based on
    usability study by Baymard Institute
    https://baymard.com/labs/touch-keyboard-types

    ECOMMERCE-4581
    embendavid

*   Add ability to add custom avatars to users via image upload or gravatar

    ECOMMERCE-4927
    Matt Duffy

*   Prevent workflow publish steps from selecting new release without setting a name

    ECOMMERCE-4832
    Matt Duffy

*   Use product image with option matching selected facets when available

    ECOMMERCE-3977
    Matt Duffy

*   Add js module to prompt user before navigating away from a form with unsaved changes.

    ECOMMERCE-4929
    Matt Duffy

*   Add boolean field type for content block types

    ECOMMERCE-4928
    Matt Duffy

*   Fix translations for search customization destroy, remove link to shipping service show as it doesn’t exist

    ECOMMERCE-4947
    Dave Barnow

*   Add default maxWidth to tooltips

    ECOMMERCE-4817
    Matt Duffy

*   Add trash functionality to admin

    This feature allows administrators to recover deleted things in the
    admin.

    ECOMMERCE-4874
    Ben Crouse

*   Add permission control for publishing changes to the live site

    ECOMMERCE-4835
    Matt Duffy

*   Strengthen content_system_test

    ECOMMERCE-4746
    Curt Howard

*   Prefer S3 configuration from ENV vars if present

    This allows builds to skip S3 configuration for Dragonfly

    ECOMMERCE-4847
    Ben Crouse

*   If available, show the pricing skus sale price on the price card

    * Add style for a horizontal rule separator in cards

    ECOMMERCE-4830
    Dave Barnow

*   Fix tests depending on auto_capture to be turned off

    ECOMMERCE-4871
    Ben Crouse

*   Add sequential editing for products

    Allow an admin to quickly edit many products in a row

    ECOMMERCE-4845
    Ben Crouse

*   Show redemption amount on card and edit view

    ECOMMERCE-4822
    Dave Barnow

*   Don't allow setting up an admin for non-permissions-managers

    ECOMMERCE-4841
    Ben Crouse

*   Fix BulkAction::ProductEdit to properly apply prices across SKUs

    ECOMMERCE-4826
    Matt Duffy

*   Increase available inventory query value to avoid invalid order in order seeds

    ECOMMERCE-4775
    Matt Duffy

*   Add account creation workflow to the admin

    This allows creating a customer or admin, and allows proceding to
    impersonate the new account.

    ECOMMERCE-4785
    Ben Crouse

*   Show link to copied order in admin

    ECOMMERCE-4821
    Ben Crouse

*   Handle editing/removing existing variants in product workflow

    ECOMMERCE-4806
    Matt Duffy

*   Cleanup styles around html sitemap

    ECOMMERCE-4778
    Matt Duffy

*   Handle product copy with ID matching another product

    ECOMMERCE-4812
    Matt Duffy

*   Allow product bulk edit changes to be applied within a release

    ECOMMERCE-4787
    Matt Duffy

*   Allow admin to copy a product

    ECOMMERCE-4786
    Matt Duffy

*   Add variant ordering

    Variants has a display order drag and drop, and this sorting order will
    reflect in the storefront.

    ECOMMERCE-4727
    Ben Crouse

*   Add HTML sitemap for seo considerations

    ECOMMERCE-4729
    Matt Duffy

*   Properly disable Feature.js tests in test environment

    Due to a race condition, the previous way we were removing the
    Feature.js classes from the root HTML element was not working
    consistently. This was due to a straight port over from the way
    we handled it for Modernizr.

    To avoid this we have rearranged the load order of the scripts
    called in Storefront's `head.js.erb` manifest. Now we load the
    Feature.js library, then the spec helper, then the Feature.js
    method which applies the classes.

    The spec helpers job is still to disable these tests and, due to
    the reorganization, this now works properly and consistently.

    ECOMMERCE-4760
    Curt Howard

*   Prevent feature.js from detecting test driver as a touch device

    This will disable the touch feature and prevent the class from being added to the DOM when running tests
    ECOMMERCE-4760
    Dave Barnow

Workarea 3.0.15 (2017-09-26)
--------------------------------------------------------------------------------

*   Tweak search suggestion logic to improve spelling corrections

    ECOMMERCE-5182
    Matt Duffy

*   Delete eslintingore, add test methods to eslintrc

    A few points:
    - `.eslintignore` didn't work on unix systems, only BSD
    - the tests were being ignored out of convenience, which was the wrong
    call. Tests are every bit as important to lint as their module
    counterparts.
    - Teaspoon fails completely silently when a syntax error is encountered,
    which is the strongest reason to use linting on these files.

    This commit also
    - Fixes url_spec.js test that was failing, silently.

    ECOMMERCE-5206
    Curt Howard

*   Correct logic that updates navigable_slug

    ECOMMERCE-5224
    Matt Duffy

*   Fixes host app style guide partials not being added to style guide

    ECOMMERCE-5166
    Brian Berg

*   Ensure search customization insights test waits for xhr

    ECOMMERCE-5218
    Curt Howard

*   Fix parsing bug in WORKAREA.url.parse

    Given the parameter string `?foo[]=bar&foo[]=baz` you would assume
    that WORKARE.url.parse would return an array named `foo` with two
    items, `bar` and `baz`, as it's value. Now it does!

    ECOMMERCE-5206
    Curt Howard

*   Fix analytics timezones

    Although server-side everything else is in UTC, to align with admin
    expectations, we'll need to configure a timezone for the time series
    data. This should be set to whatever the retailer requests.

    In a future version, we'll want to consolidate timezone management to a
    single config option (probably relying on the Rails config) so this is a
    temporary fix.

    ECOMMERCE-5167
    Ben Crouse


Workarea 3.0.14 (2017-09-15)
--------------------------------------------------------------------------------

*   Randomize release colors in Calendar UI

    To help improve visibility when many releases are added to a project,
    now each release will be color coded, based on the name of the release.

    ECOMMERCE-5173
    Curt Howard

*   Adds unique ID for `wl_text_box_small_number` in the style guide, uses `should` prose to component description, updates scss variable/value spacing, removes unnecessary quotes from the css.

    ECOMMERCE-5185
    mdelrossi

*   Adds some extra width to `.text-box--small` for number inputs in the admin to account for overlap.

    ECOMMERCE-5185
    mdelrossi

*   Use asset url helper to ensure admin view original link uses CDN

    ECOMMERCE-5139
    Matt Duffy


Workarea 3.0.13 (2017-09-06)
--------------------------------------------------------------------------------

*   Improve quality of search reporting

    A few fixes/improvements here:
    * Don't include queries less than 3 characters
    * Only use top 3% of searches for top searches (long tail)
    * Ignore searches with abandonment > 100%
    * Make more attempts to prevent searches with abandonment > 100%

    ECOMMERCE-5169
    Ben Crouse

*   Handle taxonomy block when starting taxon has been deleted.

    ECOMMERCE-4795
    Matt Duffy

*   Set menu to inactive when deleted in a release

    ECOMMERCE-4796
    Matt Duffy

*   Correct logic to determine featured products that need indexing

    ECOMMERCE-4839
    Matt Duffy

*   Update Heap account number for new Workarea account

    ECOMMERCE-5138
    Ben Crouse

*   Remove deleted products from recommendations

    ECOMMERCE-5137
    Ben Crouse

*   Add absolute_path_to_file to cassette persister

    When vcr finds a cassette but it doesn't match the url currently being
    requested it will use absolute_path_to_file to give an error message
    about the cassette it is trying to use.

    ECOMMERCE-5151
    Eric Pigeon

*   Return false from ShippingOptions#valid? if there is no selected service

    ECOMMERCE-5153
    Matt Duffy

*   Add expiration for content block caches

    ECOMMERCE-5148
    Matt Duffy

*   Correct search customization activity views

    ECOMMERCE-5125
    Matt Duffy

*   Update homebase pings to handle nested plugins

    Change the homebase ping to account for plugins nested deeper than just
    under ::Workarea.  Change the ping to load the constant defined under
    the plugin constant without looking at the Workarea::VERSION and just
    send 0.0.0 if the version isn't defined.

    ECOMMERCE-5080
    Eric Pigeon

*   Display first_displayable_value of content block only if it's a String, adds unit test.

    Fixes: ECOMMERCE-5047
    mdelrossi

*   Ignoring 404's when deleting documents from elastic search

    If an item isn't in elastic search when it is being updated, it first gets deleted and then readded. If it doesn't exist it throws an error.

    ECOMMERCE-5132
    Matt Martyn

*   Change logo from SVG to PNG

    Open Graph tags do no support SVG formatted images. There were a few possible ways to solve this:

    1. Add an additional png formatted image for use within the Open Graph tags, while keeping the main logo an svg
    2. Converting the main svg logo to a png when used within the Open Graph tag
    3. Convert the svg logo with a png format in all instances

    __Option 1__ creates an issue for implementers to know/remember to update multiple logo images. Otherwise, in their
    social shares, the Workarea logo would be shown instead of the brand.

    __Option 2__ has a few technical challenges. Since the logo does not exist in Dragonfly, but just sits in the asset pipeline,
    solutions to these challenges do not justify the effort.

    __Option 3__ was the simplest, most effective way to solve the issue. There wasn't much gained for SIs by having the logo
    be svg format in base, as svg is not always the best format for an image. So every implementation already naturally addresses
    the choice of logo format based on their needs.

    ECOMMERCE-5019
    Brian Berg

*   Improve accessibility of PDP image alt tag

    ECOMMERCE-3875
    Brian Berg

*   Fixes teaspoon tests when running in a timezone other than EST.

    ECOMMERCE-4650
    Jake Beresford


Workarea 3.0.12 (2017-08-23)
--------------------------------------------------------------------------------

*   Add user permissions append point

    ECOMMERCE-5111
    Curt Howard


Workarea 3.0.11 (2017-08-22)
--------------------------------------------------------------------------------

*   Add out-of-the-box mappings to prevent indexing errors

    This is to reduce the number of "no field mapping" errors that can
    happen during category percolation on an empty index.

    ECOMMERCE-4883
    Ben Crouse

*   Fix output of package shipped datetime

    ECOMMERCE-5101
    Dave Barnow

*   Fix default icon not loading for custom blocktype in admin

    ECOMMERCE-5059
    Diane Douglas

*   Fix category rule changes requiring reindexing

    Note that this is a semi-breaking change, but is necessary to fix the
    bug. It will require a full reindex of the storefront to fully take
    effect (but this is not required, the site will continue to work).

    ECOMMERCE-4883
    Ben Crouse

*   Move multiple test classes into separate files

    This creates decoration difficulties described here:
    https://discourse.weblinc.com/t/multiple-classes-in-discounting-system-test/843/4

    ECOMMERCE-5098
    Ben Crouse

*   Updates style_guide generator usage notes

    ECOMMERCE-5078
    Ivana Veliskova

*   Convert store credit card test to minitest

    ECOMMERCE-5097
    Eric Pigeon

*   Require rails test unit reporter in workarea test rake task

    ECOMMERCE-5087
    Matt Duffy

*   Remove minitest-reporters, use minitest-junit for CI reporting

    ECOMMERCE-5087
    Matt Duffy

*   Clean up cancel item logic and fulfillment cancellation mailer

    Ensure cancel events do not get added to fulfillemnt items when
    the quantity to cancel is 0, and make the fulfillment mailer logic
    clearer for displaying canceled items.

    ECOMMERCE-5069
    Matt Duffy

*   Adds hidden field tag to submit empty selection when no checkboxes are selected

    ECOMMERCE-4749
    Ivana Veliskova

*   Fix mixing up ID data types on user activity

    This surfaced in the new API storefront recent views endpoint.

    ECOMMERCE-5096
    Ben Crouse

*   Remove rendering of unwanted style guide partials

    Both admin and storefront render the partials respective to their
    engine by default; however, if a host app overrides any one of these
    files, they will be erroneously rendered outside of their engines scope
    (i.e storefront styleguide partials overridden or newly created in the
    host app will ALWAYS be rendered in `/admin/style_guides`)

    These changes pass a new parameter `@scope` which is infered from the
    controller's parent.  This way. partials present in the host app will
    only be rendered as they relate to the current scope.

    ECOMMERCE-4789
    Jordan Stewart

*   Disable http cache for admin users

    A max-age of 15 minutes was being set for the Cache-Control headers
    for admin users. This caused issues in dev environments where a page
    request would be rendered from the disk. This fix will prevent any
    upstream server caches from caching as well, for admin users.

    ECOMMERCE-5056
    Curt Howard

*   Guard against nil models in inventory status view model

    When a product's inventory has no items available it had the potential
    of throwing an error.

    ECOMMERCE-5067
    Curt Howard

*   Fixes Tabbed Navigation Duplication

    Admin tabbed navigation was duplicating because turbo links was caching after js rendered content, and each subsequent reload re rendered duplicate content.
    Removing the JS rendered content in turbo link's before:cache hook allows us to fix this issue.

    ECOMMERCE-4945
    Lucas Boyd

*   Fixes New Release Duplication in Product Admin

    Turbolinks was caching the release dropdown, then re running the module on reload, causing a duplication.
    Removing the dynamic release list before turbolinks begins caching fixes the issue.

    ECOMMERCE-4833
    Lucas Boyd

*   Creates styles for the chart legend and includes it in style guide

    Adds in missing styles and component for chart legend and creates styles for the chart legend.
    Then includes the chart legend and styles in the style guide.

    Fixes: ECOMMERCE-4647
    Ivana Veliskova

*   Fix svg precompile path

    ECOMMERCE-5068
    Curt Howard


Workarea 3.0.10 (2017-08-08)
--------------------------------------------------------------------------------

*   Fix messaging when a test in a decorator fails

    Our former solution using a minitest plugin to monkey-patch Rails no
    longer works after Rails v5.0.5 (they made the Rails minitest hack into
    a proper minitest plugin).

    ECOMMERCE-5054
    Ben Crouse

*   Ensure canceled items are output in fulfillment cancel mailer

    When canceling fulfillment for items, the correct order item ID wasn't being
    sent to the mailer. Also, within the view's loop of canceled items, the order
    item id needed to be converted to a string to match the keys in the
    cancellations hash. Add test coverage for mailer content

    ECOMMERCE-5045
    Brian Berg

*   Fix minitest.rake_run error

    See: https://github.com/rails/rails/commit/0d72489b2a08487f71dd4230846c01a5d99ef35f

    ECOMMERCE-5054
    Dave Barnow

*   Add rack-attack blacklisting for credit card abuse

    On live sites, both placing the order and creating a saved credit card
    have been abused by spammers trying to find credit card numbers that
    work.

    ECOMMERCE-5022
    Ben Crouse


Workarea 3.0.9 (2017-07-25)
--------------------------------------------------------------------------------

*   Update plugin_template to configure teaspoon

    ECOMMERCE-5001
    Jake Beresford

*   Set content block data to result of typecasting to ensure types persist

    ECOMMERCE-4991
    Matt Duffy

*   Use absolute path for OG:URL meta tag

    Facebook is looking for an absolute URL for this property

    ECOMMERCE-5013
    Dave Barnow

*   Update image path used for open graph image metadata

    ECOMMERCE-5009
    Matt Duffy

*   Rename Shipping::Rate method association to service

    ECOMMERCE-5008
    Matt Duffy

*   Reset bulk action product edit before updating to allow removing changes

    ECOMMERCE-4966
    Matt Duffy

*   Remove sorting for Taxonomy content blocks

    Because the menu-editor UI is reused in the taxonomy content block UI
    sorting was enabled, though these blocks are not intended to allow sorting.

    ECOMMERCE-4946
    Curt Howard

*   Show only active blocks on admin content card

    ECOMMERCE-4959
    Matt Duffy

*   Ensure values repopulate correctly on bulk action product edits edit page

    ECOMMERCE-4639
    Matt Duffy

*   Fix changelog task in plugin_template

    The regular expressions used inside the Changelog rake task in the
    plugin_template needed proper escaping.

    ECOMMERCE-4937
    Curt Howard

*   Fix default currency display in the admin

    This will need to come from the Money gem, not localization since the
    Money gem is responsible for currency conversion.

    ECOMMERCE-4943
    Ben Crouse

*   Remove links to product for inventory and pricing when product does not exist

    ECOMMERCE-4960
    Matt Duffy

*   Fix inconsistency in Redis config URL

    ECOMMERCE-4967
    Ben Crouse

*   Fix path to svgs on import views

    ECOMMERCE-4948
    Dave Barnow

*   Flush Redis database when running seeds

    ECOMMERCE-4879
    Matt Duffy

*   Prevent error when triggering reset password for bad email

    ECOMMERCE-4933
    Francisco Galarza

*   Fix `undefined method `sidekiq_options_hash'` errors in sidekiq

    `sidekiq_options` is setter, but was being used as a getter.
    Now using `get_sidekiq_options[]` to properly get the sidekiq options

    ECOMMERCE-4890
    Brian Berg


Workarea 3.0.8 (2017-07-07)
--------------------------------------------------------------------------------

*   Explicitly require 'exifr/jpeg'

    Due to a bundle update `exifr` was throwing errors.

    ECOMMERCE-4934
    Curt Howard

*   Strengthen content_system_test

    ECOMMERCE-4746
    Curt Howard

*   Add append point for current user

    Create an append point in current user json for plugins to add custom
    user attributes.

    ECOMMERCE-4931
    Eric Pigeon

*   Optimize SVG icons

    ECOMMERCE-4813
    Dave Barnow

*   Correct the display of inventory backordered date in admin

    ECOMMERCE-4851
    Matt Duffy

*   Left align datepicker when publishing from workflow

    ECOMMERCE-4396
    Curt Howard

*   Adjust font-size of list of steps visible during a workflow

    ECOMMERCE-4415
    Curt Howard

*   Fix long taxonomy breadcrumbs in Primary Nav Content UI

    Truncate these breadcrumbs when they grow to break layout.

    ECOMMERCE-4486
    Curt Howard

*   Fix specificity bug in storefront reset CSS

    In our reset css file, we were previously removing border radius for all form inputs except for the radio button. This change removes the specificity to the radio input. As a side-effect of this, iOS was rendering radio buttons as squares instead of circles. To solve this, we have targeted radio buttons with a 50% border radius.

    ECOMMERCE-4882
    Dave Barnow

*   Fix text-box--medium link in style guide

    ECOMMERCE-4719
    Dave Barnow

*   Add feature spec helpers append point to top of CSS manifests

    ECOMMERCE-4802
    Dave Barnow

*   This fixes indenting within the generic template. Product name originally had all product info nested within it.
    ECOMMERCE-4723
    Mansi Pathak

*   Add disable option for toggle_button ui, fix toggles for product edit

    ECOMMERCE-4640
    Matt Duffy

*   Update product attributes card to reflect activeness, add info on edit page

    ECOMMERCE-4814
    Matt Duffy

*   Increase clickable area of summary UI during bulk action selection

    - Improve bulk_actions_system_test to actually test clearing the session

    ECOMMERCE-4507
    Curt Howard

*   Add pointer cursor to store front button and text-button styles

    ECOMMERCE-4877
    Dave Barnow

*   Move generated content block HAML to correct location

    ECOMMERCE-4856
    Dave Barnow

*   Add 'eqeqeq' rule to eslintrc

    ECOMMERCE-4885
    Curt Howard

*   Increase available inventory query value to avoid invalid order in order seeds

    ECOMMERCE-4775
    Matt Duffy

*   Remove duplicate $link-color in typography/links

    `$link-color` is defined in `settings/colors` due to it's broader
    useage across the front-end. Having it in both places will just
    confuse SIs.

    ECOMMERCE-4881
    Curt Howard

*   Provide a place for custom webfonts in the Storefront

    This file was omitted during v3 development due to the lack of need
    for the file. It has been readded as a reminder to SIs that this is
    the location where `@font-face` declarations should live.

    ECOMMERCE-4880
    Curt Howard

*   Improve plugin template

    - Update plugin gitignore
    - Allow seeds to be run from test/dummy app

    ECOMMERCE-4869
    Curt Howard

*   Randomize user@workarea.com password in non-development environments

    Hosting would appreciate randomizing this password in case builds forget
    to update this manually.

    ECOMMERCE-4873
    Ben Crouse

*   Fix incorrect test class names

    ECOMMERCE-4872
    Ben Crouse

*   Fix tests depending on auto_capture to be turned off

    ECOMMERCE-4871
    Ben Crouse

*   Fix left navigation not respecting taxon activeness

    ECOMMERCE-4863
    Ben Crouse

*   Fix activty log for published releases

    Activity log entries for published releases were trying to access the
    audited like it was a releasable model.  Update the partial to correclty
    display data from the audit log entry.

    ECOMMERCE-4864
    Eric Pigeon


Workarea 3.0.7 (2017-06-20)
--------------------------------------------------------------------------------

*   Fix validation styling in Storefront

    ECOMMERCE-4706
    Curt Howard

*   Move WORKAREA.forms from Core to Storefront and Admin

    ECOMMERCE-4706
    Curt Howard

*   Fix front-end validation message styling in Storefront

    During the v3 upgrade the need for a `.value` component in the Admin was
    reduced to the point of removal. This work was not performed in the
    Storefront.

    jQuery Validate applies a class to validation messages for styling
    purposes. The `WORKAREA.forms` module initializes jQuery Validate on all
    forms. The module and it's configuration lived in the Core engine and
    applied one class to both the Admin and Storefront engines.

    Since the Admin was expecting this class to be `.property__note--error`
    and the Storefront was expecting this class to be `.value__error` the
    configuration needed to be engine-specific. This change moves
    `WORKAREA.config.forms` object from the `core/config.js` file into
    `admin/config.js` and `storefront/config.js`, which allows each engine
    to customize it's properties as needed.

    ECOMMERCE-4706
    Curt Howard

*   Trigger calendar widget on backordered until field, add date to inventory attributes card

    ECOMMERCE-4827
    Dave Barnow

*   Add margin under each filter for when filters span two lines

    ECOMMERCE-4811
    Dave Barnow

*   Store relative URLs for product images in Elasticsearch cache

    The absolute values we have now require reindexing when moving data
    between environments. This will make transitions to production easier.

    ECOMMERCE-4783
    Ben Crouse

*   Add caching for default category of a product

    This has been a performance problem for launches.

    ECOMMERCE-4781
    Ben Crouse

*   Improve performance when indexing products based on category changes

    Take performance improvements made by Matt Martyn in a data import.

    ECOMMERCE-4824
    Ben Crouse

*   Update unique option for workers to :until_executing

    Matt Martyn discovered situations in import where the previous option
    was causing certain jobs to not be enqueued. So I'm loosening the
    uniqueness here to fix (which was his fix as well).

    ECOMMERCE-4780
    Ben Crouse

*   Fix incorrect taxes with multiple tax codes and discounts

    Taxable share only works if the price adjustment set only contains
    adjustments for the same line item.  If the order has multiple tax codes
    and a discount applied the amount for a taxable adjustment was
    incorrect.

    ECOMMERCE-4819
    Eric Pigeon

*   Fix duplicate IDs in content editing UI

    ECOMMERCE-4382
    Curt Howard

*   Allow wait_for_xhr timeout to be configured as-needed

    ECOMMERCE-4818
    Curt Howard

*   Fix scheduled sidekiq cron jobs

    Workarea::Admin::StatusReporter was moved to Workarea::StatusReporter
    and Workarea::UpdateDashboards is no longer a worker.

    ECOMMERCE-4801
    Eric Pigeon

*   Add append point to property style guide component

    * Needed for the floating_labels plugin

    ECOMMERCE-4799
    Beresford, Jake

*   Add append point for admin users edit

    ECOMMERCE-4797
    Eric Pigeon


Workarea 3.0.6 (2017-06-07)
--------------------------------------------------------------------------------

*   Handle region name properly for addresses with regionless countries

    ECOMMERCE-4748
    Matt Duffy

*   Fix asynchronous adding to cart

    On a detail page, adding something to your cart can disappear under the
    following situation:
    * no current order
    * switch SKU, XHR request for new details starts
    * click add to cart, XHR request to add starts
    * add to cart XHR returns with new cookie with order_id
    * first XHR request for new details returns with old cookie w/o order_id
    * current_order disappears

    Although we will never be able to guarantee a solution to this, these
    changes should help mitigate:
    * disable session on HTTP caching pages (we don't want session touched
      during these requests anyways)
    * disable inputs/buttons when SKU is changed
    * show loading indictor waiting for the product details request to
      return

    ECOMMERCE-4678
    Ben Crouse

*   Ensure country select get populated correctly

    ECOMMERCE-4748
    Matt Duffy

*   Ensure mobile navigation loads content for leaf taxons if present

    ECOMMERCE-4664
    Matt Duffy

*   Fix saved addresses functionality

    When choosing a saved address for a user's shipping or billing address
    the Country & Region selects were not being set properly.

    This commit also removes the requirement from the hidden region field,
    since that field is now only shown under the very specific use-case;
    where a user selects a regionless country.

    ECOMMERCE-4761
    Curt Howard

*   Fix same day queries in the admin

    Somewhat API-breaking, but none of the v3.x builds have touched these
    files, so it seems safe to do in a patch.

    ECOMMERCE-4422
    Ben Crouse

*   Fix Workarea.with_config in system tests

    Since Capybara runs its server in a separate thread, don't use thread
    variable to fix this with system tests.

    ECOMMERCE-4774
    Ben Crouse

*   Override Address#to_json to simplify country output for json data

    ECOMMERCE-4748
    Matt Duffy

*   Fix path to the dialog's error JST template

    ECOMMERCE-4766
    Curt Howard

*   Fix fulfillment event display and clean up fulfillment API

    This is slightly breaking, but without these changes fulfillment
    quantities will show incorrectly when different kinds of events happen
    on the same item.

    ECOMMERCE-4758
    Ben Crouse

*   Require test/support files from plugins

    Allows plugins to customize/decorate test setup when tests are run in
    host apps.

    ECOMMERCE-4762
    Ben Crouse

*   Properly disable Feature.js tests in test environment

    Due to a race condition, the previous way we were removing the
    Feature.js classes from the root HTML element was not working
    consistently. This was due to a straight port over from the way
    we handled it for Modernizr.

    To avoid this we have rearranged the load order of the scripts
    called in Storefront's `head.js.erb` manifest. Now we load the
    Feature.js library, then the spec helper, then the Feature.js
    method which applies the classes.

    The spec helpers job is still to disable these tests and, due to
    the reorganization, this now works properly and consistently.

    ECOMMERCE-4760
    Curt Howard

*   Prevent feature.js from detecting test driver as a touch device

    This will disable the touch feature and prevent the class from being added to the DOM when running tests
    ECOMMERCE-4760
    Dave Barnow

*   Remove rule fields from discount template

    The properties template generated html for fields not on a
    generated discount. Removing them prevents errors being thrown
    in the application when used unmodified.

    ECOMMERCE-4754
    Matt Duffy

*   Rework TestCase::Worker to properly preserve worker state between tests

    ECOMMERCE-4734
    Matt Duffy


Workarea 3.0.5 (2017-05-26)
--------------------------------------------------------------------------------

*   Fix AJAX product detail SKU select functionality

    This functionality was broken due to a poorly constructed DOM query.

    ECOMMERCE-4756
    Curt Howard

*   Add VCR support

    This implementation allows cassette overriding.

    ECOMMERCE-4726
    Ben Crouse

*   Add image-group-content-block style guide

    ECOMMERCE-4702
    Curt Howard

*   Fix Image Group content blocks

    The initial implementation of the Image Group was meant to reflow as
    users removed images from the series, always centering the last image if
    the count was odd. At some point this stopped working as intended.

    This commit simplifies the implementation in order to achieve the
    desired result.

    ECOMMERCE-4733
    Curt Howard

*   Don't render activity headers for blank pages

    A little bit of a hack to improve display of activity timeline to not
    show a day header if there are no displyable entries for that day.

    ECOMMERCE-4555
    Ben Crouse

*   Fix user activity updates not updating timestamps

    This causes 304 responses with stale data for recent views requests.

    ECOMMERCE-4484
    Ben Crouse

*   Update discount generator to use append point

    An append point was added during the select type of creating a discount
    so there is no need for a custom discount to fully overwrite the view.
    Update the generator to create a partial and add it to the append point.

    ECOMMERCE-4744
    Eric Pigeon

*   Position imports tooltips to prevent cutoff from header

    ECOMMERCE-4546
    Matt Duffy

*   Fix admin card icon helper method to be consistent with storefront helper

    ECOMMERCE-4730
    Matt Duffy

*   Clean up email templates

    ECOMMERCE-4585
    Matt Duffy

*   Fix CSS selectors for image-based content blocks

    `.image-content-block` and `.image-and-text-content-block` both had link
    elements that wrapped their images. The classes were changed in
    ECOMMERCE-4673 but the CSS files were not updated.

    ECOMMERCE-4704
    Curt Howard

*   Add missing Storefront content-block style guides

    - Adds divider-content-block style guide
    - Adds html-content-block style guide
    - Adds image-and-text-content-block style guide
    - Adds product-list-content-block style guide
    - Adds social-network-content-block style guide
    - Adds taxonomy-content-block style guide
    - Adds text-content-block style guide
    - Adds video-content-block style guide
    - Adds personalized-recommendations-content-block style guide
    - Adds video-and-text-content-block style guide

    ECOMMERCE-4702
    Curt Howard

*   Fix file extension for taxonomy content blocks

    One, two, and three column content block partials now properly contain
    `.html` as part of their file extension chain.

    ECOMMERCE-4742
    Curt Howard

*   Remove heading elements from content blocks

    Enforcing an actual `%h2` element in the view can disrupt the flow of
    the document in addition to forcing an SI to override both the component
    and the view in order to make changes.

    - Stub out missing elements from `category-summary-content-block`
    component.

    ECOMMERCE-4741
    Curt Howard

*   Fix pages displayed in the wrong order

    Sometimes, the pagination test fails due to changes in timing of AJAX
    calls for responses. Don't use the promise's .done method because
    there's no guarantee they will be run in order.

    ECOMMERCE-4739
    Ben Crouse

*   Remove unused taxonomy-content-block__container modifier

    `taxonomy-content-block__container--image` was unreferenced in the
    codebase. This relic has been removed.

    ECOMMERCE-4740
    Curt Howard

*   Allow up to 3 tenders on the order tender card

    ECOMMERCE-4736
    Dave Barnow

*   Remove referenced navigation content block partial

    ECOMMERCE-4701
    Curt Howard

*   Make all releasable models' index status based on model active field

    ECOMMERCE-4608
    Matt Duffy

*   Remove items for inactive variants from cart

    ECOMMERCE-4082
    Matt Duffy

*   Make test more reliable

    ECOMMERCE-4689
    Ben Crouse

*   Create append point for utility navigation

    This allows implementers to append links to the utility navigation

    ECOMMERCE-4710
    Dave Barnow

*   Change text-box—mini to text-box—small

    ECOMMERCE-4718
    Dave Barnow


Workarea 3.0.4 (2017-05-16)
--------------------------------------------------------------------------------

*   Fix test when running from gem

    Ben Crouse

*   Handle passing request params to catalog customizations properly
    and fix checkout summary view

    Matt Duffy

*   Require plugin factories in test_help

    Plugins factories need to be autorequired from core so host
    apps can install them and run their tests.

    ECOMMERCE-4705
    Eric Pigeon


Workarea 3.0.3 (2017-05-15)
--------------------------------------------------------------------------------

*   Handle when all models in discount rules are deleted

    When all the models associated in a discount are deleted
    and call name on nil class.  Return from the function when
    no models are returned

    ECOMMERCE-4699
    Eric Pigeon

*   Allow skipping the CI reporters if desired

    This allows us to do custom reporters for the base gems CI

    ECOMMERCE-4689
    Ben Crouse

*   Add minitest reporters for automatic CI setup

    1) No need to make every build do this
    2) Allow easier CI for testing app/plugin templates

    ECOMMERCE-4689
    Ben Crouse

*   Clean up and improvements on custom paths for gems in app template

    ECOMMERCE-4689
    Ben Crouse

*   Allow Ruby 2.4 and bump necessary gems

    Ruby 2.4 fixes the mysterious segfaulting that occurs in the development
    environment.

    ECOMMERCE-4594
    Ben Crouse

*   replace `.value` with `.property` in the core reveal_password module.  `.value` has been removed from the admin, so it’s no longer safe to rely that is always exists.

    ECOMMERCE-4648
    Jessica Barnett

*   Skip test if using an alpha Elasticsearch version

    ECOMMERCE-4689
    Ben Crouse

*   Remove unnecessary testing that fails in CI

    ECOMMERCE-4689
    Ben Crouse


Workarea 3.0.2 (2017-05-10)
--------------------------------------------------------------------------------

*   Align test class names with file names

    ECOMMERCE-4696
    Matt Duffy

*   Add append point for adding custom discounts to setup page

    ECOMMERCE-4695
    Eric Pigeon

*   Override inline_svg helper for specific content block use case

    Create a `content_block_icon` helper modeled after `inline_svg` to
    better control the error state. This allows us to default a content
    block icon to a placehoder SVG.

    ECOMMERCE-4665
    Curt Howard

*   Remove rpsec directory

    ECOMMERCE-4690
    Matt Duffy

*   Remove the grid component from taxonomy-content-blocks

    An oversight in early content block development for v3.0.0 left the
    `taxonomy-content-block` component reliant on the `grid` component.
    The `grid` component is difficult to style contextually in this case,
    as a the content block can be used in the primary or mobile nav.

    Now the `taxonomy-content-block` manages it's own layout, making it's
    layout much simpler to override, based on it's parent component.

    ECOMMERCE-4673
    Curt Howard

*   Improve note on shipping services region field

    ECOMMERCE-4577
    Ben Crouse

*   Add %ul element to .social-networks-content-block

    The markup in the social networks content block was malformed. The
    component should have been a %ul all along.

    ECOMMERCE-4682
    Curt Howard

*   Realign secondary-nav component

    The `secondary-nav` component was out of sync with it's usage in
    the left navigation partial.

    ECOMMERCE-4672
    Curt Howard

*   Fix bugs with plugin template

    Fixes bad require and syntax in the Rakefile

    ECOMMERCE-4666
    Ben Crouse

*   Fix generator tests in host apps, and allow decoration

    ECOMMERCE-4662
    Ben Crouse

*   Stop analytics callbacks from being fired by Admins

    All analytics adapters are now suppressed for Admin users in an attempt to cut
    down on inaccurate data being transmitted to 3rd Party services. This change
    will better support the tracking of Customer data, without any noise from an
    Admin user who may be navigating around the site.

    ECOMMERCE-4681
    Curt Howard

*   Refactor plugin template

    - Organize template contents logically to ease maintainability
    - Add a Rake task to automatically generate Changelogs

    ECOMMERCE-4666
    Curt Howard

*   Remove memoization in Sidekiq::CallbacksWorker

    This memoization got in the way when decorating CallbacksWorkers.
    Ex:
    decorated do
      sidekiq_options(enqueue_on: enqueue_on.merge(Review => :create))
    end

    wouldn't actually add anything to enqueue_on since it gets memoized
    before the new options are added.

    ECOMMERCE-4675
    Eric Pigeon

*   Updates gsub to only swap out file extensions

    The gsub method for finding and running decorated test was swapping out
    the file name as well if it contained the string 'decorator' (i.e
    decorator_generator_test.rb).  The new gsub pattern is exclusive to
    subbing file extensions only.

    ECOMMERCE-4676
    Jordan Stewart

*   Update product search index rake task to account for no products

    ECOMMERCE-4663
    Matt Duffy

*   Remove global focus-ring footprint

    ECOMMERCE-4668
    Curt Howard

*   Improve Webmock configuration to match Workarea configuration

    Allow connecting to all major services

    ECOMMERCE-4631
    Ben Crouse

*   Fix bug loading non-existent decorator files

    ECOMMERCE-4667
    Ben Crouse

*   Fix test class/file name mismatch

    ECOMMERCE-4660
    Ben Crouse

*   Fix visual presentation of releases on release calendar when overlapping.

    ECOMMERCE-4368
    Fixes: ECOMMERCE-4368

    Fix var
    F.M. Bonnevier

*   Dynamically build list of payment icons to allow plugins to easily add new ones

    ECOMMERCE-4656
    Beresford, Jake


Workarea 3.0.1 (2017-04-26)
--------------------------------------------------------------------------------

*   Fix pinging to homebase

    ECOMMERCE-4651
    Ben Crouse

*   Close takevoers on turbolinks:before-cache

    Before a page is cached by Turbolinks any takeovers must be destroyed. This avoids issues where the takeover will persist when a user navigates back through history.

    ECOMMERCE-4627
    Curt Howard

*   Raise error when running test:decorated when original can't be found

    If a test decoration couldn't be found when running test:decorated it
    would just pass over the decoration and pass.  If the test decoration is
    misnamed we should raise an error and help the developer resolve the
    problem.

    ECOMMERCE-4642
    Eric Pigeon

*   Add color-picker-field component to admin styleguide

    ECOMMERCE-4634
    Beresford, Jake

*   Track factory inclusions for plugins

    Factories is included in the tests case super classes set up in the work
    area testing gem, at that point plugin factories haven't beed inlcuded
    and added with Factory.add and weren't available for us in tests.
    Change Workarea::Factory to track what includes it so future calls to
    .add will get included to the test cases.

    ECOMMERCE-4632
    Eric Pigeon

*   Fix bug when adding product images with options, filtering on storefront

    ECOMMERCE-4638
    Dave Barnow

*   Disable autocomplete on admin user/edit pages

    ECOMMERCE-4119
    Jessica Barnett

*   Update credit_card_issuers configuration to exclude bogus card type in production environment.

    ECOMMERCE-4615
    Beresford, Jake

*   Move javascript tests from spec/ to test/

    In an effort to move more code out of the `spec/` dir, all
    `spec/javascripts` dirs have been renamed to `test/javascripts`. Neither
    the tests nor the `spec_helper` have been renamed for now.

    ECOMMERCE-4540
    Tom Scott

*   Add model to validation_error_analytics_data with 0 arguments

    ECOMMERCE-4623
    Beresford, Jake

*   * Update implementation to use reduce for all_payment_icons
    * added .systemize to issuer in string interpolation

    ECOMMERCE-4615
    Beresford, Jake

*   Allow data to be passed to Content Fields so that they can be enhanced with JS

    ECOMMERCE-4624
    Beresford, Jake

*   Fix plugin generation

    Updates for v3.0 and fixes test-running tasks from within the plugin
    repo.

    ECOMMERCE-4628
    Ben Crouse

*   Fix test failure/error output commands to be accurate

    Also, add text to help guide developers trying to run tests in
    decorators.

    ECOMMERCE-4566
    Ben Crouse

*   Updated card icon logic again so that it actually works.

    * Renamed diners club icon to match optionized name
    * Add helper method to render all payment icons

    ECOMMERCE-4615
    Beresford, Jake

*   Workarea must be included before Rails.env is set

    This causes all kinds of failures and problems with tests and isn't
    respecting test env configuration

    ECOMMERCE-4629
    Ben Crouse

*   Add translations to admin application layout

    ECOMMERCE-4591
    Dave Barnow

*   Adjust z-indexes to prevent browsing controls showing in front of tooltips

    ECOMMERCE-4622
    Beresford, Jake

*   Change email banner image to workarea logo, adjust admin email template logo

    ECOMMERCE-4582
    Dave Barnow

*   Fix translation on admin WYSIWYG toolbar

    ECOMMERCE-4620
    Beresford, Jake

*   Use display block instead of extending hidden for tabs.

    Hidden class has a high specificity due to use of !important, this prevents the inline  display: block added by JS from working

    ECOMMERCE-4621
    Beresford, Jake

*   Add styles for color content field

    * Style the color picker a little
    * Add the ability to pass presets to the color field so that brands can easily use their brand colors
    * Added a helper method to create picker ID to prevent color picker preset list ID collision

    ECOMMERCE-4619
    Beresford, Jake

*   Remove inline-list mixin

    - the only benefit of inline-list is that it adds display: inline-block; to the child LI elements. However, this adds specificity that doesn’t help when it comes to working with a responsive site.

    Remove left over icon in style_guides.scss
    Remove quotes for san-serif in style_guides.html.haml’s font-family key value.

    ECOMMERCE-3330
    Steve Perks

*   Remove .js prefixes conditionals from admin

    We require JS for the admin to function, but due to habit kept adding .js and .hidden-if-js-enabled selectors throughout the admin. Removing them helps with maintenance.

    ECOMMERCE-4589
    Steve Perks

*   Prevent error due to empty payload when firing validationError analytics event

    ECOMMERCE-4617
    Beresford, Jake

*   Fix implementation of card icons

    CreditCard.issuer value is not config key, need to lookup icons by config value then use the key to build out the icon name.

    * Optimized SVGs
    * Removed SVGs fro payment types not supported OOTB
    * Ensure all payment icon names match config.credit_card_issuers keys
    * Updated data-card & payment-icon styleguide views

    ECOMMERCE-4615
    Beresford, Jake

*   Remove unnecessary interpolation

    ECOMMERCE-4616
    Dave Barnow

*   Add destroy method to wysiwyg for turbolinks

    ECOMMERCE-4604
    Beresford, Jake

*   Add selected state styles to WYSIWYG toolbar

    * Add class and styles to toolbar icons for active state styling
    * Updated references to wysihtml5

    ECOMMERCE-4586
    Beresford, Jake

*   z-index layer variables

    ECOMMERCE-3816
    Steve Perks

*   Move Dropzones above browsing-controls UI

    ECOMMERCE-4533
    Curt Howard

*   Removes dialog.js and associated styles from admin

    * Moves dialog modules from core into storefront
    * Moves loading module from core into storefront
    * Moves dialog config into storefront
    * Moves dialog teaspoon tests into storefront
    * Create a copy of the loading template in admin for use by other modules
    * Updated workarea override usage documentation

    ECOMMERCE-4587
    Beresford, Jake

*   Add border above content editor in navigation

    When no-content and no content controls a top border is needed.

    ECOMMERCE-4434
    Beresford, Jake

*   Fix jQuery UI Dialog close button icon

    ECOMMERCE-4592
    Curt Howard

*   Prevent clicks on style dropdown in WYSIWYG toolbar

    * Updated a missing translation
    * Use inline_svg instead of including the raw SVG code
    * Change icon size per Dave Barnow's request
    * Added an icon for html button in wysiwyg toolbar
    * optimize wysiwyg icon SVGs

    ECOMMERCE-4587
    Beresford, Jake

*   Make page-messages appear above admin-toolbar

    ECOMMERCE-4584
    Curt Howard

*   Load and immediately invoke Feature.js

    Previously `feature.testAll` was being invoked too late in the game, causing a content flash

    ECOMMERCE-4579
    Curt Howard

*   Move Workarea logo from bottom to top of takeover

    ECOMMERCE-4532
    Curt Howard

*   Gracefully handle long names on timeline cards

    ECOMMERCE-4366
    Curt Howard

*   Add navigation to Style Guide indexes

    ECOMMERCE-3807
    Curt Howard

*   Live searches not rendering correctly

    Changed display: block to display: table-cell when JS is enabled.

    ECOMMERCE-4583
    Steve Perks

*   Fix styling for Reactivate Discount UI

    - Adds `button--destroy` modifier to the admin
    - Adds `$bright-red` as a color to the admin

    ECOMMERCE-4159
    Curt Howard

*   Guard against change + input event chain for number inputs

    Chrome fires `change` events on mousemove when a user is interacting with the browser-supplied arrow UI on number fields, which is super weird and causes `WORKAREA.formSubmittingControls` to fire early and erratically. Guarding against the `change` event, specifically for inputs of type `number` fixes the issue.

    ECOMMERCE-4080
    Curt Howard


Workarea 3.0.0 (2017-04-07)
--------------------------------------------------------------------------------

*   Add missing page title translations

    no changelog
    ECOMMERCE-4578
    Dave Barnow

*   Finish style guide cleanup

    ECOMMERCE-4511
    Curt Howard

*   Normalize locale file

    no changelog
    ECOMMERCE-4525
    Dave Barnow

*   Titleize workflow bar buttons, put them in a more descriptive namespace

    NO CHANGELOG
    ECOMMERCE-4538
    Dave Barnow

*   Add placeholder image

    ECOMMERCE-3975
    Curt Howard

*   Clean up default asset directories

    ECOMMERCE-3975
    Curt Howard

*   Fix non-number inputs to price rules

    ECOMMERCE-4514
    Ben Crouse

*   Remove arrows from locale file

    no changelog
    ECOMMERCE-4522
    Ben Crouse

*   Add help tooltips to categorization page

    ECOMMERCE-4369
    Ben Crouse

*   Fix credit card icons when Sprockets isn't running

    Sprockets isn't running in staging or production for performance.

    ECOMMERCE-4295
    Ben Crouse

*   Upgrade jQuery to v3.2.0 & jQuery UI to 1.12.1

    ECOMMERCE-2779
    Curt Howard

*   Upgrade Lodash to v4.17.4

    See this link for more information: https://github.com/lodash/lodash/wiki/Changelog#v400

    ECOMMERCE-2779
    Curt Howard

*   Remove forced eager loading

    I believe most cases we depending on this have been fixed. If it causes
    problems, we can add it back in a patch.

    ECOMMERCE-4573
    Ben Crouse

*   Handle blank release name gracefully when creating release on workflow publish step

    ECOMMERCE-4397
    Matt Duffy

*   Correct persistence of pricing sku form data

    ECOMMERCE-4173
    Matt Duffy

*   Inject authenticity_token into every Ajax request

    To make sure all ajax calls from here on out are passing a CSRF
    token back to Rails (even if we don't currently `protect_from_forgery`
    on that request), we're now injecting the `X-CSRF-Token` header into all
    `jQuery.ajax` requests before they are sent. This allows developers to
    continue making Ajax requests and JS modules without needing to think
    about passing the CSRF token all the time.

    It also undoes a change that I made which only solved the problem for a
    single request. This solution can be credited to @sstaub, because she
    implemented it on Olympia and happened to notice that Shades of Light
    was also having the same problem.

    We used the following as a guide to creating this module: http://excid3.com/blog/rails-tip-2-include-csrf-token-with-every-ajax-request

    ECOMMERCE-4373
    Tom Scott

*   Ensure dynmaic mappings in ES

    dynamic templates don't create mappings until a document is indexed with
    a non null field.  After creating the index index and delete a null
    product to ensure the mappings exists for categories.

    ECOMMERCE-4569
    Eric Pigeon

*   Remove gsub of bin/rails in plugins

    As of Rails 5.0.2, there is no more `bin/rails` when a `rails plugin` is
    generated. We no longer need the `gsub_file` calls currently in the
    plugin template as a fix for rails 4.x plugin generation, and removing
    it allows the plugin to generate successfully.

    ECOMMERCE-4568
    Tom Scott

*   Remove background: true from indexes

    This was recommended by the consultant from MongoDB

    ECOMMERCE-4567
    Ben Crouse

*   Return Unique set of style guide partials

    Style guide partials can come from several places and can be overridden
    in a host app.  This inadvertently caused the helper to concat all
    partial paths instead of returning the unique'd list of partials to be
    rendered.

    For example, a host app that overrode store front's
    color_pallete/_grays.html.haml partial would see gray rendered twice
    when they viewed style guide in their browser

    This change now respects overridden files and ensures files aren't
    duplicated when rendered.

    ECOMMERCE-4558
    Jordan Stewart

*   Fix test decoration when packaged as a gem

    ECOMMERCE-4565
    Ben Crouse

*   Remove product_id field from FreeGift discount

    persisting the id of the product is no longer needed now that the
    product attributes are merged into the order item when added to
    a user's cart.

    ECOMMERCE-4305
    Matt Duffy


Workarea 3.0.0.beta.2 (2017-04-06)
--------------------------------------------------------------------------------

*   Make static accessors into configuration options

    This allows easier customization and one spot for configuration.

    ECOMMERCE-4560
    Ben Crouse

*   Render important tender information instead of tender partial in order cards

    * Prevents the tender always overflowing the card height
    * Adds card icons to tenders
    * Simplify the display of tender data
    * Tenders are items in a list, not tables of data
    * Implement SVG payment icons for storefront

    ECOMMERCE-4295
    Beresford, Jake

*   Allow multiple regions to be specified for a single shipping service

    ECOMMERCE-4548
    Matt Duffy

*   Don't save release on audit log entry if the audited isn't releasable

    ECOMMERCE-4553
    Ben Crouse

*   change wysihtml dependency to 0.6.x

    ECOMMERCE-2747
    Beresford, Jake

*   Expose region field for shipping services in the admin

    ECOMMERCE-4548
    Matt Duffy

*   Fix issue with managing releasable changesets when reverting changes

    ECOMMERCE-4550
    Matt Duffy

*   Upgrade WYSIWYG to latest version

    * Update asset_pickers.js to return full asset
    * populate url in optional field for asset pickers
    * Use data attribute to target wysiwyg js
    * Removes separate templates for wysiwyg link toolbar UI
    * Adds underline to wysiwyg toolbar
    * Adds style selection dropdown to WYSIWYG toolbar
    * Update wysiwyg toolbar with inline SVG
    * Improve layout of link insert UI - no more dialog

    ECOMMERCE-2747
    Beresford, Jake

*   Fix inequality product rules

    ECOMMERCE-4542
    Ben Crouse

*   Fix references to gems.workarea.com

    ECOMMERCE-4509
    Ben Crouse

*   Rename "Store Front" to Storefront

    ECOMMERCE-4509
    Ben Crouse

*   Rename Weblinc to Workarea

    ECOMMERCE-4509
    Ben Crouse

*   Allow navigables that don't respond to #active?

    ECOMMERCE-4517
    Ben Crouse

*   Move flash_messages to their respective controller

    ECOMMERCE-4545
    Benjamin Crouse

*   update email templates to haml

    ECOMMERCE-2886
    Steve Perks

*   Drop Modernizr in favor of Feature.js

    ECOMMERCE-3815
    F.M. Bonnevier

*   Remove icon font in favor of SVGs

    Icon fonts have been a bear for many implementations. By universally
    using the `inline_svg` helper we've been able to reduce our dependency
    on them in favor of SVG images in the view layer.

    For the Stylesheet layer a new mixin has been created called `svg`. This
    mixin offers similar functionality to the previous `icon` mixin, but is
    significantly smaller and easier to understand.

    There is a slight distinction, in the filesystem, between regulard SVGs
    and SVGs that are intended to be used as icons.

    1. Icon SVG images live at the load path
    `weblinc/ENGINE/icons/NAME.svg`. They are intended to have no `fill`
    attribute applied to their markup, allowing the `inline_svg` helper to
    provide a class that style's the `fill` property of the image.
    2. All other SVGs behave as normal, containing whatever colors are
    needed for their appropriate presentation. Their load path is typically
    in the root image directory for the engine.

    ECOMMERCE-2696
    Curt Howard

*   Remove todo thats not being done.

    ECOMMERCE-4312
    Matt Duffy

*   Remove enforce host check for health check user agent

    ECOMMERCE-4300
    Matt Duffy

*   Improve output of rules summary for generic (filter-based rules)

    ECOMMERCE-4544
    Ben Crouse

*   Consolidate store front code into core

    Since these three gems are coupled together anyways, have a single
    location for browsing reduces finding time.

    ECOMMERCE-4543
    Ben Crouse

*   Consolidate admin code into core

    ECOMMERCE-4541
    Ben Crouse

*   Move admin initializers into core

    ECOMMERCE-4541
    Ben Crouse

*   Correct discount item quantity condition behavior

    Require the item quantity condition to be only met on
    items that are otherwise qualified by other conditions of
    the discount (matches product, category, attributes) to
    prevent scenarios where the discount gets applied incorrectly

    ECOMMERCE-3557
    Matt Duffy

*   SASS Tools cleanup

    Remove math_helpers, px-to-percent and strip-unit helpers.

    ECOMMERCE-3351 (+1 squashed commit)
    Squashed commits:
    [065f1f0] SASS Tools cleanup

    Remove math_helpers, px-to-percent and strip-unit helpers.

    ECOMMERCE-3351
    Steve Perks

*   Dasherize breakpoint classes

    ECOMMERCE-4268
    Beresford, Jake

*   Add border to images in .help-article

    ECOMMERCE-4530
    Beresford, Jake

*   Update styling for .summary inactive state

    * Remove red dot, add opacity and 'inactive' text to .summary__info

    ECOMMERCE-4493
    Beresford, Jake

*   Fix dialog_spec.js after message module was moved to engines

    ECOMMERCE-4539
    Curt Howard

*   Consolidate admin code into core

    Since these three gems are coupled together anyways, have a single
    location for browsing models/services/queries reduces finding time.

    ECOMMERCE-4541
    Ben Crouse

*   Remove unused extra admin user internationlization keys

    ECOMMERCE-4056
    Eric Pigeon

*   Improve performance of Elasticsearch model serialization

    This is a big help for browse pages for products with lots of variants.

    ECOMMERCE-4527
    Ben Crouse

*   Extract decoration to its own gem

    ECOMMERCE-4536
    Ben Crouse

*   Add data attribute support to toggle_button helper

    ECOMMERCE-4501 (+1 squashed commit)
    Squashed commits:
    [3d35476] Add data attribute support to toggle_button helper

    ECOMMERCE-4501
    Steve Perks

*   Remove quick view pattern from store_front and all related configuration

    ECOMMERCE-3510
    Jordan Stewart

*   remove extra catalog categories internationalization keys

    ECOMMERCE-3992
    Eric Pigeon

*   Move mongoid index to module that defined field being indexed

    ECOMMERCE-4534
    Matt Duffy

*   Fix admin catalog product / catalog product images internationalization

    ECOMMERCE-3994
    Eric Pigeon

*   Remove unneeded method in Shipping

    ECOMMERCE-4310
    Matt Duffy

*   Remove configurable decorator order enforcement

    ECOMMERCE-4325
    Matt Duffy

*   Condense checkout touch into a Order method

    ECOMMERCE-4337
    Matt Duffy

*   Add script for renaming

    To move files and edit code for substitutions

    ECOMMERCE-4509
    Ben Crouse

*   Rework use of categorization in Product and OrderItem view model

    ECOMMERCE-4338
    ECOMMERCE-4339
    Matt Duffy

*   Improve category rule management UI

    Adds custom UIs for each rule type

    ECOMMERCE-4510
    Ben Crouse

*   Remove discount collection cache

    the cache was moved up to application groups so caching the discount
    collection doesn't provide any benefit or use.

    ECOMMERCE-4516
    Eric Pigeon

*   Localize discounts

    ECOMMERCE-4036
    Ben Crouse

*   Add internationalization for admin mailers

    ECOMMERCE-4529
    Matt Duffy

*   Add internationalization for admin helpers

    ECOMMERCE-4529
    Matt Duffy

*   Internationalize admin create pricing discounts

    ECOMMERCE-4015
    Eric Pigeon

*   ECOMMERCE-4017: Translation values for admin dashboards.
    Joseph Hughes

*   Add internationalization for admin view models

    ECOMMERCE-4521
    Matt Duffy

*   ECOMMERCE-4000: Include translations for comments index and edit views
    Ashley Chapokas

*   Translate admin bulk action product edits views

    ECOMMERCE-4519
    Matt Duffy

*   Move admin jquery validate messages to core with other validation messages

    ECOMMERCE-4498
    Beresford, Jake

*   Internationalization for js modules and templates.

    * remove 2 redundant JS files
    * improve layout of wysiwyg link popup

    ECOMMERCE-4498
    Beresford, Jake

*   Remove links from details/images step of Create Catalog Products workflow

    This got kicked back from QA, regression on the workflow bar links.
    Removed linking on the workflow bar for the details & images step.

    ECOMMERCE-4013
    Tom Scott

*   ECOMMERCE-4032: Include payment translations
    Ashley Chapokas

*   Translate admin pricing discount code list views

    ECOMMERCE-4035
    Matt Duffy

*   Translate admin comment mailer views

    Translations for the admin comment mailer notify message

    ECOMMERCE-3999
    Tom Scott

*   Correct sorting logic for admin discounts

    ECOMMERCE-4515
    Matt Duffy

*   Add query class to handle display of select items for a bulk action

    ECOMMERCE-4503
    Matt Duffy

*   Translate "Create Product" workflow

    Translations for the create_catalog_products views. Mostly using i15r,
    but added in some human touches when necessary (and when i15r didn't
    catch things, like the `:confirm` dialog text and `@page_title`)

    ECOMMERCE-4013
    Tom Scott

*   Internationalize admin recommendations

    ECOMMERCE-4040
    Eric Pigeon

*   Aligns export changes with bulk action js changes

    ECOMMERCE-4383
    Matt Duffy

*   Internationalize admin search customizations

    ECOMMERCE-4043
    Eric Pigeon

*   Fix bad merge

    ECOMMERCE-4014
    Jeff Yucis

*   Translate yes/no on navigation view. Remove extranous translations

    ECOMMERCE-4014
    Jeff Yucis

*   Rename jump_to_menu_fields to categorized_autocomplete_fields

    ECOMMERCE-4283
    Beresford, Jake

*   Translate admin search settings views

    ECOMMERCE-4044
    Matt Duffy

*   ECOMMERCE-4046: Translation values for shared admin partials.
    Joseph Hughes

*   Translate admin payment transaction views

    ECOMMERCE-4031
    Matt Duffy

*   Translate admin order views

    ECOMMERCE-4030
    Matt Duffy

*   Clean up and translate weblinc sorts

    ECOMMERCE-4260
    Matt Duffy

*   Fix bulk actions recall/destroy state when navigating away

    ECOMMERCE-4506
    Curt Howard

*   Swap bulk actions select all button on destroy

    ECOMMERCE-4505
    Curt Howard

*   Fix typo in bulk actions recall

    Allows excluded summaries to be deselected properly.

    ECOMMERCE-4504
    Curt Howard

*   Fix bulk actions destroy method

    ECOMMERCE-4502
    Curt Howard

*   Translate admin shipping services views

    ECOMMERCE-4047
    Matt Duffy

*   Translate admin featured products views

    ECOMMERCE-4020
    Matt Duffy

*   Add release creatables to create_release workflow plan step

    ECOMMERCE-4263
    Beresford, Jake

*   Move 'admin.page_header' append point

    * Rename old append point to 'admin.user_menu'
    * Remove link to beta feedback survey from admin

    ECOMMERCE-4294
    Beresford, Jake

*   Use class selector instead of element selector for workflow-bar__step

    ECOMMERCE-4285
    Beresford, Jake

*   Translate admin export and status report mailers

    ECOMMERCE-4049
    ECOMMERCE-4018
    Matt Duffy

*   Admin translations for releases views

    ECOMMERCE-4042
    Beresford, Jake

*   Translate admin import catalogs views

    ECOMMERCE-4024
    Matt Duffy

*   ECOMMERCE-4048: Translation values for shippings.
    Joseph Hughes

*   Add translation for content block visibility pseudo selector

    ECOMMERCE-4365
    Curt Howard

*   Fix failing tests relating to help translations

    ECOMMERCE-4023
    Beresford, Jake

*   Admin translations for help_assets

    ECOMMERCE-4023
    Beresford, Jake

*   Admin translations for help

    ECOMMERCE-4022
    Beresford, Jake

*   Translate admin activity

    ECOMMERCE-3990
    Ben Crouse

*   Internationalize admin inventory skus

    ECOMMERCE-4025
    Eric Pigeon

*   Fixes translation related test failure

    ECOMMERCE-4034
    Beresford, Jake

*   Admin translations for create_release

    ECOMMERCE-4016
    Beresford, Jake

*   Move message from core to store front and admin

    * Allows store_front to style and animate flash messaging without changing admin's behavior.
    * Transition/animation the message with css rather than a JS config preventing us from overriding the JS for more advanced styles / behaviors.

    ECOMMERCE-4481
    Steve Perks

*   Admin internationalization for pricing

    ECOMMERCE-4034
    Beresford, Jake

*   Translate admin user views, update bulk user bulk export markup

    ECOMMERCE-4056
    Matt Duffy

*   Admin translations for navigation taxons

    ECOMMERCE-4028
    Beresford, Jake

*   Internationalize admin catalog variants

    ECOMMERCE-3995
    Eric Pigeon

*   Admin translations for navigation redirects

    ECOMMERCE-4027
    Beresford, Jake

*   Update to match view path

    ECOMMERCE-4021
    Beresford, Jake

*   Admin translations for fulfillments

    ECOMMERCE-4021
    Beresford, Jake

*   Translate admin Tax Imports views

    ECOMMERCE-4052
    Matt Duffy

*   Admin translations for facets

    ECOMMERCE-4019
    Beresford, Jake

*   Allow click on primary navigation nodes

    * Adds option allow_click to tooltip module
    * Add test for switching between selected menus

    ECOMMERCE-4461
    Beresford, Jake

*   Admin translations for navigation_menus

    ECOMMERCE-4026
    Beresford, Jake

*   Translate admin Tax Rate views

    ECOMMERCE-4053
    Matt Duffy

*   Translate admin tax_category views

    ECOMMERCE-4051
    Matt Duffy

*   Rewrite Bulk Actions

    Bulk Update needed to be renamed to Bulk Actions in order to support
    multiple actions that can be performed on a group of objects in the
    system.

    It also required a rewrite because the original implementation was
    product-specific, whereas now any grouping of object may have actions
    associated with with the group.

    ECOMMERCE-3886
    Curt Howard

*   Update all tooltip forms for similar padding

    * Wrap AJAX requested forms in tooltip-content for layout consistency
    * Update markup for exports to avoid margin-bottom on %p tags
    * Reduce .property margin within tooltips

    ECOMMERCE-4424
    Beresford, Jake

*   Rework filter/facet relationship

    ECOMMERCE-4394
    Matt Duffy

*   Add pill display for creation date filter selections

    ECOMMERCE-4394
    Matt Duffy

*   Clean up Releasable

    ECOMMERCE-4298
    Ben Crouse

*   Clean up admin routes

    ECOMMERCE-4297
    Ben Crouse

*   Clean up audit log initializer

    ECOMMERCE-4296
    Ben Crouse

*   Move view model wrapping to more appropriate location

    ECOMMERCE-4293
    Ben Crouse

*   Move code in app/services to more descriptive locations

    ECOMMERCE-4485
    Ben Crouse

*   Internationalize admin catalog products

    ECOMMERCE-3994
    Eric Pigeon

*   Remove unneeded ReleasableViewModel from admin

    ECOMMERCE-4292
    Ben Crouse

*   Add payment view model

    ECOMMERCE-4291
    Ben Crouse

*   Remove redis namespacing

    Also sets up Redis config for persistence and cache separately.

    ECOMMERCE-4259
    Ben Crouse

*   Remove items missing price in the cart

    ECOMMERCE-3698
    Eric Pigeon

*   Add placeholder text to date inputs

    * clear date picker active state on datepicker_fields.js

    ECOMMERCE-4391
    Beresford, Jake

*   Increase thickness of global box shadow used on summaries

    ECOMMERCE-4469
    Beresford, Jake

*   Eliminate duplicates when displaying recent user activity

    ECOMMERCE-4476
    Matt Duffy

*   Remove old datepicker for turbolinks

    ECOMMERCE-4393
    Beresford, Jake

*   Allow ORing multiple values in a category rule

    Use commas to separate values, e.g.

    field -> Color
    operator -> Equals
    value -> Red, Green

    would give results that are Red or Green.

    ECOMMERCE-4474
    Ben Crouse

*   Image should not be required for 2 & 3 column taxonomy blocks

    ECOMMERCE-4465
    Beresford, Jake

*   Convert admin exports to use bulk action framework

    ECOMMERCE-4383
    Matt Duffy

*   Prevent primary nav tooltip opening under sticky header

    ECOMMERCE-4421
    Beresford, Jake

*   Further datepicker UI improvements

    * Add validation to date fields
    * Update calendar UI when date field changes
    * Adjust min-height
    * Expose testDateFormat method in date.js

    ECOMMERCE-4391
    Beresford, Jake

*   Add icon for new blocks, change CSS file to match other block names

    ECOMMERCE-4379
    Dave Barnow

*   Correct gemspec ruby version

    Hash#dig is new in ruby 2.3 and the app doesn't currently with 2.4

    ECOMMERCE-4470
    Eric Pigeon

*   Don't enqueue admin indexing for models that don't get indexed

    Improve performance and reduce job queue size

    ECOMMERCE-4433
    Ben Crouse

*   Add noindex tag to accessibility page

    Requested by Ali Pozielli from a SEER audit

    ECOMMERCE-4432
    Ben Crouse

*   Implement add/remove toggle when selecting featured products

    Brings more context to featured product selection and management.

    ECOMMERCE-4431
    Ben Crouse

*   Add logic to prevent datepickers being injected more than once per input

    ECOMMERCE-4393
    Beresford, Jake

*   Improve datetimepicker UI

    * Added space between calendar UI and susbmit button
    * Make date links round
    * Change styling of 'today' so it doesn't look selected
    * Fix alignment of next/prev links
    * Improve styling of month/year text

    ECOMMERCE-4391
    Beresford, Jake

*   Improve user activity performance

    Use Mongo's $push to elminate unnecessary queries

    ECOMMERCE-4425
    Ben Crouse

*   Improve UI of release planning

    * zero pad minutes
    * at the word 'at' to publish and release labels
    * move tags input below release datetime inputs

    ECOMMERCE-4392
    Beresford, Jake

*   Fix broken toggle-button for show_navigation on category edit

    ECOMMERCE-4405
    Beresford, Jake

*   Increase width of images step in create product workflow

    ECOMMERCE-4408
    Beresford, Jake

*   Change layout for payments/show to feel less cluttered

    ECOMMERCE-4410
    Beresford, Jake

*   Adds .decorator file extension to editorconfig

    ECOMMERCE-4419
    Dave Barnow

*   Add children to left hand secondary navigation

    ECOMMERCE-4418
    Beresford, Jake

*   Prevent date time picker wrapping to new line on publish step

    ECOMMERCE-4398
    Beresford, Jake

*   Admin catalog categories internationalization

    ECOMMERCE-3992
    Eric Pigeon

*   Tracks pageviews on turbolink loads

    ECOMMERCE-4387
    Dave Barnow

*   Add logic to only show filter_toggle button if there are more than 2 facets.

    ECOMMERCE-4407
    Beresford, Jake

*   Add active toggles to releasable forms

    expose activeness on releasable models, update store front to respect
    activeness

    ECOMMERCE-4091
    Eric Pigeon

*   Switch to views instead of clicks for product analytics

    This will result in a better picture, since customers can hit products
    from external links (emails, campaigns, etc)

    ECOMMERCE-4420
    Ben Crouse

*   Clean up and improve recommendations

      * Improve algorithm in certain places (uses Predictors prediction API)
      * Add more configuration for specifying the number of results
      * Simplify queries to eliminate code that won't run
      * Ensure there are always recommendations (no blank lists)
      * Convert specs to minitest

    ECOMMERCE-4395
    Ben Crouse

*   Remove condition to hide help if there are no help articles

    ECOMMERCE-4287
    Matt Duffy

*   Rewrite Store Front Pagination

    ECOMMERCE-3833
    Curt Howard

*   Update product activity partials

    ECOMMERCE-4409
    Matt Duffy

*   Only try to reload the model when its persisted during admin indexing

    ECOMMERCE-4406
    Matt Duffy

*   Upgrade Waypoints, use gem

    ECOMMERCE-3485
    Curt Howard

*   Add toggle display for release create on publish steps

    Release creation UI should only be shown when the 'With new release' checkbox is checked.

    ECOMMERCE-4384
    Beresford, Jake

*   All properties have margin unless they are --inline.

    ECOMMERCE-4237
    Beresford, Jake

*   Update layout of new and edit views using grid

    * Restrict width of forms using view__container--narrow
    * Use grid where appropriate to reduce length of forms and improve layout
    * Update some other, obscure show views
    * Update markup in all creation workflow views
    * Added asset preview to content_assets edit view

    ECOMMERCE-4237
    Beresford, Jake

*   Break out translations by view

    ECOMMERCE-4014
    Jeff Yucis

*   Move interpolation to translation file

    ECOMMERCE-4014
    Jeff Yucis

*   Translate create content pages directory

    ECOMMERCE-4014
    Jeff Yucis

*   Add storefront translations for categoyr summary block type

    * remove legacy view for content block placeholder text

    ECOMMERCE-4003
    Beresford, Jake

*   Add translations for featured products na rules in create category workflow

    * Added translations for page titles in all views for workflow

    ECOMMERCE-4012
    Beresford, Jake

*   ECOMMERCE-4045: Includes locales for searches show

    ECOMMERCE-4045: include additional translation for sort by

    ECOMMERCE-4045: Remove haml file
    Ashley Chapokas

*   Mimic changeset directory structure better in translation path

    ECOMMERCE-3997
    Jeff Yucis

*   Merge branch 'master' into feature/ECOMMERCE-3997-admin-translations-changesets
    Jeff Yucis

*   Include analytics helper to fix test

    ECOMMERCE-4378
    Beresford, Jake

*   Translate admin toolbar

    ECOMMERCE-4055
    Jeff Yucis

*   update content block type generator

    ECOMMERCE-4379
    Matt Duffy

*   Translate changeset directory

    ECOMMERCE-3997
    Jeff Yucis

*   Add framework for bulk actions

    Still a WIP, front-end to be finished by Mr Curt

    ECOMMERCE-4275
    Ben Crouse

*   Update pricing calculator generator

    ECOMMERCE-4381
    Matt Duffy

*   Translate timeline directory.

    The card partial was translated in a previous commit

    ECOMMERCE-4054
    Jeff Yucis

*   Translate the categorizations directory

    ECOMMERCE-3996
    Jeff Yucis

*   Update discount generator

    ECOMMERCE-4380
    Matt Duffy

*   Internationalization for category creation workflow

    ECOMMERCE-4012
    Beresford, Jake

*   Rename Weblinc.config.domain to Weblinc.config.host

    ECOMMERCE-4325
    Matt Duffy

*   Remove unneeded Pricing::Sku#add_price method

    ECOMMERCE-4307
    Matt Duffy

*   Move COLOR_CODES constant to weblinc.rb for reuse in lint and seeds

    ECOMMERCE-4329
    Matt Duffy

*   Consolidate duplicate methods in discount.rb

    ECOMMERCE-4303
    Matt Duffy

*   Translate the admin/content_emails view directory

    ECOMMERCE-4004
    Jeff Yucis

*   Rename update function to refresh

    ECOMMERCE-3554
    Beresford, Jake

*   Remove deprecated methods from releases_helper

    ECOMMERCE-4290
    Matt Duffy

*   Remove delete_orphaned_content rake task

    ECOMMERCE-4324
    Matt Duffy

*   Remove deprecrated methods from Discount::Collection

    ECOMMERCE-4304
    Matt Duffy

*   Remove deprecated Content::BlockType#preview_block

    ECOMMERCE-4301
    Matt Duffy

*   Remove Mongoid attributes patch

    ECOMMERCE-4327
    Matt Duffy

*   Fix Primary Nav Content Editor UI

    ECOMMERCE-4377
    Curt Howard

*   Add test for content block analytics

    ECOMMERCE-4378
    Beresford, Jake

*   Add IDs and data bindings to all content blocks.

    ECOMMERCE-4378
    Beresford, Jake

*   Fix merge conflics in admin/catalog_product_images

    ECOMMERCE-3993
    Yucis, Jeff

*   internationalization for content_presets

    ECOMMERCE-4006
    Beresford, Jake

*   Internationalization for content_pages

    ECOMMERCE-4005
    Beresford, Jake

*   Translates delete buttons, adds more action translations

    ECOMMERCE-4278
    Dave Barnow

*   Internationalize all content_blocks views

    ECOMMERCE-4003
    Beresford, Jake

*   Added update function to current user.

    Allows SI to update WEBLINC.currentUser after an ajax action that may change some value in current user is performed.

    ECOMMERCE-3554
    Beresford, Jake

*   Change button content block to use plain test instead of wysiwyg

    ECOMMERCE-4371
    Beresford, Jake

*   Help takeover comes from the top.

    * Update takeover animation class name for semantics

    ECOMMERCE-4257
    Beresford, Jake

*   Make teaspoon test a little better

    ECOMMERCE-4071
    Beresford, Jake

*   Refactor tooltips JS into a single module

    * Replaces help_tooltips, export_buttons, navigation_tooltips, save_content_block_preset, and menu_triggers modules with a single tooltip module
    * Correct size of edit icon in navigation tooltip
    * Add ability to close content preset creation tooltip
    * Allow save content block preset tooltips to close
    * Add functionality to load tooltip content by AJAX

    ECOMMERCE-4071
    Beresford, Jake

*   Fix typo in translation and add header translation that was missed

    ECOMMERCE-3993
    Jeff Yucis

*   Translate the admin/catalog_product_images directory

    ECOMMERCE-3993
    Jeff Yucis


Workarea 3.0.0.beta.1 (2017-03-15)
--------------------------------------------------------------------------------

*   Don't test localization

    Fraught with problems

    ECOMMERCE-4356
    Ben Crouse

*   Add button to clear asset from asset picker.

    * added 'Clear asset' button to asset form fields
    * Added JS to handle new button click event and announce a clear asset change message.

    ECOMMERCE-4349

    * Added translations for content_assets

    ECOMMERCE-4002
    Beresford, Jake

*   Remove duplicate query of search customization

    ECOMMERCE-4340
    Matt Duffy

*   Correct order total discount spec

    ECOMMERCE-4333
    Matt Duffy

*   Move low inventory threshold config to configuration.rb

    ECOMMERCE-4341
    Matt Duffy

*   Remove Mongoid::Fields patch

    ECOMMERCE-4332
    ECOMMERCE-4328
    Matt Duffy

*   Cleanup order integration test

    ECOMMERCE-4344
    Matt Duffy

*   Eliminate the passing of block data via the url for new content blocks

    ECOMMERCE-4273
    Matt Duffy

*   Extract test customization class to module for reuse

    ECOMMERCE-4343
    Matt Duffy

*   Allow Content Preview UI to more accurately depict Store Front

    - Clean up implementation of content block visibility classes

    ECOMMERCE-4348
    Curt Howard

*   Finish moving rspec code into rspec gem

    ECOMMERCE-3846
    Ben Crouse

*   Automatically select relevance when a query is typed

    Fixes seemingly poor results for searches

    ECOMMERCE-4359
    Ben Crouse

*   Fix Product Summary UI to allow users to click the X to remove

    ECOMMERCE-4277
    Curt Howard

*   Fix icon alignment in catalog_product_images index/edit

    ECOMMERCE-4141
    Curt Howard

*   Convert PersonalizedRecommendation spec to minitest

    ECOMMERCE-4342
    Matt Duffy

*   Exclude paths from logging admin visits

    ECOMMERCE-4218
    Matt Duffy

*   Don't reference JST in core config

    ECOMMERCE-4353
    Curt Howard

*   Consolidate and standardize locale testing setup

    Make it easier to setup locales for testing and handle teardown
    automatically.

    ECOMMERCE-4356
    Ben Crouse

*   Change style of taxonomy insert UI in workflows.

    Created clear separation between the breadcrumb builder and the drag and drop taxonomy interface.

    ECOMMERCE-4276
    Beresford, Jake

*   Update placeholder text, labels, and help notes

    Based on document linked in ticket.

    * Conditionally show discount sale rules based on @discount.price_level

    ECOMMERCE-4190
    Beresford, Jake

*   Fix alignment of product image editing icons

    ECOMMERCE-4141
    Curt Howard

*   Finish the breakpoint job

    ECOMMERCE-4232
    Curt Howard

*   Implement inline date picker and new datetime picker

    * Adds js module & config for datepicker
    * Updates datepicker filter dropdown markup for inline datepickers
    * Remove IDs from locale hidden inputs to prevent duplicate IDs on other inputs
    * Prevent Datepicker dropdown closing when clicking something in jQuery UIs weird header
    * Change browsing controls layout for adding featured products in create category workflow
    * Change browsing controls layout for activity show view
    * Add inline datetimepicker to publish step of create workflows
    * Rip out garbage 3rd party datetime picker JS
    * create time pickers via a JST, serialize the time on form submit
    * Improve core date.js API
    * Set min height on calendar to prevent alignment issues between months with more/less days.
    * next/prev buttons styled as links instead of buttons

    ECOMMERCE-4010
    Beresford, Jake

*   Use local assigns to check for workflow modifier

    ECOMMERCE-4168
    Beresford, Jake

*   Improve diff rendering of changeset fields

    add field specific partials for content blocks to improve planned
    changes view

    ECOMMERCE-4120
    Eric Pigeon

*   * Add workflow argument to content edit partial to enable conditional styling
    * Provide default value for workflow if not passed to the render statement

    ECOMMERCE-4168
    Beresford, Jake

*   Fixes teaspoon tests related to animations of takeover

    ECOMMERCE-4257
    Beresford, Jake

*   Stop content editor from scrolling the page if it doesn't need to

    ECOMMERCE-4271
    Curt Howard

*   Add product click event when choosing a propduct from search type ahead

    ECOMMERCE-4100
    Eric Pigeon

*   Show hidden state for content blocks

    ECOMMERCE-4232
    Curt Howard

*   Ensure current release always shows when listing release options

    ECOMMERCE-4272
    Ben Crouse

*   Add logic to remove takeovers if css animation events are not implemented in browser.

    ECOMMERCE-4257
    Beresford, Jake

*   Add animation to takeovers.

    * transition_end JS module changed to transtion_events & api improved for animation events
    * Change API of takeover to accept options object for takeoverClass

    ECOMMERCE-4257
    Beresford, Jake

*   Fix positioning of autocomplete field UI

    ECOMMERCE-4145
    Curt Howard

*   Re-add link to home inside primary nav

    ECOMMERCE-4233
    Curt Howard

*   Improve release-publishing display in timeline

    ECOMMERCE-4270
    Ben Crouse

*   Add system user for tracking release publishing

    Makes the timeline more clear

    ECOMMERCE-4270
    Ben Crouse

*   Add system user for logging console activity

    Create a system user to log console activity so it is visible in the
    admin timeline.

    ECOMMERCE-4269
    Ben Crouse

*   ECOMMERCE-4217: Update release calendar colors

    Updates background/text colors of release calendar to pass accesible
    contrast ratio standards
    Jordan Stewart

*   ECOMMERCE-4196: Update $green HEX value

    `$green` was failing accessibility standards, updating HEX value
    suggested from QA
    Jordan Stewart

*   Clean up SEO head tags on search

    As recommended by SEER, simplify and ban search engines from crawling
    search results.

    ECOMMERCE-4267
    Ben Crouse

*   Apply light color styles to content editing

    ECOMMERCE-4262
    Beresford, Jake

*   Add navigation menus to admin elastic search index

    add navigation menus into the index so they can be used during create
    release workflow.

    ECOMMERCE-3888
    Eric Pigeon

*   Add animation to takeovers.

    * transition_end JS module changed to transtion_events & api improved for animation events
    * Change API of takeover to accept options object for takeoverClass

    ECOMMERCE-4257
    Beresford, Jake

*   Adds localization to storefront system tests

    ECOMMERCE-3786
    Dave Barnow

*   Conditionally position the content editor actions if view has a workflow bar

    ECOMMERCE-4168
    Beresford, Jake

*   Improve content editor form actions styling

    ECOMMERCE-4168
    Beresford, Jake

*   Use a tighter font for retina devices

    ECOMMERCE-4195
    Curt Howard

*   Clean up font-family usage

    ECOMMERCE-4195
    Curt Howard

*   Add initial-scale value to page metadata to make SEER happy

    ECOMMERCE-4255
    Curt Howard

*   Prepend user sorts to admin sorts to ensure proper sorting

    ECOMMERCE-4250
    Matt Duffy

*   Index only placed order to admin, eliminate order creation date filter

    ECOMMERCE-4242
    Matt Duffy

*   Allow user to click on an asset to select it

    ECOMMERCE-4084
    Curt Howard

*   Improve styling of product-summary component

    ECOMMERCE-4225
    Curt Howard

*   Store full bson document into order item

    Using as_json would store localized fields as the value for the current
    locale instead of storing the full translations hash.  Storing the full
    document allows the use of Mongoid::Factory.from_db/2 which doesn't need
    to typcaste and is much faster than .new(attributes)

    ECOMMERCE-4256
    Eric Pigeon

*   Add autocomplete to search customization form

    ECOMMERCE-4226
    Matt Duffy

*   Improve workflow designs

    * Add consistent skip links
    * Reduce unnecessary text
    * Fix links that look like buttons

    ECOMMERCE-4261
    Ben Crouse

*   Add Category and Pages to storefront search suggestions

    ECOMMERCE-4222
    Matt Duffy

*   REmove border from wide content preview iframe

    ECOMMERCE-4258
    Beresford, Jake

*   Removed redundant tooltip data attribute, probably a result of copy pasta

    ECOMMERCE-4244
    Beresford, Jake

*   Update markup and styles to allow primary nav to wrap to multiple lines

    * Fixed oversized edit icon

    ECOMMERCE-4209
    Beresford, Jake

*   Remove meta keywords

    As recommended in the SEER audit. They do more harm than good at this
    point.

    ECOMMERCE-4254
    Ben Crouse

*   Turn off autocomplete for tax code in product create flow

    ECOMMERCE-4205
    Curt Howard

*   Update default workflow bar button state

    ECOMMERCE-4203
    Curt Howard

*   Fix head tags for pagination/filtering in categories

    Recommendations from the SEER audit

    ECOMMERCE-4253
    Ben Crouse

*   Fix alignment issue with new product image form

    ECOMMERCE-4141
    Curt Howard

*   Stop video-and-text content block from breaking mobile layout

    ECOMMERCE-4132
    Curt Howard

*   Fix storefront fulfillment mailer cancellation preview

    ECOMMERCE-4240
    Matt Duffy

*   Add alternate locale hreflang tags

    From the SEER audit

    ECOMMERCE-4249
    Ben Crouse

*   Require name field for content preset creation

    ECOMMERCE-4127
    Curt Howard

*   Add new search customization form to admin index page

    ECOMMERCE-4227
    Matt Duffy

*   Group price adjustments on shipping show

    group price adjustments instead of outputting multiple tax line items

    ECOMMERCE-3932
    Eric Pigeon

*   Clean up shipping carrier view model and fix bug with blank

    Carrier links should be configuration

    ECOMMERCE-4243
    Ben Crouse

*   Fix rounding in dashboard view models

    ECOMMERCE-4235
    Ben Crouse

*   Improve sample data to show realistic dashboards

    ECOMMERCE-4235
    Ben Crouse

*   Fix jump_to_menu issue within Admin Toolbar

    - Also fixes an issue on mobile in the storefront

    ECOMMERCE-4184
    Curt Howard

*   General Polish

    ECOMMERCE-4236
    Curt Howard

*   Reword "Export" buttons to "Create Export"

    ECOMMERCE-4234
    Curt Howard

*   Don't show admin-toolbar until it's fully loaded

    ECOMMERCE-4229
    Curt Howard

*   Make 'All System Pages' link on System Content go to index

    ECOMMERCE-4198
    Curt Howard

*   Clean up activity show view, allow exclusion of audited_types from activity

    ECOMMERCE-4088
    Matt Duffy

*   Simplify use of js-routes

    Using two options previously missed to simplify things:
    1) the application option allows specifying routes per-engine
    2) _options: true treats the arg as options rather than a model

    ECOMMERCE-4223
    Ben Crouse

*   Conditionally hide/show admin toolbar while resizing window

    ECOMMERCE-4216
    Curt Howard

*   Do not load admin toolbar for small devices

    ECOMMERCE-4216
    Curt Howard

*   Add to_m alias for to_money to NilClass

    ECOMMERCE-4215
    Matt Duffy

*   Allow admin toolbar "takeover" to be closed on ESC

    +1 tasty refactor. Om nom.

    ECOMMERCE-4184
    Curt Howard

*   Correct display of item after adding to cart

    ECOMMERCE-4207
    Matt Duffy

*   Don't show the permissions card if not a permissions manager

    ECOMMERCE-4213
    Ben Crouse

*   Fix page titles for admin pricing skus

    ECOMMERCE-4175
    Matt Duffy

*   Only return active results for search autocomplete

    ECOMMERCE-4211
    Matt Duffy

*   Fix Taxonomy content block Reset button

    ECOMMERCE-4123
    Curt Howard

*   Properly pluralize 'Change' on release summary

    ECOMMERCE-3988
    Matt Duffy

*   Fix admin export mailer preview

    ECOMMERCE-3971
    Matt Duffy

*   Fix wonky scroll for menu-editors that are too tall

    By removing the `.view__container` and the enforced overflow on the component, we can allow the `.menu-editor` component to take up the full width of the page, allowing us to set a `scrollSensitivity` property on the sortable UI.

    ECOMMERCE-4158
    Curt Howard

*   Add permission for managing permissions

    This is an important additional permission for a CSR situation where you
    wouldn't want a third party CSR to be able to revoke/grant permissions
    to anyone.

    ECOMMERCE-4213
    Ben Crouse

*   Clean up menu-editor

    - Align menu editor control icons
    - Remove unneeded link text from menu editor control:
    - Clean up menu editor icons positioning and sizes
    - Only show menu-editor scrollbar as needed
    - Only apply gutter to sibiling menus

    ECOMMERCE-4122
    Curt Howard

*   Increment cart count when product is added to cart

    ECOMMERCE-4081
    Curt Howard

*   Add pagination to Help::Assets index

    ECOMMERCE-4200
    Matt Duffy

*   Standardize workflow-bar usage

    ECOMMERCE-4206
    Curt Howard

*   Handle complex changeset undo values when displaying release changes

    ECOMMERCE-4174
    Matt Duffy

*   Move name prefixes for inventory and pricing skus to locales

    ECOMMERCE-4175
    Matt Duffy

*   derp. active color.

    ECOMMERCE-4189
    Beresford, Jake

*   Move share functionality to plugin

    ECOMMERCE-4201
    Matt Duffy

*   Don't cache navigation content requests if logged in as admin

    ECOMMERCE-3750
    Ben Crouse

*   Removes colors for each type of card,

    * Changes active state for card to blue dropshadow with blue text + icon

    ECOMMERCE-4189
    Beresford, Jake

*   Make admin header responsive

    * Change header layout to use display: flex since the width of header__actions is variable in the admin toolbar.

    ECOMMERCE-4165
    Beresford, Jake

*   Rename Commentable#notify_user_ids to subscribed_user_ids

    ECOMMERCE-4202
    Matt Duffy

*   Clean up various TODOs

    ECOMMERCE-4202
    Matt Duffy

*   Fixes comment card translation

    ECOMMERCE-3991
    Dave Barnow

*   Converts remaining request specs to integration tests

    ECOMMERCE-3741
    Dave Barnow

*   Pass the container around to prevent errors in firefox.

    ECOMMERCE-4167
    Beresford, Jake

*   Create cart item view model

    Add a new view model specifically for cart items and move inventory
    status to only be in context of a cart where inventory is still in flux.

    ECOMMERCE-3567
    Eric Pigeon

*   Add release reminder if the release has been in session for a while

    If either you exceed average admin page views in a session for a release
    or exceed average session length with a release in session, show a
    notification to make sure the admin intends to keep working on the
    release.

    ECOMMERCE-4188
    Ben Crouse

*   Fix Bulk Updater Tests

    ECOMMERCE-3882
    F.M. Bonnevier

*   Track admin filters in session for improved index links

    ECOMMERCE-4170
    Ben Crouse

*   Fix form toggle keys, add translations for timestamp labels

    ECOMMERCE-4037
    Matt Duffy

*   Rewrite admin-toolbar

    ECOMMERCE-3203
    Ben Crouse

*   Run local time every time modules are initialized

    ECOMMERCE-4163
    Ben Crouse

*   Create fulfillment item entries for digital items

    Digital items should still get fulfilled one way or another (email,
    download) and should be marked as such for record keeping in the
    fulfillment module.

    ECOMMERCE-4169
    Ben Crouse

*   Fix ordering of menus when viewing release

    ECOMMERCE-4090
    Ben Crouse

*   Add name to Pricing::Price for changeset view

    changeset_view_model expects the model to respond to name.

    ECOMMERCE-4133
    Eric Pigeon

*   Add publishing select to content editing

    Also replace activate_with inline everywhere

    ECOMMERCE-4161
    Ben Crouse

*   Change order write concern to majority

    change the write to be acknowledged by a majority of the cluster in
    addition to being written to the disk

    ECOMMERCE-3884
    Eric Pigeon

*   Don't add categories without rules to percolator for categorization

    ECOMMERCE-4157
    Ben Crouse

*   Clean up Content Editing UI

    - Fix jank when editing content on a small screen
    - Fix taxonomy content block
    - Fix alignment of icon in content-editor controls

    ECOMMERCE-3957
    Curt Howard

*   Orders should normalize email addresses

    To make them consistent with the rest of the places we use email
    addresses.

    ECOMMERCE-4153
    Ben Crouse

*   Move release select to top left

    ECOMMERCE-4111
    Ben Crouse

*   Update bulk update form, relocate to bar.

    ECOMMERCE-3882
    F.M. Bonnevier

*   Add control to show and hide filters on all index pages

    * prevent filter options wrapping
    * date and price range filters hide too

    ECOMMERCE-4114
    Beresford, Jake

*   Set initial width of content preview

    * Fix nesting of editor actions to prevent preview button wrapping to new line

    ECOMMERCE-3716
    Beresford, Jake

*   Use helper instead of view model for intrinsic ratio styles calculation

    Also rename asset field to more descriptive name and fix content helper
    test file name.

    ECOMMERCE-2893
    Ben Crouse

*   Sometimes links should be buttons, and divs should also be buttons.

    * Buttons for everyone

    ECOMMERCE-4105
    Beresford, Jake

*   Add publishing override select for current release in admin

    To warn about release publishing, and allow overriding changes to a
    different release.

    ECOMMERCE-4135
    Ben Crouse

*   Update content_block_sizing to use dimensions from asset

    * Add dragonfly analyzer for intrinsic_ratio
    * Add intrinsic_ratio field to asset model
    * Remove unnecessary configs from hero block type

    ECOMMERCE-2893
    Beresford, Jake

*   Create Elasticsearch QueryCache middleware

    create middleware similar to mongoids that caches elasticsearch queries
    for the duration of a request.

    ECOMMERCE-4117
    Eric Pigeon

*   Fix manually merchadising products for categories

    use slug routes where appropriate

    ECOMMERCE-4095
    Eric Pigeon

*   Add links to create workflows on release plan changes page

    ECOMMERCE-4115
    Beresford, Jake

*   Fix extraneous order queries

    We're doing extra order lookups when we don't need to in an
    after_action.

    ECOMMERCE-4136
    Ben Crouse

*   No need to verify csrf for analytics

    ECOMMERCE-3944
    Ben Crouse

*   Don't log abandonments if the original search wasn't logged

    ECOMMERCE-3944
    Ben Crouse

*   Remove has children class and fix menu content N+1

    No v2 builds used that selector to style anything.

    ECOMMERCE-3954
    Ben Crouse

*   Move all cancel or delete workflow buttons to the left

    * Updated workflow bar in style guide

    ECOMMERCE-4116
    Beresford, Jake

*   Fix admin index pages not respecting creation date filters

    ECOMMERCE-4079
    Ben Crouse

*   Update Product Images minitest

    * removes `skip` from product image test
    * adds test coverage for editing a products images
    * fixes error of draggables[] drag_to order

    ECOMMERCE-3857
    Jordan Stewart

*   Add better search result matching for product names

    Increasing a boost for a phrase match on name because that's seen as
    particularly important.

    ECOMMERCE-3691
    Ben Crouse

*   Style Product Images UI

    * updates styles/colors for product images UI
    * adds `arrow` scss mixin for product image action tooltip styles
    * adds #edit for catalog_product_images resource ( based on design that switch "eye" to "edit" icon )

    ECOMMERCE-3857
    Jordan Stewart

*   Remove select-box styling in favor of using browser default select menus throughout the admin.

    ECOMMERCE-4009
    Beresford, Jake

*   Fix categorization not being indexed in search

    ECOMMERCE-3691
    Ben Crouse

*   Update parent ID of add button when restructuring taxon tree

    * Changed API for url.js updateParam to updateParams which accepts a hash and updates key value pairs of URL params

    ECOMMERCE-3913
    Beresford, Jake

*   Index page UI updates

    * Implement new layout for index pages
    * Extend browsing controls component
    * Add logic for displaying facet selections
    * Add applied facets partial
    * Add creation date partial
    * Add styles for order totals summary text
    * Add js module for filter dropdowns

    ECOMMERCE-3866
    Beresford, Jake

*   Add translation for pricing skus, prices, and global cards

    ECOMMERCE-4037
    fixes: ECOMMERCE-3991, ECOMMERCE-4033
    Matt Duffy

*   Prevent sort by order link from bugging out on click

    * Fix alignment of grip icon in taxons

    ECOMMERCE-4089
    Beresford, Jake

*   Prevent horizontal scrolling on menu editor wide

    ECOMMERCE-4092
    Beresford, Jake

*   Add auxiliary navigation to admin

    For moving around to related resources/pages.

    ECOMMERCE-4093
    Ben Crouse

*   Reject blank array values in ApplicationDocument

    Select2 will create empty string values in array fields causing data in
    weird states.  Reject blank values from arrays to prevent bad data.

    ECOMMERCE-3966
    Eric Pigeon

*   Make Catalog::Variant releasable

    ECOMMERCE-4062
    Matt Duffy

*   Rename Sidekiq worker callbacks extension

    This renames `Sidekiq::WorkerCallbacks` to `Sidekiq::Callbacks`, so it's
    easier to read and use. In order to contain all plugin code in the same
    `Sidekiq` namespace, `Sidekiq::CallbacksWorker` will not be renamed.

    ECOMMERCE-3968
    Tom Scott

*   Add append point to top of storefront layout body

    ECOMMERCE-4060
    Matt Duffy

*   Correct FlatOrPercentOff to not validate numericality of amount twice

    ECOMMERCE-4083
    Matt Duffy

*   Ensure errors on discount update renders the correct template

    ECOMMERCE-4083
    Matt Duffy

*   Cache discount application groups

    move caching from discount collection to application group caching.
    application group calculation can be a computationally expensive so cache
    the group rather than just a collection of active discounts

    ECOMMERCE-3845
    Eric Pigeon

*   Add page caching to search

    Since we aren't doing personalized search anymore, this is a great
    performance improvement.

    ECOMMERCE-4087
    Ben Crouse

*   Improve and add more dashboards

    This adds daily vs weekly time series data tracking and summary data for
    orders and discounts.

    Many small improvements as well.

    Merge branch 'better-dashboards'

    ECOMMERCE-3944
    Ben Crouse

*   Add CTA to Release Calendar UI's 'Today'

    ECOMMERCE-3896
    Curt Howard

*   Remove sqllite development dependency

    Remove the SQL lite development dependency from the
    .gemspec file created by the plugin template generator.

    ECOMMERCE-3607
    Jeff Yucis

*   Fix message rendering for in-progress product bulk updates

    ECOMMERCE-4063
    Matt Duffy

*   Fix select to use alpha2

    Change the selected parameter to use the alpha2 code to match the option
    value.

    ECOMMERCE-3930
    Eric Pigeon

*   Add inactive state for navigation menus in admin

    ECOMMERCE-3899
    Matt Duffy

*   Fixes menu triggers

    ECOMMERCE-4011
    Beresford, Jake

*   Remove developer toolbar

    ECOMMERCE-4057
    Matt Duffy

*   Change pricing cache key to use order cache key

    Update pricing cache key to look at order cache key to ensure updates to
    the order cause pricing to be recalculated.  Fix a bug that would cause
    fresh pricing requests to delete all free gifts on the order.

    ECOMMERCE-3744
    Eric Pigeon

*   Fix bug in bron kerbosch implementation

    In ApplicationGroup.calculate we generate an undirected graph
    representation of discount compatibility but setting the neighborhood
    set (read compatible discounts) on each discount. We specifically need
    the open neighborhood set, but no guarantee is made to ensure that
    open neighborhood's aren't set leading to infinite recursion when the
    graph is complete or incorrect results when the graph is a serious
    of disjoint complete subgraphs.

    ECOMMERCE-4038
    Eric Pigeon

*   Add content preview functionality

    * Adds new controller action, route, and view for content#preview
    * Add icons for breakpoints and devices
    * Improve configs for breakpoints
    * Add JS module for content preview controls
    * Improve layout of empty content editors
    * Added Device chrome to content preview
    * Move all storefront breakpoints to a single ruby config shared by js and sass files
    * Always show content blocks in edit mode despite breakpoint settings
    * Use storefront_breakpoints config in test helpers
    * Add route for previewing content areas in the storefront

    ECOMMERCE-3716
    Beresford, Jake

*   Rename promise.js module to loading.js to reduce confusion.

    ECOMMERCE-2087
    Beresford, Jake

*   Revert back to hiding facet that has ben autoselected

    ECOMMERCE-3356
    Matt Duffy

*   Add cancel to Navigation Menus New & Edit Views, Cleanup

    ECOMMERCE-3963
    Curt Howard

*   Add 2 and 3 column taxonomy blocks

    * Renames Navigation block to Taxonomy
    * Adds optional image to all Taxonomy block types
    * Added taxon_lookup class to DRY out taxonomy content block view models

    ECOMMERCE-3897
    Beresford, Jake

*   Fix styling of Content Editor's empty state

    ECOMMERCE-3985
    Curt Howard

*   Improve styling of Release Select UI

    ECOMMERCE-3958
    Curt Howard

*   Fix wording in Display tab of content editing

    - Ensure `.property__note--error` is appended to the bottom of the
    `.property` UI.

    ECOMMERCE-3873
    Curt Howard

*   Replace marketing dashboard with more useful analytics

    ECOMMERCE-3944
    Ben Crouse

*   Get rid of smart navigation nomenclature

    ECOMMERCE-3944
    Ben Crouse

*   Replace people dashboard with useful information

    ECOMMERCE-3944
    Ben Crouse

*   Fixes test failure

    ECOMMERCE-3948
    Beresford, Jake

*   Set navigation content block default start to the root taxon

    ECOMMERCE-3898
    Matt Duffy

*   Pull rspec into workarea-rspec

    move rspec dependencies into new workarea-rspec gem for apps that upgrade
    to v3.

    ECOMMERCE-3846
    Eric Pigeon

*   Look for content areas specific to contentable template

    ECOMMERCE-3612
    Matt Duffy

*   Add new customers and signups graphs to user dashboard

    ECOMMERCE-3944
    Ben Crouse

*   Fix storefront heading styles

    ECOMMERCE-3809
    Curt Howard

*   Fix layout issues with discount sentence UI

    - Add `.property--inline` which hides layout-breaking elements.

    ECOMMERCE-3808
    Curt Howard

*   Fix up alternative-image-buttons module for Product Details

    At some point the classes of the `.product-details` component were simplified. The JS module was never updated to match the changes to the class names.

    ECOMMERCE-3959
    Curt Howard

*   Fix the z-index of tooltipster to sit underneath takeovers

    ECOMMERCE-3949
    Curt Howard

*   Stop glyphs that sit below the baseline from being cut off

    A minor issue was seen on the Card UI where lowercase letters that dip below the baseline would have their tails cut off.

    ECOMMERCE-3924
    Curt Howard

*   Key user analytics based on email

    This will allow us to track signup more easily

    ECOMMERCE-3944
    Ben Crouse

*   Remove some user dashboards

    These are unhelpful with little or no value

    ECOMMERCE-3944
    Ben Crouse

*   Clean up layout of property-toggle UI

    - Align checkboxes to left, before `.property__name`
    - Clean up a lot of confusing, unused classes from the view

    ECOMMERCE-3864
    Curt Howard

*   Update decorator generator

    Now generates test decorator for test related to decorated file and
    supports decorating tests directly.

    ECOMMERCE-3212
    Matt Duffy

*   Fix Edit Products link on product_bulk_updates#review view

    ECOMMERCE-3842
    Curt Howard

*   Remove shipping dashboards

    These provide little to no value

    ECOMMERCE-3944
    Ben Crouse

*   Add output of menus sorted by orders based on current order score

    ECOMMERCE-3948
    Matt Duffy

*   Fix text capitalization on product_bulk_updates#new view

    ECOMMERCE-3838
    Curt Howard

*   Clean up summary UI

    - Remove 'view' button
    - Persist summary name on hover

    ECOMMERCE-3834
    Curt Howard

*   Redirect to help article on update

    ECOMMERCE-3940
    Beresford, Jake

*   Exclude tiered shipping services when subtotal not in range

    ECOMMERCE-3444
    Matt Duffy

*   Update product variants view

    * Split related into inventory and pricing columns
    * Remove delete text from button
    * Display price and available inventory

    ECOMMERCE-3953
    Beresford, Jake

*   Move manage help assets into workflow bar

    ECOMMERCE-3941
    Beresford, Jake

*   Add user insights

    Store user order data in analytics, and output this in the admin as part
    of insights.

    ECOMMERCE-3965
    Ben Crouse

*   Update primary navigation UI

    * Move Add item button inline with navigation items
    * Move sort by orders out of workflow bar
    * Add draggable icon to each navigation item
    * Add preview of sort by order to tooltip
    * updates all dragable icons to grip icon, move to left side, and style.

    ECOMMERCE-3948
    Beresford, Jake

*   Allow content blocks to be saved while preserving order

    ECOMMERCE-3732
    Curt Howard

*   Add post filter to help query for proper filtering by category

    ECOMMERCE-3964
    Matt Duffy

*   Show sell price of variant on product show card

    ECOMMERCE-3952
    Matt Duffy

*   Fix issue with blank values in discount product_ids and category_ids

    ECOMMERCE-3929
    Matt Duffy

*   Restore tests after confirming redirects work

    ECOMMERCE-3772
    Ben Crouse

*   Update help article show view

    * Fix view heading class
    * Add padding to help articles
    * Update headings so they make sense

    ECOMMERCE-3942
    Beresford, Jake

*   Fix custom 404 pages and navigation redirects

    This provides simpler management of these two scenarios, and aligns with
    how Rails suggests handling these if you want custom functionality.

    TODO tests that are skipped should be fixed once this is verified to
    work in a real environment.

    ECOMMERCE-3772
    Ben Crouse

*   Fix bad path_helper

    change path helper to correct helper and change text to be more friendly

    ECOMMERCE-3931
    Eric Pigeon

*   Updates markup for permissions view in admin

    * Use SVGs instead of icon font
    * Burn the table
    * Make checkboxes align
    * Reduce width

    ECOMMERCE-3938
    Beresford, Jake

*   Add link to view selected release

    ECOMMERCE-3951
    Matt Duffy

*   Clean all field type values from conditions that are not selected for a discount

    ECOMMERCE-3928
    Matt Duffy

*   Remove vestigial exchange:false argument from number_to_currency

    We used to extend number_to_currency to make use of this argument, but that has long since been removed.

    ECOMMERCE-3960
    Chris Cressman

*   Add markup for Google sitelinks searchbox

    ECOMMERCE-3943
    Ben Crouse

*   Fix bugs and improve discount rules card display

    ECOMMERCE-3782
    Ben Crouse

*   Clean up and improve search text based on resource type

    ECOMMERCE-3395
    Ben Crouse

*   Move storefront search code with the rest of search

    ECOMMERCE-3914
    Ben Crouse

*   Update Taxon UI based on feedback

    * Add logic and Correct link to navigation if taxon is present in_menu?
    * Reduce spacing in the head of the taxon list to match comps more closely
    * Add icons to taxon insert view
    * Make taxonomy insert workflow views full width
    * Add instructional text
    * Make things a little better on mobile
    * Add controls and logic to return to taxonomy root when inserting taxon in workflows
    * Add component for styling select boxes
    * Allow taxons to overflow scroll rather than wrap

    ECOMMERCE-3641
    Beresford, Jake

*   Remove automatic navigation matching from storefront search

    Builds have been routinely customizing this out because it can redirect
    to the wrong category.

    ECOMMERCE-3852
    Ben Crouse

*   Improve add to cart dialog management

    ECOMMERCE-3837
    Ben Crouse

*   Clean up SKU/ID/name for pricing and inventory

    This clarifies language and makes it easier to learn and maintain.
    Requested by Chris Cressman

    ECOMMERCE-3912
    Ben Crouse

*   Prevent save on order and shipping when pricing request is fresh

    Multiple attempts to run a pricing request without changes would
    still cause a save to order and shipping with the cloned attributes,
    which resulted in item pricing adjustments being cleared.

    ECOMMERCE-3900
    Matt Duffy

*   User order ID for order identification, remove separate field for number

    This brings API consistency because this is how SKU and product IDs
    work. It also eliminates the confusion between order ID and number.

    https://discourse.workarea.com/t/rfc-using-order-number-as-id/477

    ECOMMERCE-3851
    Ben Crouse

*   Fix delete form for variants

    ECOMMERCE-3902
    Matt Duffy

*   Fixes failing tests relating to content editing and bookmarks

    ECOMMERCE-3856
    Beresford, Jake

*   Add suggestions to searches to improve dashboard

    ECOMMERCE-3852
    Ben Crouse

*   Remove Sidekiq Unique Jobs middleware when using Sidekiq inline

    The middleware causes unexpected behavior with Sidekiq::Testing.inline!
    that results in workers not running properly

    ECOMMERCE-3904
    Matt Duffy

*   Remove search click through tracking

    We can get better info from the new analytics engine

    ECOMMERCE-3852
    Ben Crouse

*   Switch abandonment dashboard to abandonment rates

    And other search dashboard improvements.

    Rate is far better metric since the number of searches will always
    correlate with raw abandonment numbers.

    ECOMMERCE-3852
    Ben Crouse

*   Style Shortcuts

    * repositions menu tooltip dropdowns to be left aligned
    * increases menu tooltip drop down widths
    * updates verbage for added short cut heading and add action link
    * replaces shortcuts header link with "link" icon
    * updates font treatments for menu__item headings and menu__item hover state

    ECOMMERCE-3855

    Clean up scss and icons

    * leverage `inline_svg` helper for icons
    * use `center()` mixing for vertical centering of component elements

    ECOMMERCE-3855
    Jordan Stewart

*   Extract product browse option functionality

    ECOMMERCE-3849
    Matt Duffy

*   Styling for content Editor

    * Move delete and create preset actions to hover state actions
    * Move content editor controls into content editor, add preview button
    * Expose activate and deactivate actions in contentBlocks.js API
    * Add JS for canceling Edit mode
    * Add JS module to activate edit mode and scroll in to view on click
    * Styling for content editor chrome
    * Add teaspoon tests for new public API methods on content_blocks.js
    * Add teaspoon tests for content_block_editor_form_cancel.js

    ECOMMERCE-3856
    Beresford, Jake

*   Add filter tracking to analytics

    ECOMMERCE-3852
    Ben Crouse

*   Add important searches search dashboard

    ECOMMERCE-3852
    Ben Crouse

*   Remove content search for plugin creation

    ECOMMERCE-3848
    Matt Duffy

*   Add insights to search customizations

    ECOMMERCE-3852
    Ben Crouse

*   Log search data with javascript instead of inline

    To prevent spam data

    ECOMMERCE-3852
    Ben Crouse

*   Generate abandoned searches dashboard based on analytics

    ECOMMERCE-3852
    Ben Crouse

*   Add missing content block icons

    ECOMMERCE-3881
    Beresford, Jake

*   Track search abandonments

    This will become how we track search quality

    ECOMMERCE-3852
    Ben Crouse

*   Switch to cross_fields searching

    Cross fields provides more intuitive management because of the way it
    combines field scores.

    http://opensourceconnections.com/blog/2015/05/27/deep-dive-into-elasticsearch-cross-field-search/

    ECOMMERCE-3852
    Ben Crouse

*   Only set position of taxon from workflow if position is available

    ECOMMERCE-3822
    Matt Duffy

*   Update taxon select UI for primary nav content editing

    * Update markup for taxon select
    * Add link icon for taxons
    * Update taxon icon helper with better API
    * Adjust styles for taxonomy content blocks
    * Updated styles of add item button
    * change last add item button in menu editor to '+' icon
    * Remove unnecessary TaxonViewModel

    ECOMMERCE-3880
    Beresford, Jake

*   Update styles for upcoming changes view

    * Add helper to render changeset icon
    * Update layout and component styles
    * Add extra-large modifier to svg_icon component
    * Move changeset icons to config
    * Make release changesets and activity logs a bit smaller
    * Improve card display of changesets
    * Reduce size of icons and avatars in changeset and timeline views
    * move release changeset styles to class modifier
    * Update activity style_guide component

    ECOMMERCE-3867
    Beresford, Jake

*   Use correct parent id when generating url for new taxon links

    ECOMMERCE-3879
    Matt Duffy

*   Fix failing tests

    ECOMMERCE-3858
    Beresford, Jake

*   Include product clicks scores in search ranking

    Products with higher clicks scores are more likely to be clicked.

    ECOMMERCE-3852
    Ben Crouse

*   Remove personalized search results

    This was having no useful effect and sometimes detrimental ones, so
    better to remove this until we develop an algorithm that works.

    ECOMMERCE-3852
    Ben Crouse

*   Remove learned keywords from search index

    ECOMMERCE-3852
    Ben Crouse

*   Limit boosts to controlling text fields

    ECOMMERCE-3852
    Ben Crouse

*   Remove also viewed as a recommendation source

    This was expensive to calculate and didn't return useful results for the
    amount of traffic our clients get.

    ECOMMERCE-3885
    Ben Crouse

*   Change Fulfillment#ship_items

    Change method signature to accept an array of hashes so extra fields can
    be added to data hash without needing to decorate methods.

    ECOMMERCE-3564
    Eric Pigeon

*   Add release selection to primary nav index page

    ECOMMERCE-3878
    Matt Duffy

*   Upgrade to Elasticsearch 5

    Merge branch 'upgrade-elasticsearch-5-v3'

    Several things here:
    * Upgrade to ES5
    * Improve filter management
    * Test query results, not syntax
    * Align naming of facet vs filter

    ECOMMERCE-3850
    Ben Crouse

*   Create Order Pricing Cache Key

    create a cache key for order pricing to avoid repricing an order when
    nothing has changed.

    ECOMMERCE-3744
    Eric Pigeon

*   Rename Shipping Method to Shipping Service

    change nomenclature from shipping method to shipping service to better
    align with domain and prevent clashing with ruby's top level method
    class.

    ECOMMERCE-3844
    Eric Pigeon

*   Replace Elasticsearch aggregations with Workarea::Analytics for catalog dashboard

    ECOMMERCE-3847
    Matt Duffy

*   * Update styles for comment cards, remove comments--narrow modifier in favor of contextual styles
    * Style comment form
    * Add view heading to comment edit view
    * Remove relic comment show view and comment summary partial
    * address rubocop failures in comments controller

    ECOMMERCE-3737
    Beresford, Jake

*   Update styling of admin dashboards

    * Implement dashboard navigation for all dashboards
    * Create dashboard actions
    * Remove dashboard__info
    * Move ledgends below charts
    * Replace .dashboard__grid with .grid
    * Update dashboards in styleguides
    * Remove icons from dashboard headings to reduce visual clutter
    * Use %h3 for dashbaord headings for better semantics and less CSS

    ECOMMERCE-3700
    Beresford, Jake

*   Refactor summary__info styles

    ECOMMERCE-3798
    Beresford, Jake

*   Add settings_access attribute for users to match admin sections

    ECOMMERCE-3877
    Matt Duffy

*   Correct generation of image url for logo in the admin email layout

    This fixes an issue where the image was broken in mailer previews

    ECOMMERCE-3491
    Matt Duffy

*   Bump jquery-rails to 4.2.2 for jquery 1.12.4

    ECOMMERCE-3443
    Matt Duffy

*   Add creation workflow for pricing discounts

    ECOMMERCE-3800
    Matt Duffy

*   Fix issues with admin localization, correct header display issue

    ECOMMERCE-3810
    Matt Duffy

*   Create draft on render of content edit with new block to use as preview

    With content presets using the same mechanism as normal new blocks, the
    initial preview was showing the block type default data over the custom
    values copied from the preset. By creating a draft and using that as the
    initial preview, it ensures the block always reflexs the data presented
    in the form.

    ECOMMERCE-3667
    Matt Duffy

*   Update timeline admin functionality

    * Add date marker component
    * Added styleguide component for date marker
    * Update markup for timeline view
    * Add release timeline icon
    * Update classes & structure for all activity partials
    * Added activity_group component to reduce the number of places modifiers have to be added
    * Group activity by day
    * Use activity-group to create visual spearation between days
    * Add contextual styling for timeline card
    * Updated activities helper to show release name if appropriate
    * Unscheduled releases display at the top

    ECOMMERCE-3652
    Beresford, Jake

*   Render placeholder taxons as plain text for left navigation

    ECOMMERCE-3795
    Matt Duffy

*   Initial commit of WCAG compliance

    ECOMMERCE-3859
    Dave Barnow

*   Improve analytics

    1) track units sold, revenue, orders
    2) show insights in admin
    3) add top and trending products dashboards

    ECOMMERCE-3861
    Ben Crouse

*   Change admin exports to open file once

    The old admin export code was opening the csv for every line it was
    writing.  The current api changes generate to take a csv handle so
    exports can loop and write with only opening the file once.

    ECOMMERCE-3799
    Eric Pigeon

*   Fix font family issue

    ECOMMERCE-3641
    Beresford, Jake

*   Style taxonomy UI

    * Update styles for menu editor to match designs
    * Add SVGs for home, view, and pages
    * Wrap taxons in TaxonViewModel
    * Insert a new taxon in a specific position within the navigation
    * Add between functionality works with re-ordering of taxons
    * Added styles and adjusted markup for taxonomy insert step in workflows
    * Added updateParam method to WORKAREA.url API
    * Use url.js to update button hrefs on re-order
    * Keep a text button at the bottom of menu-editor menus for testing and ensuring the admin UI is easy to use

    ECOMMERCE-3641
    Beresford, Jake

*   Merge branch 'master' of ssh://stash.tools.workarea.com:7999/wl/workarea into feature/ECOMMERCE-3651-style-admin-primary-navigation
    Curt Howard

*   Update style of Admin primary navigation

    ECOMMERCE-3651
    Beresford, Jake

*   Update inventory and pricing show cards.

    * Remove unrelated cards
    * Add button links for view product, edit pricing and edit inventory to top right

    ECOMMERCE-3768
    Beresford, Jake

*   Change checkout controller modules to classes

    Change checkout modules to classes to allow for decoration in v3.

    ECOMMERCE-3788
    Eric Pigeon

*   Create mobile nav UI

    ECOMMERCE-3724
    Curt Howard

*   Move middleware to app/middleware

    Move middleware to a more conventional location.

    ECOMMERCE-3790
    Eric Pigeon

*   Generate ProductPlaceholderImage from autoload path if none exists

    ECOMMERCE-3801
    Matt Duffy

*   Make number of term filter values configurable

    ECOMMERCE-3787
    Matt Duffy

*   Track smart navigation stats in analytics module

    Take advantage of the analytics storage engine for improving smart
    navigation dashboard and sorting functionality.

    ECOMMERCE-3814
    Ben Crouse

*   Move find_ordered to a Mongo extension so any model can use it

    ECOMMERCE-3813
    Ben Crouse

*   Don't render link in navigation block if taxon is a placeholder

    ECOMMERCE-3795
    Ben Crouse

*   Fix moving a new taxon between others in creation flows

    ECOMMERCE-3793
    Ben Crouse

*   Fix content preset deletion behavior

    ECOMMERCE-3789
    Matt Duffy

*   Add tooltip to prompt for custom content preset name upon creation

    ECOMMERCE-3789
    Matt Duffy

*   Improve taxonomy management buttons

    ECOMMERCE-3794
    Ben Crouse

*   Remove cart drawer

    Fixes jumbled UI and gives builds more options for the cart
    interaction

    ECOMMERCE-3791
    Ben Crouse

*   Add blocks list to content cards

    ECOMMERCE-3746
    Ben Crouse

*   Adjust styling for Summary UI
    - Remove animations. Sorry Jake
    - Show summary__type only when within view--mixed-results
    - Reduce opacity for summary__images

    ECOMMERCE-3778
    Curt Howard

*   Rework search queries for storefront index to eliminate use of refinements

    ECOMMERCE-3736
    Matt Duffy

*   Convert strings to use locales

    ECOMMERCE-3714
    Samantha Campo

*   Clean up show & edit views

    * restore left header section for wrokflow navigation only
    * update all views headers to normalized pattern
    * Adds card--button modifier and associated styles
    * Updated some 'back' link styles for visual consistency
    * Fixed bulk edit product system text following changes on another ticket

    ECOMMERCE-3723

    Update test for show/edit pages

    ECOMMERCE-3723
    Beresford, Jake

*   Restyle Content Editing

    ECOMMERCE-3657
    Curt Howard

*   Improve navigation redirect matching

    ECOMMERCE-3772
    Ben Crouse

*   Update style for help sections

    * update styles for top category result blocks atop index page
    * removes error where pagination was displayed with each article result on index page
    * restricts page width on help#takeover, #index and #show

    ECOMMERCE-3674
    Jordan Stewart

*   Add order admin improvements

    Add full attributes view, remove pricing, improve items.

    ECOMMERCE-3783
    Ben Crouse

*   Add discount rules summary to card

    Shows a summary of field names and values

    ECOMMERCE-3782
    Ben Crouse

*   Improve release index, add creation flow

    This improves usability of the releases index to create release.

    ECOMMERCE-3780
    Ben Crouse

*   Create FulfillmentItemViewModel

    OrderItemViewModel.copy_with_new_attributes wrapped an order item that
    didn't have the model relation set.  Refactor the view models to use a
    new view model for displaying fulfilled order items.

    ECOMMERCE-3568
    Eric Pigeon

*   Use countries gem for country/region data

    This improve out-of-the-box country info and makes management a whole
    lot easier since this is a config now.

    ECOMMERCE-3779
    Ben Crouse

*   Enforce an order when 2 discounts have the same class

    Ordering of discounts has been guaranteed by class but by discounts
    inside the same class.  Define a guaranteed order discounts so
    functionality is predictable.

    ECOMMERCE-3688
    Eric Pigeon

*   Simplify address validation and use in checkout

    Because we no longer have shipping estimation, address validation and
    the use of address validation can be simplified greatly.

    ECOMMERCE-3775
    Ben Crouse

*   Style show cards

    * Remove inline styles from icon SVGs to preserve fill styles.
    * Updated all card colors
    * Update generic .card styles
    * Change width of view__container to match designs
    * Adjust some card contents to match designs and UI
    * Update activity markup to allow for 2 layouts depending on where the view is rendered.
    * Updates comment layout for card display, adding modifiers to preserve layout in other parts of the app
    * Add missing block-level markup for activities
    * Improve layout of fulfillment card contents by adjusting markup
    * Update card in style_guide
    * Add styles for card__product
    * Output rules in category rules card, rather than products

    ECOMMERCE-3658
    Beresford, Jake

*   Stlying for bulk edit flow.

    * Re-add missing workflow bar
    * Adjust markup of product summary to avoid nesting a checkbox within a link
    * Implement styles for product summary radio button/checkbox things
    * Update content and layout of bulk editing workflow bar
    * Styles & markup for bulk editing screens

    ECOMMERCE-3653
    Beresford, Jake


Workarea 2.3.4 (2016-12-06)
--------------------------------------------------------------------------------


Workarea 2.3.4 (2016-12-06)
--------------------------------------------------------------------------------


Workarea 2.3.4 (2016-12-06)
--------------------------------------------------------------------------------

*   Fix showing navigation link release changes in activity

    ECOMMERCE-3522
    Ben Crouse

*   Add append points to all email templates and to account order summary and show views.

    ECOMMERCE-3579
    Beresford, Jake

*   Merge branch 'bugfix/ECOMMERCE-3525-use-bronkerbosch-algorithm' into v2-wip
    Ben Crouse

*   Return full discount set when graph is complete

    When the graph of discounts is a complete graph; ie every discount is
    compatible with every other discount, the bron-kerbosch algorithm with
    pivoting returns no results.  Detect if the graph is complete and return
    the full set.

    ECOMMERCE-3525
    Eric Pigeon

*   Include Workareat::Testing when running override generator

    explcitly requiring the testing gem in the generator allows
    developers to override assets used to configure the testing
    environments.

    ECOMMERCE-3381
    Matt Duffy

*   Force plugins to announce version in ping to home base.

    A large percentage of plugins are not requiring the version file. This means pings to homebase are not being recorded. This change requires the plugin version file from workarea core.

    Also patched the plugin template so that future plugins will not have this issue.

    ECOMMERCE-3552
    Beresford, Jake

*   Writes test for form submitting controls.
    Adds js config variables for form control time delays.
    ECOMMERCE-2603
    Lucas Boyd

*   Flush synced before updating search index settings

    This should help with indexing downtime due to synonym changes:
    https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-synced-flush.html

    ECOMMERCE-3517
    Ben Crouse

*   Adjusts admin colors to be WCAG complaint

    ECOMMERCE-3314
    Dave Barnow

*   Improve styles for activities#show

    ECOMMERCE-3312
    Curt Howard

*   Move page messages below admin search

    On smaller screens the `.page-messages` component will overlay the admin
    search box, and will remain for a frustrating amount of time. Moving it
    below the admin header alleviates this frustration.

    ECOMMERCE-3526
    Curt Howard

*   Use Bron-Kerbosch Algorithm for calculating application groups

    Bron-Kerbosch algorithm is an algorithm for calculating maximal cliques
    in an undirected graph, which is the same problem as calculating
    discount application groups.

    ECOMMERCE-3525
    Eric Pigeon

*   Update help text for URL Redirects

    The previous notes in the admin for the To and From URL Redirect form
    were misleading.

    ECOMMERCE-2800
    Curt Howard

*   Only calculate combination sizes that can possible exists

    combination sizes are only possible when a discount has that many
    compatible_ids set.

    ECOMMERCE-3503
    Eric Pigeon


Workarea 2.3.3 (2016-11-08)
--------------------------------------------------------------------------------


Workarea 2.3.3 (2016-11-08)
--------------------------------------------------------------------------------


Workarea 2.3.3 (2016-11-08)
--------------------------------------------------------------------------------


Workarea 2.3.3 (2016-11-08)
--------------------------------------------------------------------------------

*   Ensure callbacks get called on module re-init

    `.addBack()` the `[data-analytics]` selector so that analytics events
    are triggered on the response of an ajax request in the storefront.

    This ensures that customized apps that make use of AJAX requests on
    their product details pages report a SKU change, encapsulated within a
    `productQuickView` event.

    ECOMMERCE-3438
    Curt Howard

*   Fix image path in Store Front email layout

    Logo in Store Front emails is broken in development environment when
    using Rails server (and potentially other environments/situations).

    Use more robust method to construct the image path.

    ECOMMERCE-3456
    Chris Cressman

*   Allow shipping method rate tiers to be set blank for open-ended price ranges

    ECOMMERCE-3397
    Matt Duffy


Workarea 2.3.2 (2016-10-25)
--------------------------------------------------------------------------------

*   Remove duplicate ui_widget_overlay import

    - Remove duplicate `ui_widget_overlay` import from storefront
      application.scss.erb manifest.

    ECOMMERCE-3365
    Curt Howard

*   Fix Reset Results route on payment_transactions#index

    - Change Reset Results route from `content_assets_path` to
      `payment_transactions_path`

    ECOMMERCE-2719
    Curt Howard

*   Fix hidden discount compatibility

    Discount application grouping was not correctly grouping discounts. It was allowed two incompatible discounts into a group if they were both set compatible from a third as well as being compatible with a fourth.

    ECOMMERCE-3386
    Ben Crouse

*   Fix typo in navigation link destroy activity partial

    ECOMMERCE-3375
    Matt Duffy

*   Correct path of javascript module generated with js_module_generator

    ECOMMERCE-3369
    Matt Duffy

*   Use path route helper in StyleGuidesHelper

    - Remove excessive poltergeist timeout

    ECOMMERCE-3371
    Curt Howard

*   Prevent impersonated user orders from becoming an admins order on session timeout

    ECOMMERCE-3323
    Matt Duffy

*   Fix link name persisting in failed link creation

    ECOMMERCE-1526
    Ben Crouse

*   Add append point for checkout confirmation page

    This is needed by workarea-listrak (and probably other plugins) to
    cleanly insert our `<script>` tag into the order confirmation page.

    ECOMMERCE-3366
    Tom Scott


Workarea 2.3.1 (2016-10-11)
--------------------------------------------------------------------------------

*   Fix broken email template footer links

    ECOMMERCE-3256
    Darielle Davis

*   Add Workarea.config.domain to default_url_options

    Fixes situations where internal IP addresses are used as hosts when Rails doesn't have a host to use.

    ECOMMERCE-3328
    Ben Crouse


Workarea 2.3.0 (2016-10-07)
--------------------------------------------------------------------------------

*   Add monitoring endpoint for load balancing

    Checks whether this particular server should be included in load balancing.

    ECOMMERCE-3138
    Ben Crouse

*   Prevent duplicate audit log entries for embedded documents in a release

    ECOMMERCE-3318
    Matt Duffy

*   Add 404 page to sample data

    ECOMMERCE-3325
    Ben Crouse

*   Fix issues with content block changes showing for content activity

    ECOMMERCE-3318
    Matt Duffy

*   Add inline-help to tax_categories#new view

    ECOMMERCE-3285
    Curt Howard

*   Fix alertification notification persistence

    ECOMMERCE-3311
    Curt Howard

*   Fix bottom-center position on hero content block

    ECOMMERCE-3317
    Curt Howard

*   Add unique tax codes to tax category factory

    ECOMMERCE-3161
    Ben Crouse

*   Fix action-text modifier for hero-type content blocks

    The hero-type content block scss files were referencing the wrong
    element modifier. Update the hero-type content block scss & style
    guides.

    ECOMMERCE-3316
    Curt Howard

*   Add ability to customize hero banner alt text

    Our offering for the 'hero banner' content block type didn't have any way of updating
    the alt text attribute for the image selected - it was alawys and empty string.

    Alt text is important for SEO and accesibility reasons, there for it should
    be open for customization in the admin to reflect better information for
    it corresponding image.

    We now provide the ability for admin to update hero banner content blocks alt-text; this input
    is intended to be optional.

    * adds alt text input field on hero content block in admin
    * adds output of alt text on hero content block storefront
      (copy of banner content block implementation)

    ECOMMERCE-3315
    Jordan Stewart

*   Use dragonfly secret from Rails secrets if present

    This will make environment transfers of assets easier. Try to use Rails.application.secrets.dragonfly_secret if present. Fallback to Rails.application.secrets.secret_key_base which is what we're currently doing.

    ECOMMERCE-3296
    Ben Crouse


Workarea 2.3.0.beta.1 (2016-10-05)
--------------------------------------------------------------------------------

*   Update help articles

    New articles:
     - Pricing and Tax
     - Import Tax Rates
     - Orders

    Updated articles:
     - SEO
     - Notifications

    You can get the new articles by running `rake workarea:upgrade_help`

    ECOMMERCE-3009
    Ben Crouse

*   Use item quantity in percentage-based discount calculation

    ECOMMERCE-3174
    Matt Duffy

*   Add minimum length to account edit password field

    ECOMMERCE-3228
    Ben Crouse

*   Add rake task to dump help

    Dumps help articles to data/help in a format that can be consumed by the help sample data creator.

    ECOMMERCE-3293
    Ben Crouse

*   Fix missing search click throughs

    ECOMMERCE-3292
    Ben Crouse

*   Check checkout purchasability during place order

    ECOMMERCE-3028
    Matt Duffy

*   Add compatibility with PhantomJS >= 2

    Poltergeist must be bumped for compatibility with the newer version of PhantomJS.

    PhantomJS has added an in-memory page cache, so we must clear this before tests. When testing the same page, a manual cache expiration is necessary.

    All tests still pass on PhantomJS < 2, you just get a warning to upgrade PhantomJS.

    ECOMMERCE-3288
    Ben Crouse

*   Only fire validation analytics if WORKAREA.analytics module exists

    ECOMMERCE-3220
    Ben Crouse

*   Add analytics events for flash messages and validation errors

    ECOMMERCE-3220
    Ben Crouse

*   Add rake task for help upgrading

    Add a rake task to add and index only help articles that aren't already in the database.

    ECOMMERCE-3286
    Ben Crouse

*   Update tax code field and fix admin indexing on product bulk update

    ECOMMERCE-3072
    Matt Duffy

*   Allow to use of .include over .prepend to add module decorators to subclasses

    ECOMMERCE-3214
    Matt Duffy

*   Move developer toolbar into middleware without persistence

    ECOMMERCE-3271
    Ben Crouse

*   Add 'Not Specified' as option for shipping method country selection

    ECOMMERCE-2038
    Matt Duffy

*   Filter address region select by selected country

    ECOMMERCE-3267
    Matt Duffy

*   Use text box for pricing sku tax code selection

    ECOMMERCE-3276
    fixes: ECOMMERCE-3277
    Matt Duffy

*   Sort search product suggestions to match search customizations

    ECOMMERCE-3265
    Ben Crouse

*   Rename "Open" By status link in admin navigation to "Placed" for clarity

    ECOMMERCE-3219
    Matt Duffy

*   Fix style guide button spacing for dev toolbar

    ECOMMERCE-3141
    Ben Crouse

*   Stylize developer toolbar

    ECOMMERCE-3141
    Matt Duffy

*   Use config for scrollToButton's animation speed

    ECOMMERCE-3261
    Curt Howard

*   Add indexes to help performance

    Reported by Jason when working on CSC performance

    ECOMMERCE-3224
    Ben Crouse

*   Improve Customized Sort Search Results UI

    Previously we had two instances of jQuery UI sortable interacting with
    one another, which technically worked, but allowed both areas to be
    sorted. The problem was only one of the areas saved the sort.

    By switching the other area to a draggable instance we are able to have
    a more desireable interaction.

    ECOMMERCE-3065
    Curt Howard

*   Use config value in content preview live update

    Swap hard-coded js integer with the max url length
    config value set by the application.

    ECOMMERCE-3010
    Kristen Ward

*   Update js config for erb compatibility

    Escape non-erb js parser values in config

    ECOMMERCE-3010
    Kristen Ward

*   Add .erb extension to js config files

    Use git mv to keep history

    ECOMMERCE-3010
    Kristen Ward

*   Add underscore to index name for locales

    Elasticsearch requires that the name of each index
    consists of lowercase letters and underscores. The use
    of locales in the index name such as en-US breaks
    this requirement.

    ECOMMERCE-3222
    Sean Fenton

*   Allow proper switching between content and product search results

    ECOMMERCE-3205
    Matt Duffy

*   Fix decorating test files with multiple test classes

    This is a common Minitest pattern, so our decoration should allow for it.

    ECOMMERCE-3211
    Ben Crouse

*   Add primary nav analytics events

    Using the primary navigation will now fire analytics events, with a
    payload that contains link name, link depth, and the resulting url.

    ECOMMERCE-3135
    Curt Howard

*   Add toolbar to storefront to provide developers with useful information

    ECOMMERCE-3141
    Matt Duffy

*   Add filtering for admin navigation redirects

    Mongo indexes on Workarea::Navigation::Redirecti were added in order
    to support this feature. Existing builds will be required to run
    `rake db:mongoid:create_indexes` in order to maintain performance.

    ECOMMERCE-3160
    Matt Duffy

*   Add hide/show password toggle to password fields

    In lieu of a password confirmation field, we now offer a hide/show
    password toggle.

    ECOMMERCE-3157
    Curt Howard

*   Update tax rate and category validations

    ECOMMERCE-3161
    Matt Duffy

*   Allow changes to new content block made from a preset to persist correctly

    ECOMMERCE-3171
    Matt Duffy

*   Fix allowing invalid shipping method on place order

    It's possible get a shipping method and price at one price tier, leave checkout, change order contents, manually enter the payment URL, click place order, and receive incorrect shipping method and/or price for that method because shipping methods aren't being validated.

    ECOMMERCE-3201
    Ben Crouse

*   Regenerate storefront icon fonts

    At some point the icons.json file stopped importing nicely with
    icomoon.io. This manifest has been regenerated based on the default
    icomoon free fontset and imports much better.

    ECOMMERCE-2768
    Curt Howard

*   Ensure alertifications to not appear off-screen

    Give the alertification tooltip a max-height to ensure it always appears
    _below_ the trigger element, and not above and off page.

    ECOMMERCE-3134
    Curt Howard

*   Remove unnecessary price adjustment deletion in discounting

    Remove superfluous calls to delete these in the database, price adjustment manipulation should be handled in memory.

    ECOMMERCE-3184
    Ben Crouse

*   Fix N+1 percolator queries for order analytics

    Using the product view model causes an Elasticsearch percolator query per-item whenever order item analytics are rendered.

    Switching to Mongoid to look up categories based on the IDs saved on the Order::Item is much more performant.

    ECOMMERCE-3179
    Ben Crouse

*   Update admin area button ID for multiple areas.

    * Add spec test for multiple content areas in admin.
    * Concat dynamic string to ID for button

    ECOMMERCE-3076
    F.M. Bonnevier

*   Add endpoints for application health monitoring

    ECOMMERCE-3138
    Matt Duffy

*   Add product-list__inventory-status element class

    The inventory status was being output in a naked paragraph tag.

    ECOMMERCE-2977
    Curt Howard

*   Permanently delete orders in the clean orders worker

    Mongoid::Paranoia is preventing these from actually being deleted in the DB, which can cause performance drags on other Order queries.

    ECOMMERCE-3173
    Ben Crouse

*   Add Rails logging for host enforcement

    Makes for easier debugging

    ECOMMERCE-3169
    Ben Crouse

*   Show worst performing searches in search customizations admin

    Showing these on search customizations gives admins a starting place for searches for which they should try to improve results.

    ECOMMERCE-3168
    Ben Crouse

*   Escape product IDs when clearing from search index

    Escaping this is a slight behavior change (people may be inadvertently depending on this behavior) but this fixes a hard-to-track-down bug.

    ECOMMERCE-3167
    Ben Crouse

*   Add clickable link by slugs on edit pages in admin

    ECOMMERCE-3166
    Ben Crouse

*   Reduce audit log expiry to 3 months

    We end up with some very large audit log collections, let's reduce this to trim them down.

    ECOMMERCE-3165
    Ben Crouse

*   Simplify creation of content presets

    ECOMMERCE-3136
    Matt Duffy

*   Correctly display release changes for multi-column content blocks

    ECOMMERCE-3062
    Matt Duffy

*   Allow admin user to see where a navigation link currently points to.

    When an admin user tries to edit a navigation link in the admin, there is no way for them to see where the
    link currently points to.  This alleviates that problem to make it easier on the admin.

    ECOMMERCE-3149
    Joe Giambrone

*   Add minitest support

    This functionality gives several big wins:
     * Automatic test suite upgrading
     * Decoratable tests

    All tests will be moved to Minitest for v3.0, this converts a handful to serve as a preview for what's to come. This also gives curious developers something to get their feet wet.

    Mild gotcha to use this functionality: to correctly set Rails.env when running rake workarea:test, workarea must be required before Bundler.require in config/application.rb. We make use of the same hack Rails does to make this possible. Currently, the app generator places workarea requires after Bundler.require, but this will change in v3.0.

    ECOMMERCE-3137
    Ben Crouse

*   Show embedded model activity for a root model

    For instance, show product image activity when viewing activity for the product.

    ECOMMERCE-3112
    Ben Crouse

*   Fix promo code lists showing in notifications

    They are accidentally being included and outputting incorrectly.

    ECOMMERCE-3114
    Ben Crouse

*   Add sorting discounts by redemptions

    This new feature will require re-indexing discounts to take effect.

    ECOMMERCE-3140
    Ben Crouse

*   Anchor regular expression queries

    remove invalid mogno index - mongodb only allows one array field in an
    index
    left achor regular expression queries - when a case senstive regular
    expression starts with a left achor, mongodb can effeciently use an
    index to perform the query

    ECOMMERCE-3152
    Eric Pigeon

*   Fix shipping index for looking up by number

    ECOMMERCE-3150
    Ben Crouse

*   Avoid generating overrides for files containing the specific file name

    ECOMMERCE-3143
    Matt Duffy

*   Use shipping method value to populate tax_code field on edit

    ECOMMERCE-3145
    Matt Duffy

*   Fix ContentSearchViewModel spec

    ECOMMERCE-3081
    Matt Duffy

*   Fix forging host on browse page links

    This is a side-effect of passing params through to the link_to helper

    ECOMMERCE-3142
    Ben Crouse

*   Allow date-range-picker UI to be right-aligned

    ECOMMERCE-3113
    Curt Howard

*   Simplify SEO automation and move to background process

    ECOMMERCE-3108
    Matt Duffy

*   Convert region field to text box for countries without regions

    ECOMMERCE-3091
    Matt Duffy

*   Add indexes on audit log for admin notifications

    Fixes significant performance problems when loading admin pages with lots of activity.

    ECOMMERCE-3132
    Eric Pigeon

*   Embed tax imports into tax category

    ECOMMERCE-3084
    Matt Duffy

*   Allow creation of just a content preset.

    ECOMMERCE-3090
    Matt Duffy

*   Copy all file types of matching paths when using the override generator

    ECOMMERCE-3022
    Matt Duffy

*   Update Canadian postal code regex in sample data to allow lowercase

    ECOMMERCE-3101
    Matt Duffy

*   Fix navigation link activity with releases

    ECOMMERCE-3054
    Ben Crouse

*   Add release tracking to audit log entries to display in activity

    ECOMMERCE-3054
    Ben Crouse

*   Add rake task for creating orphaned content

    Cotnent that is associated with a contentable that was never persisted
    to the database causes content search to break.

    ECOMMERCE-3104
    Eric Pigeon

*   Add product image support to activity

    Tracking embedded documents in activity required work on the audit log gem. This bumps the dependency on that gem to take advantage.

    ECOMMERCE-3054
    Ben Crouse

*   Update Tax Category and Rates workflow

    ECOMMERCE-3084
    Matt Duffy

*   Outdent storefront.secondary_payment append point

    The `storefront.secondary_payment` append point, on
    `checkouts#payment`, was indented, causing invalid nesting of
    `.checkout-payment__secondary-method` elements.

    Outdenting this append point fixes the issue.

    ECOMMERCE-3077
    Curt Howard

*   Search Customization Content creates orphaned content

    view a search results page was creating orphaned cotnent for null
    objected search customizations. add a guard statement to prevent
    creating content

    ECOMMERCE-3083
    Eric Pigeon

*   Allow the content editing drawer to reopen

    Provide a `$source` value to `WORKAREA.drawer.closeCurrentDrawer` so that
    a user may change their mind when choosing a content block to
    administrate.

    ECOMMERCE-3070
    Curt Howard

*   Allow content blocks to be reused as presets

    ECOMMERCE-3047
    Matt Duffy

*   Only use existing fulfillment admin ES order status

    When determining order status for admin ES index, it should only look at
    the fulfillment if it actually exists.  Otherwise when SIs decorate a
    fulfillment without items to have a different status than :open, the
    order might be indexed with the wrong status.

    ECOMMERCE-3063
    Eric Pigeon

*   Fix Continue Shopping button on empty cart

    Change the `:back` action to `root_url`.

    ECOMMERCE-3033
    Curt Howard

*   Add tax category and rate to activity

    ECOMMERCE-3053
    Ben Crouse

*   Quiet the audit log in Sidekiq

    Better to have this off by default as a way to avoid noise in the audit log. It can still be turned on manually.

    ECOMMERCE-3053
    Ben Crouse

*   Fix activity count on main dashboard

    ECOMMERCE-3050
    Ben Crouse

*   Correct tax import behavior

    Ensure that tax imports update existing rates if possible, and make
    charge on shipping field case insensitive.

    ECOMMERCE-3059
    fixes: ECOMMERCE-3060
    Matt Duffy

*   Add admin tax category management

    ECOMMERCE-3030
    Matt Duffy

*   Round calculated sales scores to two decimal places smart navigation dashboard

    ECOMMERCE-3052
    Matt Duffy

*   Rename recent-views-heading CSS element

    `recent-views-heading` class should be `recent-views__heading`

    ECOMMERCE-2974
    Curt Howard

*   Increse width of popup button window

    Some of the social networks we support on the PDP have increase the
    width of their share pages. Update the default width value for
    `WORKAREA.config.popupButtons.width`

    ECOMMERCE-2766
    Curt Howard

*   Support decorators in any directory with .decorate extension

    This makes it easier to see customizations in an app without having to jump around different directories. This will be the only way to decorate with the release of v3.0.

    For example, if you want to decorate Workarea::Catalog::Product, you would create a file at #{Rails.root}/app/models/workarea/catalog/product.decorate with the contents:
        module Workarea
          decorate Catalog::Product do
            # my decorations
          end
        end

    *.decorator files are just Ruby, and editors will need to be updated to use Ruby settings on these files. *.decorator files are loaded _after_ decorators in app/decorators.

    ECOMMERCE-3044
    Ben Crouse

*   SEO automation

    Provide smart default values for page title and description for
    home page, pages, categories, and products when user defined
    values are not present.

    ECOMMERCE-3000
    Matt Duffy

*   Handle missing navigation links related to smart nav aggregation

    ECOMMERCE-3042
    Matt Duffy

*   Add 'Search Settings' guide

    ECOMMERCE-2930
    Chris Cressman

*   Add 'Search Customizations' guide

    ECOMMERCE-2890
    Chris Cressman

*   Remove extraneous queries when calculating primary nav for a product

    No need for the extra queries or logic which is providing trivial value.

    ECOMMERCE-3023
    Ben Crouse

*   Add two & three column Hero content blocks

    Two and three column, hero-based content blocks are now available as
    part of the Admin's default content block offering.

    - Add jQuery Accordion to the admin, used in the Content Block Edit
      dialog to help consolidate large forms.
    - Simplify Hero Content Block positioning CSS. Though technically
      breaking, this is a refactor and the optimized code does not
      necessarily to be taken during an upgrade.
    - Removes background image requirement for all hero-type content blocks

    ECOMMERCE-2990
    Curt Howard

*   Fix pagination.js page-footer bug

    This bug occurs intermittantly on builds. The issue manifests itself as
    a floating `.page-footer` component that appears in the middle of a set
    of paginated results.

    This occurs because, on unload of a page that contains pagination, the
    view's height is being cached in `window.history.state` to be recalled
    when a user navigates back to the page. This is done to preserve their
    spot on the page when the brower's back functionality is triggered.

    The solution is to ensure that the view's height is cleared after 750ms,
    in the same way we handle page scrolling aspect of the module. This way
    the static height is _always_ removed.

    ECOMMERCE-3027
    Curt Howard

*   Fix "A copy of xxx has been removed from the module tree but is still active"

    Patch to Wisper that I am 99% sure fixes the issue

    ECOMMERCE-3020
    Jesse McPherson

*   Avoid elasticsearch deprecation warnings

    Elasticsearch (the gem) version 2.0 was released on July 20. The release
    includes deprecation warnings for methods not compatible with version 2
    of Elasticsearch (the database).

    Since Workarea applications use Elasticsearch (the database) version 1.x,
    these warnings are irrelevant and a nuisance. We don't depend on
    elasticsearch explicitly, but we do depend on elasticsearch-persistence
    which optimistically depends on elasticsearch > 0.4, resulting in
    Bundler resolving to elasticsearch 2.0.

    Explicitly constrain elasticsearch to < 2.0 to avoid these warnings.

    ECOMMERCE-3021
    Chris Cressman

*   Clean summary dashboard for 1 column display

    ECOMMERCE-3002
    Ben Crouse

*   Align search customization custom sort ui with category preview ui

    ECOMMERCE-3001
    Matt Duffy

*   Add activity to dashboard

    This increases visibility of the activity stream in the admin.

    ECOMMERCE-3002
    Ben Crouse

*   Increase click area when adding/removing manual products to a category

    This commit allows a user to click the entire product summary component,
    instead of just the nested checkbox, when adding/removing manual
    products to a category.

    ECOMMERCE-2989
    Curt Howard

*   Validate operator and field for category rules

    ECOMMERCE-2914
    Matt Duffy

*   Search Quality Report

    ECOMMERCE-2941
    Matt Duffy

*   Reduce asset thumbnail load time preventing timeouts

    Currently our calls to asset thumbnails call the optim
    process, and then another process which itself calls the
    optim process.

    Call the correct image processor directly, rather than
    doubling up processor calls. This allows for efficient
    retrieval of the correct processed job and ensures
    caching.

    ECOMMERCE-2428
    Kristen Ward

*   Add title attribute to asset thumbnails

    Since name is truncated, add full asset name as title

    ECOMMERCE-2942
    Kristen Ward

*   Fix dev-only issue when adding products to the cart

    An issue was reported that an Uncaught TypeError appears, in
    development, when a user is adding a product to the cart. This seems to
    only occur when an SI is jumping around to many branches during a
    project's development. Sometimes the product data changes on them,
    causing them to have to reseed. This error then acts as a false-flag, as
    they assume there is something wrong with the drawer and not the cart,
    where the real problem lies.

    The fix simply ensures that a passed argument is a jQuery Collection
    before trying to treat it as such.

    ECOMMERCE-2972
    Curt Howard

*   Skip processing for admin images that are SVG

    ECOMMERCE-2927
    Matt Duffy

*   Add activity stream to admin

    This includes avatars for admin users. This gives more awareness to what's going on in the admin and can even allow for debugging by SI teams.

    ECOMMERCE-2943
    Curt Howard

*   Rearrange sample data loading to ensure content blocks have data

    ECOMMERCE-2961
    Matt Duffy

*   Expand character set for word separation in content block extraction

    ECOMMERCE-2928
    Matt Duffy

*   Fix issue with notification generation for discount autodeactivation

    ECOMMERCE-2923
    Matt Duffy

*   Truncate asset names to fit with ellipses

    Text is overflowing its box. Add overflow hidden
    and ellipses.

    ECOMMERCE-2942
    Kristen Ward

*   Don't enforce domains when request is from load balancer

    Seeing the 301 causes the ELB to take app servers out of rotation, which brings all app servers down.

    ECOMMERCE-2970
    Ben Crouse

*   Fix not showing release validation errors when updating

    ECOMMERCE-2921
    Ben Crouse

*   Add Tax rate importing

    ECOMMERCE-2940
    Matt Duffy

*   Make completed order cookie expiration configurable

    Allow SIs to change this value in their projects,
    so that working with the order confirmation page
    is easier during development.

    ECOMMERCE-2666
    Kristen Ward

*   Show correct browse option image on browse and pdp

    Generic products set to browse by option are not
    displaying the correct option due to discrepencies in
    case and option name.

    Check for options[:option] first, as browse by option
    images will have this value in summaries. Fall back to
    browse option name, such as 'color', which is used by PDP.
    Prefer option so that correct image will still display
    when multiple filters are applied.

    ECOMMERCE-2593
    Kristen Ward

*   Document decorator generator

    ECOMMERCE-2471
    Chris Cressman

*   Change fulfillment to publish cancelations responsibly

    calling Fulfillment#cancel_items would publish workarea_items_canceled
    with impunity.  Passing any empty enumerable would cause an event to be
    published even though no items were canelled.  Passing item ids not
    present in the order would still publish cancelation events.  Change
    fulfillment to only publish when items are actually canceled and only
    the items that were canceled.

    ECOMMERCE-2966
    Eric Pigeon

*   Fix improper use of link_to in status report mailer

    link_to doesn't make sense in a plain text email remove it

    ECOMMERCE-2955
    Eric Pigeon

*   Use proxies from environment variables for Geocoder

    ECOMMERCE-2948
    Ben Crouse

*   Fix help sample data by moving help docs into core

    This will allow them to be referenced in sample data when gems are published/distributed.

    ECOMMERCE-2939
    Ben Crouse

*   Include version number in `rails new` examples

    To create a Workarea v2 app, you must use the Rails 4 executable. Update
    examples in guides to specifiy that version.

    ECOMMERCE-2803
    Chris Cressman


Workarea 2.2.0 (2016-07-01)
--------------------------------------------------------------------------------

*   Add help articles for release

    ECOMMERCE-2845
    Ben Crouse

*   Redirect to cart when adding a promo code from the summary

    ECOMMERCE-2462
    Ben Crouse

*   Remove content from search index on deletion

    ECOMMERCE-2920
    Matt Duffy

*   Fix back button display and class names on mobile menus

    Back button is showing inconsistently in the mobile navigation
    menu, and menu class modifier is always `1` rather than the
    current menu depth.

    Fix logic flow for keeping menu depth accurate, and add correct class.

    Update mobile nav spec to test that back button works properly

    ECOMMERCE-2628
    Kristen Ward

*   Overhaul page-content component

    `.page-content` was originally written to work relatively automagically.
    This caused a lot of confusion in the code and disallowed implementers
    the ability to customize without totally overhauling this component at
    the project level.

    This was solved by simplifying the component and rewriting it to follow
    the path a developer would take to customize. This means that the layout
    of this component is now dependant on the classes applied to the
    `application` or `checkout` layout file, which is a more natural
    flow for developers.

    Another big upshot of this work is that we are able to conditionally
    show the page's aside depending on what layout it's part of. Now, during
    checkout by default, the order totals table is available for mobile.

    ECOMMERCE-2753
    Curt Howard

*   Add empty content block message to content editing UI

    ECOMMERCE-2870
    Curt Howard

*   Fix discounts created in the TTL period getting auto-deactivated

    ECOMMERCE-2915
    Ben Crouse

*   Remove one-off bulk-import help page in favor of article

    ECOMMERCE-2902
    Curt Howard

*   Add spaces after csv values on catalog_products#edit

    If a Product contained too many filter values the edit view's layout
    would be compromised, since there was no natural way to wrap the
    outputted text. Swapping the delineator from `,` to `, ` provides the
    browser with a natural way of wrapping the text in this area.

    ECOMMERCE-2773
    Curt Howard

*   Add visual weight to prompt for reload for bulk uploading

    The styling of the message displayed after a successful bulk upload was
    too benign. We had to knock it up a notch with a blast from our spice
    weasel, e.g. display a success `.message` component instead.

    ECOMMERCE-2913
    Curt Howard

*   Allow html options to be passed to link_to_filter

    Only name and value are currently accounted for, as well as
    link text optionally from a block. Update link_to_filter method
    to work more like link_to, responding to html_options as well

    Update unit test

    ECOMMERCE-2776
    Kristen Ward

*   Use appropriate image sizes for displaying assets in the admin

    ECOMMERCE-2907
    Matt Duffy

*   Decrease visual impact of help button

    ECOMMERCE-2905
    Curt Howard

*   Prevent user from unloading window while bulk uploading assets

    Now a confirmation dialog will be produced when a user attempts to
    navigate away from an active Dropzone instance.

    ECOMMERCE-2908
    Curt Howard

*   Add storage of who checked out on an order

    If an order is placed using impersonation, this is now shown in the admin (and who actually placed the order). This functionality was requested in the v2.2 RC demos.

    ECOMMERCE-2592
    Ben Crouse

*   Prevent slug from being changed for releases

    ECOMMERCE-2888
    Matt Duffy

*   Add Validation to CategoryRule value

    If a category rule is saved where the value is empty, it causes the ES
    percolation to break, add validation on presence of value to prevent
    invalid rules from getting saved.

    ECOMMERCE-2899
    Eric Pigeon

*   Add fields to track user impersonation

    These fields will be displayed in the admin and tracked by the audit to log.

    ECOMMERCE-2592
    Ben Crouse

*   Update app template to set session expiration to two weeks

    ECOMMERCE-2894
    Matt Duffy

*   Default the asset name to the file name if no name given

    Improves asset display when lots of bulk-uploaded assets

    ECOMMERCE-2898
    Ben Crouse

*   Ensure `with` option set in decorator generator is a valid symbol

    ECOMMERCE-2896
    Matt Duffy

*   Fix alerts showing for inactive products

    This isn't an alert and causes confusion and alerts that cannot be cleared.

    ECOMMERCE-2897
    Ben Crouse

*   Fix help related query to respect configured max count

    ECOMMERCE-2895
    Ben Crouse

*   Record audit log when publishing a release

    This will ensure tracking for all release publishing (not just releases manually published in the admin).

    ECOMMERCE-2883
    Ben Crouse

*   Add rake task to reload help articles

    Useful for upgrading to ensure the latest help articles end up in the admin.

    ECOMMERCE-2884
    Ben Crouse

*   Remove deprecated data attribute

    ECOMMERCE-1608
    Curt Howard

*   Fix LocalTime bug with alertifications

    `LocalTime.run()` is being called every minute, naturally. It does not
    run for elements that are visually hidden when the page is loaded. This
    affected the alertifications UI. The fix was to nudge `LocalTime` to
    rerun when the tooltip content was ready to be displayed.

    ECOMMERCE-2660
    Curt Howard

*   Removes line that resets repo, makes block one-line

    ECOMMERCE-2731
    Dave Barnow

*   Allow permissions to help for admins

    This will allow admins with permissions to manage help. For example, if a client wants to write some articles for their own workflow, this can now be stored in the system.

    ECOMMERCE-2878
    Ben Crouse

*   Add display of discount redemption/auto deactivation times

    Intended to help admin users awareness of redemption and auto-deactivation scheduling

    ECOMMERCE-2877
    Ben Crouse

*   Add append point for admin edit order meta data

    Adds append point to admin order edit screens meta data.
    A use case could be showing 3rd party IDs or timestamps

    ECOMMERCE-2860
    Jeff Yucis

*   Add notification for bulk edits

    A bulk edit is an important event admins will want to know about.

    ECOMMERCE-2876
    Ben Crouse

*   Adds suggested search terms to sample data ECOMMERCE-2731
    Dave Barnow

*   Add cart link element classes to .page-header component

    We've been missing `.page-header__cart-link` and
    `.page-header__cart-count` for a long time. No more, I say.

    ECOMMERCE-2769
    Curt Howard

*   Add release switching option to admin toolbar

    ECOMMERCE-2844
    Matt Duffy

*   Remove case-sensitive uniqueness validations

    These validations cause slow MongoDB queries with regexes. Although this may be considered breaking, a poll showed that developers were in favor with this change 2-to-1

    ECOMMERCE-2863
    Ben Crouse

*   Use full class name for Shipping::Method in sample data

    ECOMMERCE-2861
    Matt Duffy

*   Write a test for forms.js

    ECOMMERCE-2604
    Ivana

*   Update share mailer to user config email_from, set reply-to to user's email

    ECOMMERCE-2794
    Matt Duffy

*   Swap YouTube video with placeholder on Style Guide

    YouTube made a change to it's JavaScript on it's servers. Since we were
    loading a real YouTube video on the Style Guide page, RSpec began to
    fail for us. This commit removes the network dependency of loading a
    live YouTube video and favors just a placeholder iframe which will still
    accurately simulate an embedded video for styling purposes.

    ECOMMERCE-2859
    Curt Howard

*   Don't remember location for form submissions

    This causes invalid redirects, which result in 404s

    ECOMMERCE-2854
    Ben Crouse

*   Remove admin documentation in favor of help docs

    ECOMMERCE-2840
    Matt Duffy

*   Add link to view full cart from cart drawer

    ECOMMERCE-2842
    Matt Duffy

*   Restore use of dialog loading options config

    ECOMMERCE-2780
    Matt Duffy

*   Alias append methods on the Workarea module

    Workarea.append_* is a nicer way to write it, we only care about it being part of Plugin internal to core.

    ECOMMERCE-2843
    Ben Crouse

*   Improve app template prompts and allow skipping them

    Add prompt for sample data.

    Reword plugins prompt.

    Move all prompts to beginning.

    Use `WORKAREA_TESTS` environment variable to skip tests prompt.

    Use `WORKAREA_SAMPLE_DATA` environment variable to skip sample data prompt.

    ECOMMERCE-2670
    Chris Cressman

*   Fix display of invalid transactions in admin

    Add 'missing' partial for compatibility, catch errors
    in payment type and title when no tender is present.

    Add unit test

    ECOMMERCE-2621
    Kristen Ward

*   Show correct browse option image in generic summary and pdp

    On pdp options come from the url, and options[:color] (or other
    browse option) provides the correct result. In browse summaries
    options come from the search result, and the value needed comes
    from options[:option]

    Try fallback to product.options[:option] for use in summaries.

    Look for optionized browse option for use in pdp for consistency

    Update spec

    ECOMMERCE-2593
    Kristen Ward

*   Show checkout page totals on mobile

    Add wrapper classes to show and hide at breakpoints

    ECOMMERCE-2753
    Kristen Ward

*   Fix auto-update of menu items when dragged to last position

    Menu item positions do not save when an item is dragged to the
    bottom of the list. The condition for inserting a menu item
    below another item is never reached, as the empty child menu
    condition is incorrectly met first. This causes logic errors on
    ajax update, which does not save the order of menu items properly.

    Update condition for detecting empty child menu via addToParent
    function.

    Add unit test of addToParent method (expose method for testing)

    ECOMMERCE-2658
    Kristen Ward

*   Send correct current item price to order item analytics

    Prices for order items are appearing inflated in analytics
    dashboard. Use current item price for order item price.
    Use fix from COSCENTER-745

    Update unit test

    ECOMMERCE-2795
    Kristen Ward

*   Fix Semantic Markup for Prices

    The Semantic Markup for pages with prices on them was being considered invalid by the Google Structured Data Testing tool (https://search.google.com/structured-data/testing-tool). It was considered invalid because the "price" property contained a symbol and the "priceCurrency" field was missing. This commit moves the "$" symbol outside of the "span" that contains the product's price and adds a "meta" tag that contains the price's currency.

    ECOMMERCE-2767
    Mike Dalton

*   Add 'View Models' guide

    ECOMMERCE-2247
    Chris Cressman

*   Ensure comments are deleted when commentable is deleted.

    ECOMMERCE-2732
    Matt Duffy

*   Shipment embeds_one address should be addressable

    Polymorphic relations need an as field to work fully.  Adding as to the
    relationship on shipment allows the address to know about the shipment
    it is embedded in.

    ECOMMERCE-2781
    Eric Pigeon

*   Delay subscription of listener until after initialization of classes

    ECOMMERCE-2725
    Matt Duffy

*   Add date range toggling to order shipping status dashboard

    ECOMMERCE-2761
    Matt Duffy

*   Translate error messages in password validator

    Update spec

    Add TODO for v3

    ECOMMERCE-2730
    Kristen Ward

*   Include mail preview routes in all environments except production

    ECOMMERCE-2436
    Matt Duffy

*   Show user validation errors on failed password reset

    Errors such as a weak password are not being shown do to
    an invalid method call. App crashes instead. Update to
    loop over each user error and add it to the errors displayed
    as flash messages.

    ECOMMERCE-2730
    Kristen Ward

*   Fix flash messages getting cached

    Since we call /current_user.json on all endpoints that get HTTP cached, the code written to handle flash messages on XHR requests will show and discard the flash message correctly. We only need to prevent flash message pages from being added to the cache.

    ECOMMERCE-2715
    Ben Crouse

*   Simulate hover-intent in CSS for context-menus

    ECOMMERCE-2676
    Curt Howard

*   Store user activity ID with order

    This will allow better analysis of activity data in the future

    ECOMMERCE-2756
    Ben Crouse

*   ECOMMERCE-2731 Begins work on search suggestions
    Dave Barnow

*   Prevent NaN errors in date fields on back button in Safari

    In production only, the datetimepicker fields module
    is being re-run on page load after a back button press
    and is trying to use the cached, already-localized ("pretty") value
    as its starting value. In Safari, this creates an Invalid Date object,
    which is converted to NaN values by strftime.

    Provide opportunity to return from the setLocalizedDate function
    before updating the field value. This fixes the safari production
    edge case where the initial value comes from the browser cache
    rather than the iso8601 value provided by the server, and the module
    re-initializes anyway.

    Add unit test

    ECOMMERCE-2596
    Kristen Ward

*   Rename incorrect label attribute to match field on bulk update form

    ECOMMERCE-2596
    Kristen Ward

*   Update reference to loading indicator options

    Dialog options are being referenced instead,
    resulting in loss of delay option.

    ECOMMERCE-2681
    Kristen Ward

*   Fix misleading green for the abandoned orders dashboard

    ECOMMERCE-2702
    Ben Crouse

*   Add help article to manage shipping methods

    ECOMMERCE-2706
    Ben Crouse

*   Allow remote selects to be used in content editing UI

    Because jQuery Select2 is a non-standard form control, and because we
    previously had no content editing UI make use of them, the content
    editor would simply use the last selected value in one of these controls
    as the value for the params hash being passed to the preview route.

    Also, this commit introduces minimal test coverage for the module.

    ECOMMERCE-2703
    Curt Howard

*   Remove form-actions from tab component

    ECOMMERCE-2541
    Curt Howard

*   Make top products graph colors consistent with top categories

    ECOMMERCE-2702
    Ben Crouse

*   Fix and clean up dialog_spec.js

    The `createFromUrl` and `createFromForm` examples were written
    incorrectly. Their assertions were never being called due to their
    dependency on `$(document).ajaxComplete()`.

    This commit also:
    - fixes formatting issues (adding semicolons)
    - removes unnecessary, duplicate assertions from a few other examples

    ECOMMERCE-2720
    Curt Howard

*   Add assets to help system

    This includes a way sample article with assets to demonstrate how to load assets from sample data

    ECOMMERCE-2707
    Ben Crouse

*   Add help article for browsing and content navigation

    ECOMMERCE-2642
    Matt Duffy

*   ECOMMERCE-2600: adds cookie_spec.js

    ECOMMERCE-2600: adds comment to what to check on cookie_spec

    ECOMMERCE-2600: adding a delay for testing cookie

    ECOMMERCE-2600: fixes to cookie spec

    ECOMMERCE-2600: finished test for cookie with expiration date

    ECOMMERCE-2600: updates cookie js to test for expiration date
    Ivana

*   Add spec for url.js

    ECOMMERCE-2599
    Curt Howard

*   Re-write search guides

    ECOMMERCE-2580
    ECOMMERCE-2581
    ECOMMERCE-2582
    ECOMMERCE-2616
    Chris Cressman

*   Add Automated JavaScript Testing guide

    ECOMMERCE-2704
    Curt Howard

*   Make no_results search page contentable.

    ECOMMERCE-2542
    Matt Duffy

*   Improve handling of publishing overrides

    Makes them safer with guarantees around errors and previously-set overrides

    ECOMMERCE-1287
    Ben Crouse

*   Allow content to be added for search results based on query

    ECOMMERCE-2541
    Matt Duffy

*   Create product list content block type

    ECOMMERCE-2703
    Matt Duffy

*   Remove unneeded memoization

    It causes bugs with multisite Sidekiq middleware

    ECOMMERCE-2714
    Ben Crouse

*   Remove unneeded memoization

    It causes bugs with multisite Sidekiq middleware

    ECOMMERCE-2714
    Ben Crouse

*   m.save }

    2.) Alternatively, passing an option to the **save** method will disable
    publishing during a save action, similar to the `validate: false`
    convention ported from ActiveRecord (and Mongoid):

            model.save publish: false

    I feel like the second choice there will be used more often, but I'd
    like to have the block too both for backwards compatibility and because
    you might need to execute multiple lines of code without publishing. But
    that is somewhat flexible...

    ECOMMERCE-1287

    Signed-off-by: Frank Zondlo <fzondlo@gmail.com>
    mImprove the APIs of Workarea::Publisher

    The API for disabling the publishing of Wisper notifications to our
    listeners can be a little ugly to deal with in some instances. This
    change allows two things:

    1.) Passing the model instance into the block, for brevity:

            model.without_publishing {
    Frank Zondlo

*   Use current Mongoid client for "map reduce" collections instead of default Mongoid client

    We create several collections that are used with "map reduce" queries. Since these collections do not have a corresponding class, we need to tell Mongoid which database to store these collections in. This commit changes this database from the default client to the current client since a multi site setup could switch to a non-default client.

    ECOMMERCE-2665
    Mike Dalton

*   Prevent errors caused by blank sku reserve quanity

    nil reserve quantities cause errors when calculating
    available to sell quantities.

    Convert values to integers in calculation.

    ECOMMERCE-2558
    Kristen Ward

*   Allow blank tax policy to be saved in bulk edits

    Javascript currently disables all bulk editing fields
    with blank values. Add a data attribute that can be used to enable
    blank values. Apply to tax policy field.

    Add method to display '-' instead of nothing on the review
    page for nil values

    Add unit test for js

    ECOMMERCE-2611
    Kristen Ward

*   Fix bulk update 'Allow Discounting' toggle

    Toggling is not working. Update markup to fix.

    ECOMMERCE-2611
    Kristen Ward

*   Allow admin filter of products by template type

    ECOMMERCE-2687
    Matt Duffy

*   Add SEO features help article

    ECOMMERCE-2649
    Ben Crouse

*   Add product variants help article

    ECOMMERCE-2646
    Ben Crouse

*   Add product filters and attributes help article

    ECOMMERCE-2645
    Ben Crouse

*   Add search features help article

    ECOMMERCE-2644
    Ben Crouse

*   Unit tests are executable after being generated

    Currently, the decorator generator in 2.2 will generate verbatim model
    specs from the engine it finds the implementation code in. However, this
    causes problems if your spec files use the `rails_helper` rather than
    the `spec_helper`, which we seem to be implementing as a company. The
    generator will now gsub out `require 'spec_helper'` for
    `require 'rails_helper'`, so that generated specs can be run
    immediately and to ensure correctness on the implementing developer's
    part.

    ECOMMERCE-2139
    Tom Scott

*   Add sample data help articles

    Sample data will load articles from docs/help. The format of that directory for an article is:

    docs/help/{category}/{title}/summary.md
    docs/help/{category}/{title}/body.md
    docs/help/{category}/{title}/thumbnail.{jpg,jpeg,gif,png}

    ECOMMERCE-2636
    Ben Crouse

*   Ignore content blocks and admin in rack-attack

    ECOMMERCE-2684
    Ben Crouse

*   Don't rate-limit product images with rack-attack

    ECOMMERCE-2683
    Ben Crouse

*   Memoize default_category_id to prevent extraneous Elasticsearch queries

    ECOMMERCE-2682
    Ben Crouse

*   Rewrite development environment guides

    Introduce the prepared (virtualized) development environment option.

    Make the custom development environment instructions less specific to
    OS X.

    ECOMMERCE-2476
    Chris Cressman

*   Prevent empty reserve quantity from being saved via admin form

    nil reserve quantities cause errors and there is currently no validation
    to prevent nil values from being saved. Add client side validation to
    prevent errors from being encountered from admin ui.

    Add to all inventory sku quantity fields on new and edit screens

    ECOMMERCE-2558
    Kristen Ward

*   Remove h1-h6 margin from generic/_visual_rhythm.scss

    The `margin-bottom` for h1 through h6 elements was being applied in two
    files: `base/_headings.scss` and in `generic/_visual_rhythm.scss`.
    This commit removes the entry in `generic/_visual_rhythm.scss`.

    ECOMMERCE-2585
    Curt Howard

*   Add "Help & Support" guide

    ECOMMERCE-2512
    Chris Cressman

*   Add ENV to meta title for client-only facing environments

    ECOMMERCE-2567
    Curt Howard

*   Add explicit require to generated sample_data

    Generated SampleData creators don't explicitly require
    `workarea/sample_data` at the top of the file, which can cause issues if
    you're doing anything but tacking the creator onto the end of the
    swappable list. If you attempt to swap, insert_before/after, or delete,
    you'll run into a `LoadError` when Ruby tries to autoload the constant
    that was referenced.

    For example, this will fail:

    ```ruby
    module Workarea
      module SampleData
        class Foos
          def perform
            Foo.create_all!
          end
        end

        creators.swap Products, Foos
      end
    end
    ```

    But this will work:

    ```ruby
    require 'workarea/sample_data'

    module Workarea
      module SampleData
        class Foos
          def perform
            Foo.create_all!
          end
        end

        creators.swap Products, Foos
      end
    end
    ```

    The reasoning behind this is because the SampleData file will also
    create the `creators` SwappableList and load in all of the required
    constants, so you can just begin working and not have to worry about
    loading your particular code..

    ECOMMERCE-2597
    Tom Scott

*   Minor CSS and flow improvements to Help UI

    - Fix alignment of help index summary name and text
    - Open help articles in new tab from drawer

    ECOMMERCE-2539
    Curt Howard

*   Add Alertification UI

    ECOMMERCE-2546
    Curt Howard

*   Minor fixes from QA

    - Fixes layout of `help-article__head`. Didn't need to be a table. Not
      everything _needs_ to be a table.
    - Add style guides for `search-form`
    - Add `search-form--outlined` modifier
    - Make help drawer search form a `search-form`
    - Pad out the right side of `help-article__aside`
    - Add titles to Edit and Delete buttons

    ECOMMERCE-2539
    Curt Howard

*   Automatically configure Elasticsearch

    This consolidates ES configuration and adds functionality to automatically pull Elasticsearch URLs out of environment variables.

    ECOMMERCE-2591
    Ben Crouse

*   Automatically configure Redis

    This consolidates Redis configuration and adds functionality to automatically pull Redis config out of environment variables.

    ECOMMERCE-2594
    Ben Crouse

*   Fix datepicker styles

    ECOMMERCE-2431
    Kristen Ward

*   Prevent cutoff of absolutely positioned elements in admin dialogs

    Remove dialog overflow scrolling in admin

    Overflow: auto; setting is cutting off absolutely positioned
    elements within dialogs, and is not necessary as jquery ui
    automatically resizes the window to fit the contents.

    ECOMMERCE-2481
    Kristen Ward

*   Clean up Help UI

    Adds teaspoon tests for `drawer.js`.

    ECOMMERCE-2539
    ECOMMERCE-1806
    Curt Howard

*   Add translation for storefront mobile navigation button

    Mobile navigation menu fallback text is plain english.
    Change to localized translation.

    ECOMMERCE-2515
    Kristen Ward

*   Automatically configure Mongoid

    The goal of this feature is to prevent implementations from creating custom Mongoid configs that are incorrect or inconsistent.

    This functionality will be expanded in v3 to include diff read/write preferences per-model.

    ECOMMERCE-2568
    Ben Crouse

*   Account for locale when defining predicate methods

    Mongoid defines predicate methods for each `field` you specify in the
    model class definition, in addition to accessors so that the fields can
    be modified. These predicates, which are basically the field name with a
    '?' on the end, return +true+ or +false+ depending on whether the field
    is present in the document or not (e.g., the value of the field is not
    `null`). For localized attributes, however, this method would always
    return `true` if it had been set at any time, since localization is
    implemented in Mongoid by converting each attribute value into a nested
    JSON object, with each key representing a locale and each value
    representing the attribute value for that given locale (using the `I18n`
    library to fall back locales in the same way the rest of the Rails app
    works).

    This patch is essentially a copy/paste of the Mongoid fixes made by
    Emily Stolfo, which can be seen in its original form on the Mongoid
    JIRA, and on GitHub:

    https://jira.mongodb.org/browse/MONGOID-4260

    Fixes ECOMMERCE-2563
    Tom Scott

*   Prevent submission of fixture form in teaspoon analytics spec

    ECOMMERCE-2565
    Matt Duffy

*   Add task to clean up host projects

    ECOMMERCE-2538
    Matt Duffy

*   Add UI documentation for synonym phrases

    ECOMMERCE-2531
    Ben Crouse

*   Add additional sensitive fields to filtered params

    ECOMMERCE-2522
    Ben Crouse

*   Use request.host instead of request.domain for URL enforcement

    The previous implementation failed when running on a subdomain

    ECOMMERCE-2569
    Ben Crouse

*   Fix issue with discount compatibility

    ECOMMERCE-2529
    Matt Duffy

*   Fix erratic teaspoon tests

    ECOMMERCE-2565
    Matt Duffy

*   Redirect to Workarea.config.domain if the request doesn't match

    This makes hosting setup easier by making the app a single point of config/knowledge about what domain the site should be running on.

    ECOMMERCE-2569
    Ben Crouse

*   Dont publish touching last_indexed_at

    Saving a product will fire off index product browse and admin index
    listeners, but product browse touches the product causing the admin to
    rexinded that product a second time.  Without publishing updating
    last_index_at prevents this second index.

    ECOMMERCE-2564
    Eric Pigeon

*   Change storefront redirects to 301 instead of 302

    Although there are situations for a temporary redirect, a permanent redirect is the primary use-case here. This feature is usually used for rescuing old site URLs and redirecting to their new ones after a re-platform to Workarea.

    ECOMMERCE-2570
    Ben Crouse

*   Allow configuring whether decorators load order is enforced

    This will allow us to gradually roll out and test this functionality before we release v3.0.

    ECOMMERCE-2460
    Ben Crouse

*   Make pricing and inventory sku fields read-only

    Changing the pricing sku 'sku' field is illegal and
    there is code in the system to prevent it. However the field
    can still be edited on the front-end, causing errors. Remove
    editable field and replace with text.

    Do same for inventory sku edit page

    ECOMMERCE-2511
    Kristen Ward

*   Tweak DropzoneJS UI

    ECOMMERCE-2527
    Curt Howard

*   Remove memoization in Address#country_model as it causes validation issues

    ECOMMERCE-2562
    gharnly

*   Validate minimum quantity for pricing sku prices

    Negative quantities are currently bypassing client side validation.
    Add model validation to pricing sku prices and output errors in
    the edit view.

    ECOMMERCE-2505
    Kristen Ward

*   Add inventory to product bulk editing

    ECOMMERCE-2537
    Matt Duffy

*   Prevent double firing of update cart item analytics event

    The update cart item event is also firing on form submission.
    Prevent duplication by returning from the setup form submissions
    handler if the event type is updateCartItem.

    Add refactoring comment, update spec

    Update checkoutShippingMethodSelected event to fire on change

    ECOMMERCE-2510
    Kristen Ward

*   Add alerts to the admin

    ECOMMERCE-2492
    Ben Crouse

*   Add Pricing fields to product bulk editing

    ECOMMERCE-2536
    Matt Duffy

*   Adding a append point for product image fields

    ECOMMERCE-2559
    MMartyn

*   Made user order history count configurable

    Number of orders to display on the user order history page is now
    configurable through the workarea config

    ECOMMERCE-2517
    Frank Zondlo

*   Fix backorder messaging for items with no ship date or backordered quantity

    Backorder messaging is falling back incorrectly.
    Items with no ship date are being declared out of stock, while items with
    no available or backorder quantity are being declared backordered rather
    than out of stock.

    Display generic 'backordered' message for items with backorder qty but
    no ship date.

    Display 'out of stock' for items with no backorder or available quantity,
    regardless of ship date.

    ECOMMERCE-2431
    Kristen Ward

*   Show admin toolbar on all storefront pages

    Previously, it only showed when there was an underlying object to show. This helps bring attention when previewing a release or impersonating a user.

    ECOMMERCE-2535
    Ben Crouse

*   Make publisher enabling/disabling threadsafe

    ECOMMERCE-2526
    Ben Crouse

*   Sort decorators before loading to ensure consistent load order

    ECOMMERCE-2460
    Matt Duffy

*   Add user impersonation and remove admin order-placing

    Merge branch 'impersonate-customer' into v2-wip

    To minimize duplicate code and functionality, we're replacing admin order-placing with the ability to impersonate a customer on the storefront. This will give CSRs the same customizations to checkout as customers.

    ECOMMERCE-2484
    Ben Crouse

*   Adds a Checkout Progress indicator component

    ECOMMERCE-2490
    Curt Howard

*   Add dragonfly analyzer fields to ProductPlaceholderImage

    ECOMMERCE-2552
    Curt Howard

*   Store additional dragonfly analyser data on asset model

    ECOMMERCE-2412
    Curt Howard

*   Show correct inventory status in cart

    Skus with an allow_backorder inventory policy incorrectly display
    inventory status as "in stock" when backordered quantity exists but
    available (in-stock, non-reserve) quantity is low or 0.

    Check that product is not backordered before displaying
    the in stock or low stock messaging.

    ECOMMERCE-2431
    Kristen Ward

*   Extend bulk asset upload functionality to content block UI

    ECOMMERCE-2525
    Curt Howard

*   Fix another release spec

    ECOMMERCE-2514
    Matt Duffy

*   Add basic notifications to the admin

    ECOMMERCE-2493
    Ben Crouse

*   Add Bulk Asset Upload functionality

    ECOMMERCE-2487
    Curt Howard

*   Fix new release creation from browsing navigation select menu

    Form submitting controls are causing the release selection
    menu from submitting prematurely when 'new release' is selected

    Remove auto-submit from select box, unhide 'Go/Apply' button

    Change action/button text to reflect ui considerations

    ECOMMERCE-2468
    Kristen Ward

*   Enables JS for all feature tests

    All feature tests are now running with javascript enabled.
    This commit sets `js: true` for all feature tests and fixes any failing tests as a result of that.

    ECOMMERCE-2333
    Dave Barnow

*   Tweak release spec

    This fixes random failures experienced by SI teams as well as the product CI.

    ECOMMERCE-2514
    Matt Duffy

*   Remove trailing new lines in code blocks

    Improve visual appearance of code blocks in guides by
    removing the trailing empty line.

    ECOMMERCE-2399
    Frank Zondlo

*   Clean up Decorator Generator

    ECOMMERCE-2501
    Matt Duffy

*   Revert "Merge pull request #1311 in WL/workarea from feature/ECOMMERCE-2384-place-order-in-admin to v2-wip"

    This reverts commit aede85af51680db4c5a7c2ec3a36bceb682ccf1a, reversing
    changes made to 3c3d08cced7a8dc023316857cf7ca0ef4bcecf34.

    Conflicts:
        admin/app/assets/javascripts/workarea/admin/application.js.erb
    Ben Crouse

*   Fallback gracefully on content block live previews that are too large

    ECOMMERCE-2326
    Matt Duffy

*   Add automatic deactivation of discounts after lack of use

    This feature adds a background job to automatically deactivate discounts when they haven't been used in 30 days (configurable). An admin can override this by disabling auto deactivation on an individual discount.

    There are two main things we're trying to achieve with this feature:
    *   Retailers losing money due to discounts they forgot were active
    *   Improve pricing performance by not needing to calculate stale discounts

    Merge branch 'auto-deactivate-discounts' into v2-wip

    ECOMMERCE-2489
    Ben Crouse

*   Add help area to admin

    Merge branch 'admin-help' into v2-wip

    ECOMMERCE-2380

    Conflicts:
        admin/app/assets/javascripts/workarea/admin/application.js.erb
    Ben Crouse

*   Add normalization of email address on email signups

    downcase all email addresses on email signups to allow the
    removal of case-insensitivity validation, preventing regex
    queries during validation.

    ECOMMERCE-2480
    Matt Duffy

*   Expire order reports after configurable period

    ECOMMERCE-2482
    Matt Duffy

*   Add "Ecosystem" guide

    The "Ecosystem" guide supercedes the "View Workarea Source Code" guide,
    so remove "View Workarea Source Code" guide and update all links to point
    to "Ecosystem" guide instead.

    Also link to "Ecosystem" and "Prerequisites & Dependencies" from guides
    home page.

    ECOMMERCE-2474
    Chris Cressman

*   Add rspec-retry to test suite

    While hacky, if this improves reliability of builds and productivity of developers, who cares. Builds have been unreliable for reasons outside the scope of this software (e.g. poltergeist, phantomjs) and it's not worth our time to specifically work around those issues.

    ECOMMERCE-2491
    Ben Crouse

*   Ensure custom sample data creators are only added once

    When swapping sample data creators, any custom creators
    swapped-in are also auto-loaded at the end.

    Check for existing sample data creator before inserting into list

    ECOMMERCE-2464
    Kristen Ward

*   Fix URL assertion for when running tests in host app

    ECOMMERCE-2386
    Ben Crouse

*   Switch to an event stack

    This will allow other uses for the stack, e.g. asserting against event firing order in tests or an adapter making use of the event order.

    ECOMMERCE-2386
    Ben Crouse

*   Add "Prerequisites & Dependencies" guide

    ECOMMERCE-2434
    Chris Cressman

*   Sanitizing optional query in product queries

    ECOMMERCE-2467
    MMartyn

*   Admin users can place orders through the admin

    ECOMMERCE-2384
    Matt Duffy

*   Add analytics feature test

    By opening up the `WORKAREA.analytics.events` array as a public property
    on the module we are able to return it's contents to rspec and assert
    that each key in the event hash is present and reporting correctly.

    ECOMMERCE-2386
    Curt Howard

*   Add placeholder content for content block previews that are too large.

    ECOMMERCE-2326
    Matt Duffy

*   Add append point and admin css class for easier extension of product templates

    ECOMMERCE-2265
    Matt Duffy

*   Add default modal overlay styles and implementation example

    Platform currently uses non-modal dialogs by default, with the
    option to pass in settings via data attribute. However, once
    `modal: true` is activated, there are no functional styles
    included for the overlay.

    Additionally, there is no included reference for how to set up
    the data attribute with options hash correctly.

    Include default styles for `.ui-widget-overlay` and jsdoc
    example for `data-dialog-button` options.

    ECOMMERCE-1589
    Kristen Ward

*   Explicitly set Accept header for pagination ajax request

    ECOMMERCE-1653
    Matt Duffy

*   Redirect to cart on xhr requests with expired checkout

    When checkout expires, ajax requests which are designed to replace
    sidebar content insert the cart page into the sidebar instead.
    Flash message is rendered inside sidebar as well.

    Add logic to checkouts controller to change the window location
    via js upon receiving expired xhr requests, recreating the same
    experience as a non-xhr request.

    Add 422 status to prevent js from replacing content prior to redirect.

    Add request spec

    ECOMMERCE-2026
    Kristen Ward

*   Generate decorators and unit tests

    Currently, devs must manually create the decorator file and copy over
    the unit tests whenever they wish to decorate an existing Workarea
    platform component. This adds a generator called 'workarea:decorator'
    whose job it is to create the generated decorator file with sane
    defaults, then copy over the decorated class's respective unit tests so
    that we can get faster feedback when existing functionality has been
    changed.

    ECOMMERCE-1502
    Tom Scott

*   Update meta environment tag

    Tag attributes are incorrect.

    ECOMMERCE-2349
    Kristen Ward

*   Constrain pricing sku quantities to a minimum of 1

    Add client side validation

    ECOMMERCE-2236
    Kristen Ward


Workarea 2.1.3 (2016-04-06)
--------------------------------------------------------------------------------

*   Do not display pagination markup for 0 pages

    The shared pagination partial is currently not rendered when there
    is only 1 page of results to display, but values of 0 are not currently
    accounted for. The partial will be rendered for an empty collection,
    resulting in erratic behavior and unnecessary js initialization.

    Update conditional to display pagination only for collections
    with greater than 1 page.

    ECOMMERCE-2461
    Kristen Ward

*   Handle customization attributes with a space character

    When passing in attributes to instantiate a `Customizations` class, the attributes are all converted to instance variables. This works for attribute names that are already valid identifier but if an attribute has a space in it (i.e. "A Test") it is not considered a valid identifier. By calling `#systemize` on the attribute name, it will be converted to a `String` that is a valid identifier.

    ECOMMERCE-1641
    Mike Dalton

*   Fix random CI failure in releases spec, take 2

    ECOMMERCE-2443
    Curt Howard

*   Fix random CI failure in releases spec

    Due to the way the calendar control scenario was written, it was not
    waiting for xhr properly. This should fix that issue.

    ECOMMERCE-2443
    Curt Howard

*   Flatten TopCategories dashboard inheritence

    ECOMMERCE-2433
    Matt Duffy


Workarea 2.1.2 (2016-04-01)
--------------------------------------------------------------------------------

*   Fix more broken dashboards due to missing models


    ECOMMERCE-2433
    Ben Crouse


Workarea 2.1.1 (2016-04-01)
--------------------------------------------------------------------------------

*   Fix broken dashboards due to missing data on upgrade

    Upgrading broke demo.workarea.com due to missing data, even after running the rake task to update the dashboards. This commit patches those places of missing data.

    ECOMMERCE-2433
    Ben Crouse


Workarea 2.1.0 (2016-04-01)
--------------------------------------------------------------------------------

*   Add "Listeners & Publishers" guide

    ECOMMERCE-2246
    Chris Cressman


Workarea 2.1.0.beta.5 (2016-03-31)
--------------------------------------------------------------------------------

*   Add "Today" button to Releases calendar UI

    - Updates `icon-text-button` style guide
    - Adds hover state for all control buttons
    - Adds "Today" button which resets the calendar state

    ECOMMERCE-2421
    Curt Howard

*   Add 'muted' modifier to Cancel buttons in bulk edit views

    ECOMMERCE-2405
    Curt Howard

*   Alternate month colors statically on the releases#index calendar

    ECOMMERCE-2417
    Curt Howard

*   Change CSV Help Tooltip heading to read better

    ECOMMERCE-2350
    Curt Howard

*   Allow plural class names in sample data creators

    `.classify` is stripping the plural form off of class names.
    Use `.camelize` instead to prevent errors when running
    custom sample data.

    ECOMMERCE-2182
    Kristen Ward

*   Remove "Decorate a Sample Data Creator" Guide

    The changes to sample data in Workarea v2.0 made sample data decoration
    irrelevant. Some users of the guide also reported the process described
    did not work in their appplication. Put this to bed by removing the
    guide.

    ECOMMERCE-2090
    Chris Cressman

*   Clarify how to customize a Modernizr build

    Users asked for more explicit instructions to customize the Modernizr
    build used within their application. Update the Modernizr guide
    accordingly.

    ECOMMERCE-2167
    Chris Cressman

*   Adjust the layout of grouped chart__summary elements

    ECOMMERCE-2397
    Curt Howard

*   Adjust layout of releases#index calendar container

    ECOMMERCE-2391
    Curt Howard

*   Update 'Create a Release' help tooltip text

    ECOMMERCE-2370
    Curt Howard

*   Remove message styling from releases#edit

    ECOMMERCE-2393
    Curt Howard

*   Merge branch 'v2-wip' into improve/ECOMMERCE-2361-update-release-notes-add

    Conflicts:
    	docs/guides/source/release-notes.html.haml
    Ben Crouse

*   Update 'Create a Release' tooltip help text

    ECOMMERCE-2370
    Curt Howard


Workarea 2.1.0.beta.4 (2016-03-29)
--------------------------------------------------------------------------------

*   Align Order Summary toggles with other Dashboards

    ECOMMERCE-2369
    Curt Howard

*   Update dashboard icons

    ECOMMERCE-2319
    Curt Howard

*   Change Learn More link on releases#edit to be a question mark icon

    ECOMMERCE-2347
    Curt Howard

*   Prevent search index reset all from running twice

    Remove duplicate code in index manager

    ECOMMERCE-1985
    Kristen Ward

*   Add missing product list analytics HTML data

    All product lists should have analytics data attached to them for completeness. This was fixed by the Rachel Roy team. This commit makes a few minor changes to their work.

    ECOMMERCE-2373
    Ben Crouse

*   Fix order stats to update with applied filters

    Reorder refinements to include admin filters before order filters

    Add unit test

    ECOMMERCE-2122
    Kristen Ward

*   Restrict access to dashboards based on user permissions

    ECOMMERCE-2328
    Matt Duffy

*   Include category in order item analytics data

    ECOMMERCE-2313
    Kristen Ward


Workarea 2.1.0.beta.3 (2016-03-28)
--------------------------------------------------------------------------------

*   Allow changing the linkable through the admin UI

    ECOMMERCE-2359
    Ben Crouse

*   Display Menu Editor Sort By menu on its own line

    ECOMMERCE-2354
    Curt Howard

*   Minor bugfixes/improvements to Navigation Editor

    - Fix visual bug when dragging menu-item in Safari
    - Preserve active state when adding a new page to a child
    - Improve 'Drag Items Here' placeholder functionality

    ECOMMERCE-2351
    Curt Howard

*   Update main dashboard chart__summary area

    ECOMMERCE-2346
    Curt Howard

*   Add seven day interval to revenue on main dashboard

    ECOMMERCE-2360
    Matt Duffy

*   Generalize chart__summary element

    ECOMMERCE-2346
    Curt Howard

*   Merge branch 'improve/ECOMMERCE-2352-dashboard-visual-' into v2-wip
    Curt Howard

*   Improve elastic search indexing

    * Using pluck(:id) is faster than all.map(&:id), pluck won't send the
    whole document through the pipe, but only the fields needed.

    * Add options as second parameter to ProductPrimaryNavigation, so
    ProductMapper and ProductPrimaryNavigation can sure the same
    percolationin ES.

    * Add memoization to #link_for_category to cut down on database calls.

    * Change linked_categories_from to be more efficient and cut down on
    database calls.  While some clarity is lost, a large number of database
    hits are removed.

    ECOMMERCE-2348
    Eric Pigeon

*   Yield #creators within the #run method in SampleData

    This allows the developer to have full access to all of the
    core and engine sample data creators when executing #run from
    within a host app allowing deeper customization to sample
    data.

    ECOMMERCE-2357
    Mark Platt

*   Add i18n translations for flash error messages in core

    Some plain-text error messages are present in the storefront.
    Translate all core messages to avoid this issue.

    ECOMMERCE-2241
    Kristen Ward


Workarea 2.1.0.beta.2 (2016-03-24)
--------------------------------------------------------------------------------

*   Remove "What's a Release" text from releases#index

    This saves some vertical real-estate and gets more of the calendar to
    appear above the fold.

    ECOMMERCE-2345
    Curt Howard


Workarea 2.1.0.beta.1 (2016-03-24)
--------------------------------------------------------------------------------

*   Update icon--check-mark to icon--system-success

    After the check-mark icon was renamed to have a more generic use case,
    some of the markup wasn't updated to match the new name. This fixes this
    issue.

    ECOMMERCE-2344
    Curt Howard

*   Restore "Learn More" tooltip on releases#edit

    This tooltip was stripped out accidentally when the Releases Calendar UI
    was being created. This is a straight copy from the v2.0-stable branch.

    ECOMMERCE-2343
    Curt Howard

*   Moved promo codes out so that they can be used in conjunction with order total

    ECOMMERCE-2232
    MMartyn

*   Remove extraneous Search::Settings queries

    We're calling settings in the initializers of the repositories, but this isn't being used. So there is an extraneous query every time a repository is instantiated.

    ECOMMERCE-2341
    Ben Crouse

*   Add updated main admin dashboard

    ECOMMERCE-2197
    Matt Duffy

*   Improve presentation of Smart Navigation

    ECOMMERCE-2276
    Curt Howard

*   Change Chart Heading on Trending Charts to Total #

    ECOMMERCE-2332
    Curt Howard

*   Tweak Bulk Product Selection

    - Pull `.bulk-select__toggle` to the right in it's row on
      `catalog_products#index`
    - Move help text into text box on `catalog_products_bulk_update#new`

    ECOMMERCE-2259
    Curt Howard

*   Update class name for table price label

    Class name is missing prefix.

    ECOMMERCE-2229
    Kristen Ward

*   Stop all charts in row from updating when date is toggled

    ECOMMERCE-2324
    Curt Howard

*   Tweak styles for Releases Calendar

    ECOMMERCE-2311
    Curt Howard

*   Fix generic CSS rule preventing rounded borders on buttons

    A CSS rule in `generic/_reset.scss` was disallowing border-radius to be
    set on `input[type=submit]` elements. This is an issue when a `.button`
    class was applied to such elements. If `.button` is supposed to be
    rounded, those styles were not being applied properly.

    ECOMMERCE-2329
    Curt Howard

*   Add Bulk Product Editing functionality

    Introduces the ability to edit products in bulk from the
    catalog_products#index.

    ECOMMERCE-2072
    ECOMMERCE-2193
    ECOMMERCE-2314
    Adam Clarke

*   Add indexes to improve query performance

    ECOMMERCE-2325
    Ben Crouse

*   Add quantity to analytics data on add to cart

    The add to cart event is not getting the quanity
    because it is fired before form submit.

    Add the quantity attribute via JS.

    Reference RACHELROY-262 commit:
    cff0085d190

    Add unit test

    ECOMMERCE-2315
    Kristen Ward

*   Fix layout of Top Searches Dashboard card

    ECOMMERCE-2310
    Curt Howard

*   Adjust Smart Navigation Dashboard card layout

    ECOMMERCE-2309
    Curt Howard

*   Stop clearfix from inheriting border-spacing from parent

    ECOMMERCE-2323
    Curt Howard

*   Fix layout of Recent Searches Dashboard card

    ECOMMERCE-2308
    Curt Howard

*   Visually align Account Signup & Purchase Time Dashboard cards

    ECOMMERCE-2307
    Curt Howard

*   Visually align Shipping Status & Method Dashboard cards

    ECOMMERCE-2306
    Curt Howard

*   Add visual points back into line charts

    ECOMMERCE-2305
    Curt Howard

*   Fix presentation of Discounts Dashboard card

    ECOMMERCE-2304
    Curt Howard

*   Reduce sales score decay

    Previously set too aggressively, this commit backs off to set the sale half-life at a little over 6 weeks.

    ECOMMERCE-2321
    Ben Crouse

*   Update Dashboard chart colors

    ECOMMERCE-2291
    Curt Howard

*   Visually clean up Dashboard UI components

    - Dashboards are now controlled by a tabular layout to keep consistent
      heights per row.
    - The `.chart__data` element has been reworked into a tabular layout.
    - Remove half-baked grid layout constraints, accidentially merged into
      the working branch earlier.

    ECOMMERCE-2252

    Conflicts:
    	admin/app/views/workarea/admin/dashboards/_shipping.html.haml
    	admin/app/views/workarea/admin/dashboards/_smart_navigation.html.haml
    	admin/app/views/workarea/admin/dashboards/_top_categories.html.haml
    	admin/app/views/workarea/admin/dashboards/_top_discounts.html.haml
    	admin/app/views/workarea/admin/dashboards/_top_products.html.haml
    	admin/app/views/workarea/admin/dashboards/catalog.html.haml
    	admin/app/views/workarea/admin/dashboards/orders.html.haml
    	admin/app/views/workarea/admin/dashboards/people.html.haml
    	admin/app/views/workarea/admin/dashboards/store.html.haml
    Curt Howard

*   Document product template generator

    ECOMMERCE-2188
    Chris Cressman

*   Document content block type generator

    ECOMMERCE-2189
    Chris Cressman

*   Add rake task for updating dashboard data

    ECOMMERCE-2263
    Matt Duffy

*   Include all available filters in user export

    User export does not currently respect 'role' filter
    Update export form to include filter params
    Create helper method to add hidden inputs

    ECOMMERCE-2211
    Kristen Ward

*   Set default average purchase time for purchase time dashboard widget

    ECOMMERCE-2300
    Matt Duffy

*   [NO SQUASH] Remove Payment Method dashboard

    Removal of the Payment Method dashboard, for later inclusion.

    ECOMMERCE-2255
    Curt Howard

*   Add Dashboards for Store, Catalog, Order, and People

    Provides Dashboard Charts for the Store, Catalog, Order, and People
    sections of the Admin.

    ECOMMERCE-2125
    ECOMMERCE-2070
    ECOMMERCE-2129
    ECOMMERCE-2126
    ECOMMERCE-2171
    ECOMMERCE-2255
    Curt Howard

*   ECOMMERCE-2292: Update ratio to match new function
    Steve Perks

*   Visually improve Releases Dashboard Calendar

    - Remove modernizr-(no)-js classes from CSS, feature now requires
      JavaScript
    - Add timestamp to Release indicator
    - Suffix Month name with the year to lessen confusion when browsing
    - Align Release Dashboard aside to top of calendar
    - Fix styling of Unscheduled Releases
    - Align Month & Year to left of calendar day
    - Stop releases from spanning outside of the calendar day

    ECOMMERCE-2163
    Curt Howard

*   Clean up content block type generator

    ECOMMERCE-2289
    Matt Duffy

*   ECOMMERCE-2292: update media-ratio math to provide correct padding.
    Steve Perks

*   Don't bother with rack protections in test or development

    This is a nuisance for slow machines or development where many requests are required. Since it doesn't provide any value in test or development, don't insert the middleware.

    ECOMMERCE-2256
    Ben Crouse

*   Display sales score on inventory and product edit

    Since we're showing this on navigation links now, it makes sense to give visibility into this everywhere.

    ECOMMERCE-2267
    Ben Crouse

*   Fix broken inquiry mailer

    Update method call in preview

    ECOMMERCE-2237
    Kristen Ward

*   Add user email address to export csv

    Email address is missing from exports.
    Add user.email column after user.id

    ECOMMERCE-2283
    Kristen Ward

*   Add '--has-children' modifier to navigation helper

    This commit adds:

    - `.primary-nav__menu-item--has-children`
    - `.secondary-nav__menu-item--has-children`
    - `.mobile-nav__menu-item--has-children`

    ECOMMERCE-2272
    Curt Howard

*   Move product template generator to core, clean up

    ECOMMERCE-2183
    Matt Duffy

*   Fix relative path output in sharing email

    This was broken by the security fix for a XSS vulnerability. This fix also adds a helper to create the full URL for a given path in a mailer.

    ECOMMERCE-2281
    Ben Crouse

*   Update product browse mapping, restore created_at

    Field was removed erroneously, is necessary for product sort

    ECOMMERCE-2157
    Kristen Ward

*   Move required attr on cvv field from label to input

    The `required: true` attribute is incorrectly located on the label.
    Move it to the input.

    ECOMMERCE-2206
    Kristen Ward

*   Remove trailing new lines in code blocks

    Improve visual appearance of code blocks in guides.
    Decorate haml code filter used by middleman syntax plugin.
    Create mixin to strip newlines from code before syntax highlighting.

    ECOMMERCE-1963
    Kristen Ward

*   change redirect after pricing edit via product edit

    ECOMMERCE-1864

    add and fix tests for pricing administration

    ECOMMERCE-1864

    Use the correct spelling of referrer

    ECOMMERCE-1864
    Adam Clarke

*   Update fields in browse product mapping

    Remove unused fields for clarity

    ECOMMERCE-2157
    Kristen Ward

*   Add help tooltip for CSV formatting

    Prevent errors resulting from illegal quotes by providing
    an inline explanation of how to escape special characters.

    ECOMMERCE-2151
    Kristen Ward

*   Add rack attack for blocking and throttling abusive requests

    Include rack-attack out of the box to protect sites from bots or other abusive request patterns. We use the recommended configuration by the gem, but allow tech leads to configure it as needed.

    ECOMMERCE-2256
    Ben Crouse

*   Add messaging to storefront for packages with no tracking number

    ECOMMERCE-2238
    Matt Duffy

*   Add accessibility improvements to product edit form

    Add labels where missing
    Add descriptive text to clear button

    Update spec

    ECOMMERCE-1539
    Kristen Ward

*   Add "Communicate with Elasticsearch" guide

    ECOMMERCE-2190
    Chris Cressman

*   Fix decorator load order when cache_classes = true

    Decorators are being loaded in a different order in different
    environments. The root cause is the cache_classes logic that is removed
    in this commit. I'm unable to determine why this was there in the first
    place, so this change terrifies me. I'm not even sure we should be
    releasing it as patch, as it has the potential to break apps that were
    depending on the inconsistency.

    It's basically impossible to test due to a changing Rails
    environment.

    ECOMMERCE-2216
    Ben Crouse

*   Remove use of Mongoid field check methods on localized fields

    ECOMMERCE-2147
    Matt Duffy

*   Update fulfillment mailer preview to show items

    Correct the hash sent to FulfillmentMailer.canceled

    ECOMMERCE-1924
    Kristen Ward

*   Ensure shipped items with no tracking number are displayed properly

    ECOMMERCE-2238
    Matt Duffy

*   Update Payment Integration guide

    ECOMMERCE-2079
    Matt Duffy

*   Prevent quantity values lower than 0 for inventory skus

    Add minimum value attribute to quantity fields

    ECOMMERCE-2078
    Kristen Ward

*   Update dashboard revenue graph time segments

    When viewing revenue graph for 7-90 day date periods, the times
    start and end in 24 hour intervals back from the present time. This
    causes confusion around the reported values for that time segment.

    Update revenue graph so that time segments start at 12:00 am
    and end at 11:59 pm.

    Clean up dashboard view via helper, remove multiple calls to Time.now

    Increase 7-90 day range end times to end of current day, so that
    step is consistent and revenue totals accurate. date ranges include
    the full current day.

    ECOMMERCE-2123
    Kristen Ward

*   Fix XSS vulnerability with email sharing

    By outputting the URL directly passed from the query string, we open the possibility of a JavaScript URL (e.g. javascript:netsparker(0x006 A24)). This commit fixes this by sanitizing the URL in the model, and using that sanitized version in the view.

    ECOMMERCE-2227
    Ben Crouse

*   Pass the options from cart view model to order item view model

    SIs have needed information from #view_model_options in the order item
    view model and it's more consistent.

    ECOMMERCE-2091
    Eric Pigeon

*   Fix Order and User date filter links in admin menu

    Change params to iso8601 strings to prevent NaN errors
    in certain browsers (safari, ie)

    Add end dates to update datepicker link text

    ECOMMERCE-2121
    Kristen Ward

*   Make page logo consistent size across browsers

    Add block display to anchor element

    ECOMMERCE-1892
    Kristen Ward

*   Add filtering by placed at date to orders index

    This improvement gives user a way to gauge revenue for a given
    timeframe from the orders index page, addressing a point of
    confusion for some users.

    Add date range picker for placed at
    Update query, mapper, export parameters, and orders spec

    ECOMMERCE-2120
    Kristen Ward

*   Add Smart Navigation sorting to Navigation Menus

    Navigation Items in each level of the navigation are able to be sorted
    Alphabetically or by "Sales Score".

    The look-and-feel of this feature has been updated.

    This commit is breaking. The following front-end files have been
    modified:

    - admin/app/assets/javascripts/workarea/admin/modules/menu_editor_links.js
    - admin/app/assets/javascripts/workarea/admin/modules/menu_editor_menu_list_sortables.js
    - admin/app/assets/stylesheets/workarea/admin/components/_menu_editor.scss
    - admin/app/views/workarea/admin/navigation_links/_link.html.haml
    - admin/app/views/workarea/admin/navigation_links/children.html.haml
    - admin/app/views/workarea/admin/navigation_menus/edit.html.haml

    ECOMMERCE-2198
    Curt Howard

*   Add rake task to show listener definition location

    Adds `rake workarea:listeners` to show method and class definition locations for workarea listeners.

    ECOMMERCE-2213
    Thomas Vendetta

*   Add loading indicator translation to style guides

    ECOMMERCE-1302
    Kristen Ward

*   Update elasticsearch install instructions

    Several elasticsearch packages were removed from the default Homebrew
    package repository, which invalidated our elasticsearch installation
    instructions. We responded by creating our own Homebrew package
    repository to host those packages.

    Update development environment guide to suggest the use of the Workarea
    Homebrew tap and suggest version 1.5 of elasticsearch since that's the
    version we currently use in Production environments.

    ECOMMERCE-2210
    Chris Cressman

*   Document sample data generator

    ECOMMERCE-2143
    Chris Cressman

*   Document pricing calculator generator

    ECOMMERCE-2149
    Chris Cressman

*   Document discount generator

    ECOMMERCE-2148
    Chris Cressman

*   Change release calendar functionality to week-view

    This work changes the release calendar from a traditional calender to a
    browse-by-week calendar. The calendar now shows one previous week, the
    current week, and two following weeks.

    ECOMMERCE-2208
    Curt Howard

*   Add instructions and help page for CSV imports

    ECOMMERCE-2200
    Ben Crouse

*   Add integration spec to ensure recommendations being output

    ECOMMERCE-2199
    Ben Crouse

*   Fix checkout addresses view model to always return a shipping address when asked

    This is a more robust fix, with a cheaper test.

    ECOMMERCE-2215
    Ben Crouse

*   Check if shipping_address.errors should display

    When an order doesn't require shipping current_checkout#shipment is nil.
    Storefront::Checkout::AddressesViewModel#shipping_address calls
    shipment.address. The addresses.html.haml view properly checks if
    order_requires_shipping? except when outputting errors. Without
    javascript and digital only products, submitting an invalid billing
    address breaks the application.

    ECOMMERCE-2215
    Eric Pigeon

*   Improve algorithm for email recommendations

    This switches from using the same personalized results on the storefront to the following fallback system:

    1) Products also purchased with products in this order, sorted by sales

    2) Related products to products in the order

    3) Top sellers

    ECOMMERCE-2199
    Ben Crouse

*   Update ContentBlockTypeGenerator for new APIs

    After some changes were made to the way we test and implement generators
    on the Workarea platform, the ContentBlockGenerator looked a bit
    out-of-date. This updates the generator for the new APIs and renames it
    to ContentBlockTypeGenerator, to better reflect what it's actually
    creating.

    - Rename ContentBlockGenerator to ContentBlockTypeGenerator
    - Don't generate sample data in ContentBlockTypeGenerator.
    - Use the new `Plugin.append_stylesheets` method to append the newly
      generated stylesheet.
    - Modify ViewModel template to implement +locals+.

    Fixes ECOMMERCE-2184
    Tom Scott

*   Adjust step size for revenue graph with small amounts of data

    If the graph has less than 6 minutes of data, make the step size
    equal to the amount of available time. Once the available time
    hits 6 minutes, the step size returns to 3 minutes.

    ECOMMERCE-2180
    Kristen Ward

*   Add recommendations to transactional emails

    ECOMMERCE-2199
    Ben Crouse

*   Add translated text to loading indicator for non-visual users

    ECOMMERCE-1302
    Kristen Ward

*   Add overflow scrolling to admin menu, prevent overlap with WL logo

    Menu stays fixed behind workarea logo when window size is too small.
    Add overflow scrolling to prevent this.

    ECOMMERCE-1569
    Kristen Ward

*   Loosen changelog generation commit filtering

    This changes changelog generation to allow reverts and merges where a ticket number is present.

    ECOMMERCE-2185
    Ben Crouse

*   Allow navigation link clone attributes to be configurable

    ECOMMERCE-2207
    Ben Crouse

*   Generate Order Reports

    listen for an order placed or fulfillment updated to create an
    OrderReport that extracts relevant data from an order to allow for
    simple aggregation of the data for reporting on dashboards.

    ECOMMERCE-2169
    Matt Duffy

*   Document style guide generator

    Add "Create a Style Guide" guide and update "Release Notes" guide.

    ECOMMERCE-2080
    Chris Cressman

*   Add first-iteration smart navigation functionality

    ECOMMERCE-2128
    Ben Crouse

*   Add order indexes to support reminder and recently updated workers

    ECOMMERCE-2164
    Ben Crouse

*   Use generated changelog in guides

    ECOMMERCE-1356
    Ben Crouse

*   Add link from catalog_products#index to import_catalog#new

    ECOMMERCE-2047
    Curt Howard

*   Add indexes to support the UpdateProductSalePrice worker

    ECOMMERCE-2060
    Ben Crouse

*   Always include User-Agent specification in robots.txt

    Some validators are fine with this, some aren't. Better to play this on the safe side.

    ECOMMERCE-2177
    Ben Crouse

*   Add autoloading of sample data creators in host app

    This makes sample data customization far simpler. Hopefully, people will embrace this, and start using the sample data rake task for their projects.


    ECOMMERCE-2173
    Ben Crouse

*   Clean up/standardize generator implementations and testing

    After being worked on by different people and implemented and tested
    inconsistently, this work makes several changes:

    *   Remove need for generator_spec. The tests for serveral of the generators
        wasn't actually testing anything because this gem has some bugs. I've fixed
        the "broken" tests.

    *   Simplify content block generator spec to remove some of the excessive
        complication. Lost functionaly will be made up for with new functionality
        where the sample data creation automatically loads sample data classes from
        host application.

    *   Hack around the annoying missing bin/rails message. This was happening
        because of the discount generator, which calls another generator.

    ECOMMERCE-2144
    Ben Crouse

*   Fix floating page footer issue with Pagination

    - Swap `pushState` with `replaceState`
    - Unset `.view` height when window is resized

    ECOMMERCE-2004
    Curt Howard

*   Fix quickview 'Read More' link error

    Route is being interpreted incorrectly from quickview,
    resulting in a scrambled URL.

    Specify params hash for link in truncated product description helper

    Add test for truncate product description helper

    Include url helpers in product helper spec

    ECOMMERCE-2064
    Kristen Ward

*   Fix i18n spec for host application compatibility

    I18n spec is incompatible with host applications whose
    config.i18n.enforce_available_locales is set to true.
    Update spec to set available locales per i18n documentation.

    ECOMMERCE-2008
    Kristen Ward

*   Clean up openDrawer function call

    drawer.js call includes unnecessary options hash

    ECOMMERCE-2150
    Kristen Ward

*   Add expiration of cache for collection queries

    ECOMMERCE-1740
    Matt Duffy

*   Improve UpdateProductSalePrice worker

    the query to determine which products require an update returns
    the correct set of products. Products are only affected one and
    touched to ensure caches are cleared for affected products.

    ECOMMERCE-2060
    Matt Duffy

*   Fix discounts granted to orders with empty items

    This additional rule is a guard against granting discounts when an
    order doesn't have any relevant items. For example, don't give
    free shipping if the discount is set to ignore sale items and
    there are only sale items in the order.

    ECOMMERCE-2154
    Ben Crouse

*   Specifically sort the order of style guide partials alphabetically

    Although the default order appears to be correct, newly added
    style guide partials are added to the end of the list.

    Add explicit call to sort method on partials array.

    ECOMMERCE-1941
    Kristen Ward

*   Ensure ApplicationGroup#value always returns Money object

    Most valuable application group is being incorrectly determined
    in cases where shipping or other discounts not containing
    price adjustments do not return a Money value

    Add test and fix from commit 09f64a691e2 (YARN-148)

    ECOMMERCE-2085
    Kristen Ward

*   Don't set cache=false cookie unless the user is an admin

    Setting this cookies causes rack-cache to be skipped. Skipping
    the rack-cache for non-admins doesn't do anything but hurt
    performance.

    ECOMMERCE-2113
    Ben Crouse

*   Add generator for new discounts

    Generates a new `Pricing::Discount` model, `Admin::Discounts` view
    model, and the proper Haml admin views for editing the new discount.
    This generated code is intended to be extended when needed by the
    developer, and provides inline comments to aid the developer in creating
    a discount model.

    ECOMMERCE-2107
    Tom Scott

*   Add generator for pricing calculators.

    Generates a new `PricingCalculator` model for making price adjustments
    in accordance with http://guides.workarea.com/customize-pricing.html.

    ECOMMERCE-2138
    Tom Scott

*   Update description of branching strategy in guides

    ECOMMERCE-2117
    Chris Cressman

*   Include order item details in free gift item data

    SIs have reported that some 3rd party services require all order items
    to include certain information including product name.
    Merge order item details into order items created by the free gift discount
    if product details are available. Add feature test for functionality.

    ECOMMERCE-1959
    Kristen Ward

*   Add boilerplate jsdoc comments to module generator

    ECOMMERCE-1964
    Kristen Ward

*   Fix issue with release calendar browsing

    Rails understands the EDT time zone but cannot have it's `Time.zone` set
    to EDT. This fix uses the determined UTC offset as the server's time
    zone.

    ECOMMERCE-2092
    Curt Howard

*   Add SampleData generator

    This generator adds a new sample_data script, which is used to generate
    custom sample data for Workarea applications. Sample data is usually used
    in the development and testing phases, but can also be used to seed the
    database in non-local deployments of the app.

    ECOMMERCE-2108
    Tom Scott

*   Fix context-menus within model-summaries

    A previous fix was applied to ensure that `context-menu` components
    found within `model-summary` components wouldn't cause the entire page
    to have a long horizontal scroll. The fix unfortunately trimmed off the
    `context-menu` when it was expanded. This patch fixes the issue
    correctly.

    ECOMMERCE-2093
    Curt Howard

*   Fix style guide generator

    - Prefix partial path with an underscore
    - Allow page to be rendered without error

    ECOMMERCE-1736
    Curt Howard

*   Prevent invalid filter form submissions on product edit page

    Users are reporting difficulty adjusting values in the 'edit view filters'
    section of the product form once the form comes back with errors. Add client-
    side validation to prevent form submissions which include the keyword 'type'.

    ECOMMERCE-1989
    Kristen Ward

*   Fix home base pinging

    Two problems addressed here: unsigned certs and pinging home base
    before the app's initializers have run.

    ECOMMERCE-2109
    Ben Crouse

*   give content block generator templates .erb extension

    ECOMMERCE-2106

    hopefully this appeases Tailor
    Adam Clarke

*   Allow decorating of parent and child classes

    Decorating a parent and child class can cause errors depending on the
    order the decorators are loaded.  When the parent class is decorated
    first, the decoration of the child class will thrown an error from
    inheriting the prepended module.  By added the target name to the
    generated modole parent and child decorations will not name clash.

    ECOMMERCE-1633
    Eric Pigeon

*   add generator for custom product templates

    ECOMMERCE-2015

    add template name to workarea config file

    ECOMMERCE-2015

    add templates for product template partial and view model

    ECOMMERCE-2015

    Update gnerator usage and add messaging to generated files

    ECOMMERCE-2015

    add specs and minor adjustments for product template generator

    ECOMMERCE-2015

    add ammeter for generator specs (dupe from ecom-2016)

    ECOMMERCE-2015

    adjustments to make product template generator specs pass

    ECOMMERCE-2015

    specs for skipping product template generator view model

    ECOMMERCE-2015

    remove product template view

    ECOMMERCE-2015
    Adam Clarke

*   Add custom content block generator

    ECOMMERCE-2016

    * generate content block type config
    * add init switch for creating files before inserting
    * generate view templates
    * add content block stylesheet generator
    * applying cressman's pull request feedback
    * rename sample data rake task
    * add tests for content block generator
    * update USAGE for content block generator
    Adam Clarke

*   Add missing 'Dependencies' append to JS manifests

    Previously plugins were unable to append 3rd Party libraries to the
    manifest.

    ECOMMERCE-2094
    Curt Howard

*   ECOMMERCE-2083: Add append points for navigation content
    Steve Perks

*   Fix image_url in product CSV imports

    Dragonfly insists on calling save on the model (not its parent) so when
    creating the image, this changes to call create and persist immediately.

    ECOMMERCE-1974
    Ben Crouse

*   Allow product template to be blank in CSV imports

    The importer will default the value to generic.

    ECOMMERCE-1974
    Ben Crouse

*   Fix duplicate data in CSV import updates

    ECOMMERCE-1974
    Ben Crouse

*   Add Style Guide Generator

    ECOMMERCE-1736
    Curt Howard

*   Add Releases Dashboard

    This commit is entirely breaking:

    - deleted:    admin/app/assets/images/workarea/admin/activate_with_release.png
    - deleted:    admin/app/assets/images/workarea/admin/create_new_release.png
    - deleted:    admin/app/assets/images/workarea/admin/publish_release.png
    - deleted:    admin/app/assets/images/workarea/admin/save_changes_with_release.png
    - deleted:    admin/app/assets/javascripts/workarea/admin/modules/releases_timelines.js
    - deleted:    admin/app/assets/stylesheets/workarea/admin/components/_releases_timeline.scss
    - deleted:    admin/app/views/workarea/admin/releases/timeline/_future.html.haml
    - deleted:    admin/app/views/workarea/admin/releases/timeline/_past.html.haml
    - deleted:    docs/admin/source/releases-timeline.html.haml
    - modified:   admin/app/assets/stylesheets/workarea/admin/application.scss.erb
    - modified:   admin/app/assets/javascripts/workarea/admin/application.js.erb
    - modified:   admin/app/controllers/workarea/admin/releases_controller.rb
    - modified:   admin/app/views/workarea/admin/releases/index.html.haml
    - modified:   admin/spec/features/releases_spec.rb

    ECOMMERCE-2020
    Curt Howard

*   Prevent nil comparison error from occurring in product editor

    Amends previous commit af8e2ef3764 which allowed the one_price?
    	method to compare nil values with dollar amounts

    ECOMMERCE-1865
    Kristen Ward

*   Document the import catalog from CSV feature

    ECOMMERCE-2054
    Chris Cressman

*   Remove invalid user parameter from permit list

    ECOMMERCE-2033
    Kristen Ward

*   Fix arguments count error in search generator

    Remove splat from add_set method

    Reference Baudville commit 64e390b2ba0

    ECOMMERCE-2053
    Kristen Ward

*   Disallow reserved word 'type' in product filter keys

    Add validation to product model

    Flash error message on failure

    Add unit test for validation, clean up test

    ECOMMERCE-1989
    Kristen Ward

*   Change lint output to CSV so output is easier to process

    ECOMMERCE-1974
    Ben Crouse

*   Set default nil value on ProductBrowse popularity

    If popularity comes back as NaN then ElasticSearch
    indexes it as a null value and raises an error:
      `Missing value for field [popularity]`

    This causes search queries to return 500 errors.

    ECOMMERCE-2034

    Fixes: STILA-338
    Thomas Vendetta

*   Add category queries to product browse repo from rake task

    Ensure category percolator queries are added when product browse
    is re-indexed.

    ECOMMERCE-2045
    Matt Duffy

*   Fix truncated description scroll_to_button bug

    The `anchor` param being passed to the route helper was being improperly
    merged into the options hash. This commit separates this param from the
    other options passed to the helper.

    ECOMMERCE-1994
    Curt Howard

*   Fix layout of admin's main dashboard

    The model summaries at the bottom of this page were pushing the page out
    to 99999px due to the way model summary responds to certain types of
    layouts.

    ECOMMERCE-2005
    Curt Howard

*   Add append point for discount conditions

    ECOMMERCE-2003
    Kristen Ward

*   ECOMMERCE-2037: Prevent error on checkout that happens when inventory sku backorder value gets saved as nil
    Bob Clewell

*   Fix usage of legacy write option, prefer j: true instead

    fsync doesn't do anything in Mongoid 5, this was missed in the upgade.
    Using j: true achieves what we want. See details here:
    https://docs.mongodb.org/manual/reference/write-concern/#wc-j

    ECOMMERCE-2039
    Ben Crouse

*   Add translations for authentication flash messages

    In the `Workarea::Authentication` controller concern, the flash messages
    displayed when a user is not logged in (or a user must be logged out)
    are not translated, and thus result in English text appearing no matter
    what locale has been set. This change copies the hard-coded flash
    message text from `Workarea::Authentication` into the core english locale
    file, and replaces the text with calls to `I18n.t`.

    ECOMMERCE-2000

    Adapt from v0.11 commit

    Conflicts:
    	core/config/locales/en.yml
    	core/lib/workarea/authentication/controller.rb
    Tom Scott

*   Document rake:workarea:lint

    ECOMMERCE-1991
    Chris Cressman

*   Update description of branching strategy in guides

    Update the contributing guide to reflect the latest product team
    branching strategy. Link to this from the plugin maintenance guide
    to avoid duplicating the information.

    ECOMMERCE-2007
    Chris Cressman

*   Add flat file (CSV) importing classes and admin UI

    The goal with this code is to provide easier data structure targets for
    importing into the system. Additionally, we expose this in the admin for easier
    demoing and product data management.

    Merge branch 'feature-flat-file-uploads' into v2-wip

    ECOMMERCE-1974
    Ben Crouse

*   ECOMMERCE-2028: Add append point to each admin toolbar.
    Mark Platt

*   a real test for the shipping method rate update feature

    ECOMMERCE-1926
    Adam Clarke

*   ECOMMERCE-2032: stub method only when it is defined on class for
    set_current_user helper method
    fgalarza

*   Fix Free Gift discounts

    Correct logic preventing free gifts from having a discount
    value and correctly qualifying for an order.

    ECOMMERCE-1990
    Matt Duffy

*   Merge branch 'v2-wip' of ssh://stash.tools.workarea.com:7999/wl/workarea into bugfix/ECOMMERCE-1926-changing-shipping-method-rate-breaks-checkout
    Adam Clarke

*   prevent blank shipping rate teir range from being saved

    ECOMMERCE-1926
    Adam Clarke

*   Properly implement heading pattern in CSS

    The previous heading solution actually went against the architecture,
    but by introducing a `heading` mixin we are able to provide congruency
    between the `base/_headings.scss` file and the `trumps/_heading.scss`
    file.

    - `$heading-1-font-size` through `$heading-6-font-size` variables have
      now been compressed into a `$heading-font-sizes` Sass map variable.
    - `core/trumps/_heading.scss` has been replaced by unique `storefront`
      and `admin` `trumps/_heading.scss` files.
    - `heading` style guide entry updated

    ECOMMERCE-1992
    Curt Howard

*   ignore zero quantity items passed to `Fulfillment#ship_items`

    ECOMMERCE-1910
    Adam Clarke

*   Add worker to update sale products

    To prevent product indexes from being stale when pricing skus
    go on/off sale, a worker runs every 15 minutes to update the
    index of products associated with pricing skus that have changed
    sale status since the last window.

    ECOMMERCE-1862
    Matt Duffy

*   Display pricing regardless of inventory in admin

    Create new pricing collection which includes all variant pricing

    Add show_sell_range? and one_price? methods specific to admin
    from storefront, add unit tests

    ECOMMERCE-1865
    Kristen Ward

*   Display correct messaging for redeemed single use promo codes

    Use commit 6b9f0d74df5

    Add test for error message for redeemed single use promo codes

    ECOMMERCE-1752
    Kristen Ward

*   Add worker to update sale products

    To prevent product indexes from being stale when pricing skus
    go on/off sale, a worker runs every 15 minutes to update the
    index of products associated with pricing skus that have changed
    sale status since the last window.

    ECOMMERCE-1862
    Matt Duffy

*   Add `rake workarea:lint` to lint the current implementation

    The base implementation checks current data for possible problems to help with
    data integrations. We can expand the use of the workarea:lint rake task in the
    future to include code introspection as well.

    To add a custom linter from either a project or plugin, simply drop a file in
    the lib/workarea/lint directory, and define a class that inherits from
    Workarea::Lint in that file. See core/lib/workarea/lint for examples.

    ECOMMERCE-1974
    Ben Crouse

*   Remove another deprecated scheduled task

    The import code has been removed for v2.0 so it can be moved to a plugin.

    ECOMMERCE-1986
    Ben Crouse

*   Remove deprecated scheduled task

    The import code has been removed for v2.0 so it can be moved to a plugin.

    ECOMMERCE-1986
    Ben Crouse

*   Update export parameter for order status

    ECOMMERCE-1779
    Kristen Ward

*   Update admin main navigation order filtering links

    ECOMMERCE-1778
    Kristen Ward

*   change order package(parcel) headings on storefront

    ECOMMERCE-1910
    Adam Clarke

*   Update plugin template mongoid config

    ECOMMERCE-1983
    Kristen Ward

*   Apply changes for segmentation plugin

    Pricing::Collection#for_sku passes options through to Pricing::Sku,
    and the discount edit form has append points for new conditions.

    ECOMMERCE-1981
    Matt Duffy

*   Add teaspoon test for dialog.js

    `WORKAREA.url` now contains two new methods:

    - `WORKAREA.url.current()` gets the current `window.location.href` value
    - `WORKAREA.url.redirectTo(url)` sets the current `window.location` value

    Because of the protected nature of the `window` host object, these
    methods were needed to be able to stub their return values in tests.
    They also serve as helpful aliases for developers.

    ECOMMERCE-1807
    Curt Howard

*   Update typecast spec examples with current year

    Use in examples where year is unspecified or unknown
    (additional/I18n, time formats)

    ECOMMERCE-1967
    Kristen Ward

*   Fix cloning bug in `WORKAREA.drawer.createFromFragment`

    `createFromFragment` was passing a jQuery object to the `create` method,
    which expects a String containing the HTML content that should be
    displayed.

    This commit also satisfies jshint warnings in `drawer.js` and
    `drawer_buttons.js` and fixes a typo in the thrown exception within
    `WORKAREA.drawerButtons.handleOpenAction`.

    ECOMMERCE-1968
    Curt Howard

*   Update release notes for v2.0

    ECOMMERCE-1883
    Ben Crouse

*   Fix bug to close mobile nav drawer when clicking X button

    Due to the recent refactor of `WORKAREA.drawer` and the way
    `WORKAREA.mobileNavChildMenus` replaces the default actions for the
    drawer used by the mobile navigation, attempting to close the drawer by
    clicking the X button began to throw an error.

    This was fixed by explicitly binding each button's action when the
    mobile nav drawers actions are replaced.

    When using a custom `readyEvent` in the drawer module, the originating
    `$source` object is now passed along to the event handler, which is
    helps to bridge the API gap between a module that customizes the default
    drawer offering and the drawer module itself.

    ECOMMERCE-1969
    Curt Howard

*   reset publish_at when publishing a release

    In order to ensure that scheduled releases that have been published
    show up in the list of archived/completed releases, the `publish!`
    method no longer checks wether or not the `publish_at` date is in the
    future.

    ECOMMERCE-1923
    Adam Clarke

*   Update base to be compatible with Modernizr v3:

    Modernizr v3 released and officially dropped support for v2. The upgrade
    from v2 to v3 causes some breaking changes in our platform, namely:

    - To utilize the `.no-js` class hook alongside a custom prefix, the
      class hook must be renamed `.modernizr-no-js`
    - The `.modernizr-(no-)touch` test has been renamed to
      `.modernizr-(no-)touchevents`

    This commit sees these modifications in base, along with the dependent
    version of `workarea-modernizr-rails` bump to v2.0.0.

    ECOMMERCE-1961
    Curt Howard

*   Add explicit dependency on sprockets-rails 2

    sprockets-rails 3 was released Dec 17 and is incompatible with Workarea.
    Since we don't specify an explicit dependency on sprockets-rails,
    Bundler is resolving to sprockets-rails 3, which prevents the app from
    starting.

    Add an explicit dependency on sprockets-rails 2 to resolve the issue.

    ECOMMERCE-1960
    Chris Cressman


Workarea v2.0.0 (2015-12-17)
--------------------------------------------------------------------------------

*   Fix alignment of date-range-pickers in dialogs

    ECOMMERCE-1937
    Curt Howard

*   Update guides for new sample data

    ECOMMERCE-1860
    Ben Crouse

*   Prevent page layout from cascading content-box & more:

    Fix icon mixin documentation

    Bump margin of page messages

    Fix value `p` tag use case

    ECOMMERCE-1958
    Curt Howard

*   Consolidate sample data requiring in the sample data file

    This makes it simpler for a build to require sample data for
    customizing data.

    ECOMMERCE-1860
    Ben Crouse

*   Make admin index filters compatible with sort

    Add test for sorting with filters applied

    ECOMMERCE-1776
    Kristen Ward

*   Remove email signup popup

    This will be moved into a plugin for future support

    ECOMMERCE-1957
    Ben Crouse

*   Add more system content sample data

    This reflects more of what the system offers out of the box

    ECOMMERCE-1860
    Ben Crouse

*   Add append point for user context menu

    ECOMMERCE-1877
    Matt Duffy

*   Separate system content from dynamic content in sample data

    This will allow a build to more gracefully customize system data
    without need to decorate/override all the dynamic data loading code.

    ECOMMERCE-1860
    Ben Crouse

*   Limit sample data category names to 2 words

    ECOMMERCE-1860
    Ben Crouse

*   Rename marketing pages to browsing pages

    This helps connect the fact that those sample data pages will
    end up in the browsing navigation.

    ECOMMERCE-1860
    Ben Crouse

*   Ensure sample data pages have unique names

    ECOMMERCE-1860
    Ben Crouse

*   Use faker data in shares sample data

    ECOMMERCE-1860
    Ben Crouse

*   Fix yield return value logic for determining search template

    ECOMMERCE-1931
    Ben Crouse

*   Improve sample data generator

    This commit reduces the complexity of the sample data generation as well
    renaming it to reduce confusion with rails generators. Decoupling the
    individual pieces of sample data will make it easier to implementations
    to override individual parts for their build.

    We've also switched to using Faker as much as it makes sense to.

    ECOMMERCE-1860
    Ben Crouse

*   Change presentation of navigation_menus#edit dialog

    ECOMMERCE-1691
    Curt Howard

*   Document CSS Architecture

    ECOMMERCE-1880
    Curt Howard

*   Ensure product results are shown when filtering search

    The search results were displaying content when filters would narrow
    the product results below the number of content results. This prevents
    the defaulting to content search when product filters are present.

    ECOMMERCE-1931
    Matt Duffy

*   Add discount application group calculation

    To fix incorrect discount calculation based on calculation ordering, we need to
    calculate each combination of discounts to determine the best value. These
    value calculations are each done and then undone and the best valued discount
    group is applied.

    ECOMMERCE-1866
    Ben Crouse

*   Rename vertical-rhythm -> visual-rhythm

    ECOMMERCE-1933
    Curt Howard

*   Move visually-hidden trump styles to payment-icon

    ECOMMERCE-1933
    Curt Howard

*   Ensure shipping option is valid on address update

    There were scenarios in which a shipping method could be selected,
    and then later become invalid when the user changed their shipping
    address. They could then skip over the shipping step and retain
    the now invalid shipping options.

    This fix ensures on address save that the selected shipping option
    is still valid.

    ECOMMERCE-1927
    Matt Duffy

*   ECOMMERCE-1860: remove specific data from page queries
    Adam Clarke

*   Remove "Change Version" menu from guides

    ECOMMERCE-1935
    Chris Cressman

*   Fix category rules preview 412 Error

    ECOMMERCE-1916
    Curt Howard

*   Specify Elasticsearch version in dev environment guide

    Provide more helpful information about the versions and Homebrew
    packages for Elasticsearch and PhantomJS.

    ECOMMERCE-1934
    Chris Cressman

*   Fix visual bugs in admin:

    Fix alignment of Sort By menus within index-filters

    Remove negative margin from search-form icon

    Fix visibility issue with context-menu

    Fixes alignment issue with context-menu

    Updates icon mixin documentation, removes rendered CSS examples

    ECOMMERCE-1932
    Curt Howard

*   Fix autocompletion not matching on partial words

    This was because of the ES query type. This commit changes to use a
    prefix match like the jump to functionality if the request is xhr.

    ECOMMERCE-1928
    Ben Crouse

*   Add separate translations for html/text email areas

    ECOMMERCE-1794
    Kristen Ward

*   Add icon for Pricing and Inventory Links in Variants

    ECOMMERCE-1929
    Curt Howard

*   ECOMMERCE-1860: remove data dependencies from category queries
    Adam Clarke

*   Fix query parameter length for Category UI preview

    When a Category rule is added or modified the Category UI preview
    updates by submitting the serialized data of the surrounding form. When
    there are many manual products saved for a Category, the query string
    becomes very long, potentially causing a 412 server error.

    This commit removes the manual product IDs from the `$.get` request,
    since they are not needed to properly render the rule-based preview.

    ECOMMERCE-1916
    Curt Howard

*   Rename model method for accuracy

    ECOMMERCE-1556
    Ben Crouse

*   Update content block guides

    ECOMMERCE-1678
    Chris Cressman

*   ECOMMERCE-1922: Fixes typo in search spec
    Dave Barnow

*   Fix Category UI Preview when no rules are present

    ECOMMERCE-1918
    Curt Howard

*   Hide unwanted page headings instead of removing them

    Don't allow admins to remove the H1 from a content page. Visually hide
    it instead. This will prevent admins from unwillingly harming SEO.

    Duplicate H1s are unlikely since the HTML content block is the only type
    that allows adding an H1 to the page's content. A missing H1 is
    therefore the bigger risk.

    ECOMMERCE-1556
    Chris Cressman

*   Fix alignment of form controls when invalid

    When jQuery Validate applied the class `.value__error` to the
    `.text-box` component it also applied a `display: block` property value,
    which broke the tabular layout in the admin. This fix conditionally
    styles labels differently from text boxes.

    Comments have been improved for both engine's `.value` components as
    well.

    ECOMMERCE-1908
    Curt Howard

*   Add render H1 toggle to content pages

    This removes the need for H1 management in templates and allows us to
    remove the landing template since after this change, it provides no value.

    ECOMMERCE-1556
    Ben Crouse

*   Fix overflow issue with autocomplete within ui-dialog

    ECOMMERCE-1906
    Curt Howard

*   Fix selected state of asset picker radio button

    ECOMMERCE-1899
    Curt Howard

*   Remove segmentation

    ECOMMERCE-1913
    Ben Crouse

*   Consolidate config so it's all in one place

    ECOMMERCE-1584
    Ben Crouse

*   Move default configuration into its own file

    ECOMMERCE-1584
    Ben Crouse

*   Move initializers into their own files

    ECOMMERCE-1584
    Ben Crouse

*   Don't spell-correct based on products if there are content results

    ECOMMERCE-1834
    Ben Crouse

*   Exclude digital products from fulfillment items

    Add listener spec

    ECOMMERCE-1598
    Kristen Ward

*   Fix Load More Results button placement in pagination

    ECOMMERCE-1905
    Curt Howard

*   Fix items with 0 pending quantity

    Previously item ids would be included in the pending hash with 0, which
    is extraneous and/or irrelevant info.

    ECOMMERCE-1903
    Ben Crouse

*   Render the layout for XHR requests if layout=true

    This allows XHR requests to be made with the full layout while still
    considered XHR requests from the server's perspective. This is in
    contrast to removing the X-Requested-With header.

    ECOMMERCE-1854
    Ben Crouse

*   Patch dialog fragment to remove X-Requested-With

    This ensures the server will render the request exactly as the page
    would be rendered for a non-XHR request.

    ECOMMERCE-1854
    Ben Crouse

*   Remove unnecessary prefilter

    This is no longer needed since we are correctly using Vary headers
    to vary the cache based on the X-Requested-With

    ECOMMERCE-1854
    Ben Crouse

*   Begin new content block guides

    ECOMMERCE-1678
    Chris Cressman

*   Clean up checkout views

    This commit includes:

    - Move `grid` from components to `objects`
    - Add `responsive-grid` object
    - Removal of fieldsets from `checkout#addresses`
    - Add more classes to `checkout#shipping`
    - Modernize the `clearfix` trump
    - Secondary payments now visible by default, removes
      `checkout_secondary_payments.js`

    ECOMMERCE-1608
    Curt Howard

*   Add ping to home base on application initialization

    ECOMMERCE-1253
    Ben Crouse

*   Create consistency with use of `facet` or `filter`

    The terms `facet` and `filter` were used in mixed scenarios throughout
    the codebase. This aims to make the use of either term consistent.

    `facet` is used in the context of search results, when referring to a list
    of filter values. `filter` is used to refer to lists of attributes that are
    used to narrow search results.

    ECOMMERCE-1878
    Matt Duffy

*   Begin updating stylesheet guides

    ECOMMERCE-1680
    Chris Cressman

*   Extract asset importing into plugin

    Remove code around importing product and asset images for
    creation of workarea-import plugin.

    ECOMMERCE-1876
    Matt Duffy

*   Remove OMS functionality

    Admin OMS functionality is being moved to a workarea-oms plugin.

    ECOMMERCE-1877
    Matt Duffy

*   Update views, partials, and helpers guides

    ECOMMERCE-1821
    Chris Cressman

*   Update plugins guides

    ECOMMERCE-1815
    Chris Cressman

*   Fix item cancellations showing when quantity 0

    Without this fix, cancellations adds an entry in the return value
    even if the quantity cancelled on the item is 0

    ECOMMERCE-1902
    Ben Crouse

*   Rewrite test for adding content

    Prevent random failures

    ECOMMERCE-1898
    Kristen Ward

*   Adjust JS Modules

    `release_search_for_editing.js` became
    `releasable_model_search_forms.js`.

    `releases_timelines.js` has been made less fragile.

    `search_results_sortables.js` has been cleaned up.

    ECOMMERCE-1702
    Curt Howard

*   Update getting started guides

    ECOMMERCE-1833
    Chris Cressman

*   Add/update ruby guides

    ECOMMERCE-1820
    Chris Cressman

*   Update product images and content assets guides

    ECOMMERCE-1827
    Chris Cressman

*   Update analytics guides

    ECOMMERCE-1825
    Chris Cressman

*   Add/update contact form guides

    ECOMMERCE-1826
    Chris Cressman

*   Add application order to discounts

    This resolves several calculation problems when determining discount value.
    Merge branch 'feature-discount-application-order'

    ECOMMERCE-1875
    Ben Crouse

*   Remove synonyms reindex warning

    ECOMMERCE-1798
    Kristen Ward

*   Refactor checkout code

    With intent to make extension and customization of checkout for
    host applications, the checkout steps and controller actions are
    broken into smaller pieces that allow easier customization of
    the checkout flow.

    ECOMMERCE-1765
    Matt Duffy

*   Rewrite pagination.js

    Pagination needed to be rewritten in order to support future development
    of Ajax Browse/Search Filtering. This change also improves this module's
    readability, squashes a bug that was frequently reported regarding it's
    use of Waypoints.js & removes the final, needless `$.get` request per
    page.

    ECOMMERCE-1873
    Curt Howard

*   Remove landing page type

    Base now ships with only one page template by default: generic. The
    logic has been retained so that SIs may still extend the previous
    functionality to create other page templates as needed.

    ECOMMERCE-1556
    Curt Howard

*   Disable analytics.js while editing content

    The analytics module would misfire many times during the process of
    editing content. This commit stops the analytics module from firing
    false positives while updating page content.

    ECOMMERCE-1733
    Curt Howard

*   Generalize range filters for FilterManager

    This updates the logic around building elasticsearch aggregation for
    price ranges and generalizes it to allow for the addition of any number
    of filters with range values.

    ECOMMERCE-1630
    Matt Duffy

*   Update products guides

    ECOMMERCE-1831
    Chris Cressman

*   Update pricing guides

    ECOMMERCE-1830
    Chris Cressman

*   Update caching guides

    ECOMMERCE-1817
    Chris Cressman

*   Update system emails guides

    ECOMMERCE-1824
    Chris Cressman

*   Update payment guides

    ECOMMERCE-1829
    Chris Cressman

*   Update search guides

    ECOMMERCE-1828
    Chris Cressman

*   Update testing & QA guides

    ECOMMERCE-1818
    Chris Cressman

*   Update contributing guides

    ECOMMERCE-1812
    Chris Cressman

*   Update architecture guides

    ECOMMERCE-1816
    Chris Cressman

*   Overhaul Category UI

    The addition of manual products and previous Preview functionality has
    been consolidated into a singular preview area that is live updated as
    rules are applied.

    ECOMMERCE-1848
    Curt Howard

*   Update data imports guides

    ECOMMERCE-1813
    Chris Cressman

*   Update the guides for additional configurations

    ECOMMERCE-1819
    Chris Cressman

*   Update error pages guides

    ECOMMERCE-1823
    Chris Cressman

*   Update dependency configuration guides

    ECOMMERCE-1832
    Chris Cressman

*   Update I18n guides

    ECOMMERCE-1822
    Chris Cressman

*   Swap success message and page check in content spec

    ECOMMERCE-1861
    Kristen Ward

*   Make Mongoid models publishers by default

    Rather than requiring developers to remember to make a new model
    a publisher, we patch Mongoid::Document to automatically include
    the Mongoid::Publisher module

    ECOMMERCE-1795
    Matt Duffy

*   Remove package products

    We will be moving this functionality to a plugin to allow more options
    for us in the future on the first major release.

    ECOMMERCE-1837
    Ben Crouse

*   Includes query string on return to location

    This corrects an issue where only the path of a remembered
    location was used when redirecting back to a path after login. This
    changes the method used on the parsed URI to include the query
    string in the redirect path.

    ECOMMERCE-1751
    Matt Duffy

*   Add custom discount guide

    ECOMMERCE-1811
    Chris Cressman

*   Update sample data guides

    ECOMMERCE-1771
    Chris Cressman

*   Upgrade to Sidekiq 4

    updates gemspec in core and sidekiq cron version for compatibility
    with Sidekiq 4.

    ECOMMERCE-1799
    Matt Duffy

*   Use default category sort for rule-based products

    Products in the category after the manual products should reflect the
    default sort for the category selected in the admin.

    ECOMMERCE-1839
    Ben Crouse

*   Fix select2 single select dropdown styles

    ECOMMERCE-1859
    Kristen Ward

*   Switch to sidekiq-cron for scheduled jobs

    ECOMMERCE-1640
    Ben Crouse

*   Allow custom filter lists per-category

    ECOMMERCE-1570
    Ben Crouse

*   Merge branch 'feature-add-content-search'

    ECOMMERCE-1834

    Conflicts:
    	core/lib/workarea/core/engine.rb
    Ben Crouse

*   Update inventory dropdown to identify policy regardless of case

    ECOMMERCE-1793
    Kristen Ward

*   Merge branch 'feature/ECOMMERCE-1671-update-style-guides'
    Curt Howard

*   Update & simplify style guides

    This commit sees the removal of the distincition between designer &
    deveolper modes, which was creating confusion around their intended
    uses.

    All layers of the ITCSS architecture are now accounted for in the style
    guide's structure for each engine.

    Arbitrary margins have been removed around each component to showcase if
    the component carries it's own, intentional margin.

    Some style guides have been updated to show their modifiers with the
    parent block, for reasons of convenience.

    ECOMMERCE-1671
    Curt Howard

*   Add worker to keep product browse index fresh

    This serves as a safety net to ensure we don't end up with stale product
    data in the Elasticsearch index. Also protects against products not
    getting indexed.

    ECOMMERCE-1858
    Ben Crouse

*   Update JavaScript guides

    ECOMMERCE-1661
    Chris Cressman

*   Add JSDoc comments to all JavaScripts

    ECOMMERCE-1216
    Chris Cressman

*   Remove JavaScript reference from style guides

    ECOMMERCE-1216
    Chris Cressman

*   Make jQuery validate messages translatable

    Add defaults to en.yml
    Reference commit 2a0da84618f

    ECOMMERCE-1567
    Kristen Ward

*   Clean up discounts namespacing mess

    ECOMMERCE-1844
    Ben Crouse

*   Fix bugs in empty categories

    ECOMMERCE-1749
    Ben Crouse

*   Assume the presence of storefront and admin, always

    Removing the poor original assumption it may be useful to allow the
    admin and storefront to be mounted independently of one another. In
    practice, this is never done and just complicates code and testing.

    ECOMMERCE-1576
    Ben Crouse

*   Fix test failures in generated host app

    Admin assets spec:
    Use image file path from test asset to prevent iframe errors

    Admin content spec:
    Add presets when creating html block

    Store front passwords spec:
    Remove check for admin vs user account path
    Replace with generic success message check

    Store front i18n spec:
    Add name field to dummy locale file

    ECOMMERCE-1774
    Kristen Ward

*   Correctly remove free gift item when disqualified from order

    items were getting unintentionally removed twice from an order. This
    would sometimes cause other free gifts to be removed unintentionally.

    ECOMMERCE-1810
    Matt Duffy

*   Add "Not in Navigation" filter for category admin

    ECOMMERCE-1805
    Ben Crouse

*   Fix no products filter on category dependency on browse indexing

    When you add products to a category, the ES entry for the category does
    not get correctly updated because it depends on the product browsing
    index, which isn't necessarily updated yet. The solution here is to
    force index the first product in the category if present before
    continuing on to index the category admin entry.

    ECOMMERCE-1749
    Ben Crouse

*   Move i18n icon into related text-box

    The `i18n_icon` helper has been removed in favor of a modifier of
    `text-box--i18n` on all associated `text-box` components. The styling
    for the modifier is conditional, and will only display it's icon if a
    class of `i18n` is found higher in the modifiers ancestor tree.
    Currently the `i18n` class is output on the `html` element of the
    admin's application layout.

    ECOMMERCE-1743
    Curt Howard

*   Fix incomplete admin indexing

    Fixes by adding admin reindexing when a model is touched.

    ECOMMERCE-1750
    Ben Crouse

*   Position context menu over sibling model summaries on hover

    ECOMMERCE-1790
    Kristen Ward

*   Add jquery validate to admin

    Move forms module and defaults to core
    Update manifests
    Add styles to error elements

    ECOMMERCE-1773
    Kristen Ward

*   Minor style cleanup

    ECOMMERCE-1727
    Ben Crouse

*   Restructure guides

    In response to feedback from SIs, restructure guides to be smaller
    and more task oriented.

    Remove in-page table of contents in favor of a site-wide navigation
    present on every page.

    ECOMMERCE-1791
    Chris Cressman

*   Refactor search router for easier extension

    This commit changes the Search::Router from a big, hairy if statement to
    a chain of middleware using our SwappableList class. This will allow
    easier extension and decoration by both system implementations and
    plugins.

    ECOMMERCE-1727
    Ben Crouse

*   Remove requirement for user to re-authenticate at checkout

    If a user is already logged in upon starting checkout, they will be
    automatically taken into the checkout flow to the first required step.

    ECOMMERCE-1717
    Matt Duffy

*   Move feature_spec_helper.js to immediately follow Modernizr

    In the test environment, feature_spec_helper.js is needed to undo
    certain Modernizr behavior. We allow plugins to insert code between
    Modernizr and feature_spec_helper in the head.js manifest, which may
    lead to bugs in the test environment.

    In the head manifest, move feature_spec_helper to immediately follow
    Modernizr.

    ECOMMERCE-1803
    Chris Cressman

*   Test for existing WORKAREA.config object before creating it

    In workarea.js, we test for an existing `WORKAREA` object before defining
    one so that an SI can establish the WORKAREA namespace earlier in the
    document if necessary. However, we don't offer the same courtesy for the
    `WORKAREA.config` object.

    Test for `WORKAREA.config` before defining it so that we don't overwrite
    it if it already exists.

    ECOMMERCE-1804
    Chris Cressman

*   Replaces added to cart dialog with drawer

    Clicking add to cart on both PDP and quick view will
    no longer open a dialog to confirm the add to cart. It
    now opens up the cart drawer with the flash messages within.

    This required a refactoring of how the drawers module was
    written in order to eliminate the need for a secondary ajax
    call to load the cart summary after the request to add the
    cart items.

    ECOMMERCE-1746
    Fixes: ECOMMERCE-1739
    Matt Duffy

*   Move modifiers to the block/element they modify

    ECOMMERCE-1611
    Curt Howard

*   Merge branch 'feature/ECOMMERCE-1676-create-objects-functional'
    Curt Howard

*   Move product placeholder image to catalog root

    ECOMMERCE-1585
    Ben Crouse

*   Move product image to catalog root

    ECOMMERCE-1585
    Ben Crouse

*   Move variants to catalog root

    ECOMMERCE-1585
    Ben Crouse

*   Reduce CSS footprint in storefront

    This commit removes much of the accumulated cruft and opinionated
    styling from the storefront, while making the remaining amount of CSS
    as configurable as possible.

    A true objects layer has been added:

    - `objects/_button.scss`: contains baseline styling for `.button` and
      `.text-button`. Can be used to remove the styling for stray `button`
      elements.
    - `objects/_unstyled_list.scss`: removes browser default styling for
      lists.
    - `objects/_inline_list.scss`: does the same as the above, but makes
      internal `li` elements `display: inline-block`.

    The mixins offering has expanded to include:

    - `grid`: used in `components/_grid.scss` and for responsive grid
      one-offs.
    - `icon`: consolidates previous `icon-container` and `icon` mixins

    Some modules have been reinvisoned and/or simplified considerably. Those
    worth noting are as follows:

    - `components/_button.scss`: simply defines the CSS responsible for the
      design, relying on `objects/_button.scss` for the baseline styling.
    - `components/_text_button.scss`: same as above
    - `components/_grid.scss`: relies on `grid` mixin. `.grid--2-at-medium`
      has been removed.
    - `components/_message.scss`: simplified to be much closer to the admin.
    - `components/_page_content.scss`: defined by a two column grid with a
      gutter. Rewritten to use general sibling selectors, simplifying the
      file considerably.
    - `components/_page_header.scss`: simplified as much as possible, with
      respsect to the fact that this file is going to be heavily customized
      on a per-project basis.
    - `components/_product_details_container`: conditional overrides
      removed, simplified.

    The `storefront/application.scss.erb` file has two additional append
    points, one for `dependencies` (for plugins who leverage a rails
    front-end gem dependency) and `theme` where the bulk of the style
    overrides should take place as themes are being created.

    Many minor adjustments have been made to the storefront views in
    support of these simplifications.

    ECOMMERCE-1676
    Curt Howard

*   Prevent nil regular prices

    The admin guards against empty regular price submissions, but the
    API does not. To ensure that regular price is never nil across the
    application, a before_validation callback is added to set regular
    price to 0 if its been set to nil.

    ECOMMERCE-1742
    Matt Duffy

*   Improve name for queries for catalog details

    ECOMMERCE-1585
    Ben Crouse

*   Clean up reports after removing many of them

    After moving empty categories and product-data reports to filters
    in the search index, it doesn't really make sense to have a
    separate reports module.

    Resulting from changes in
    ECOMMERCE-1750 and ECOMMERCE-1749
    Ben Crouse

*   Add product issues filter and replace missing images report

    ECOMMERCE-1750
    Ben Crouse

*   Move content assets sample data files

    Files to be used as content assets sample data are expected in the host
    app at `data/images/content`. However, this directory name is misleading
    since not all content asset files are images. Content assets sample data
    files within the workarea gem are expected at `data/assets` which is
    arbitrarily different from the host app location.

    Standardize on `data/content_assets` as the expected location within the
    host app and the workarea gem. This name maps to the corresponding model
    name and provides parity with `data/product_images` which is also used
    within the workarea gem.

    ECOMMERCE-1766
    Chris Cressman

*   Be consistent when saving asset paths on a content block

    Content block data sometimes includes asset paths. These paths should
    always refer to `Workarea::Content::Asset`s rather than files in
    `app/assets`. Each should also always include the asset host if one is
    configured so that developers can't omit the asset host in the view and
    cause performance problems.

    Asset paths are saved as data on content blocks primarily through (1)
    the asset picker UI and (2) sample data generators. The asset picker UI
    correctly uses `Workarea::Content::Asset`s, but it incorrectly excludes
    the asset host for non-image assets. The `BlockTypesGenerator` correctly
    includes the asset host, but incorrectly references assets in
    `app/assets`.

    Update both solutions to work consistently. For including the asset
    host, prefer the `url_to_asset` helper over the `image_url` and
    `asset_url` helpers. `image_url` is intended for use with images in
    `app/assets`, while `asset_url` can cause naming conflicts if the host
    app defines a 'Asset' resource.

    ECOMMERCE-1745
    Chris Cressman

*   Move empty categories report to a filter on categories index

    ECOMMERCE-1749
    Ben Crouse

*   Change to always save details hash values as arrays

    This will make accessing/manipulating details on products or variants
    a more consistent and less surprising experience.

    ECOMMERCE-1578
    Ben Crouse

*   Put feature specs in the Workarea module

    ECOMMERCE-1580
    Ben Crouse

*   Clean up product pricing and ES caching

    Reduces the amount of code around figuring out product pricing and adds product
    inventory caching in Elasticsearch.

    Merge branch 'cleanup-pricing-caching'

    ECOMMERCE-1583
    Ben Crouse

*   Fix search rake tasks for locale-specific repositories

    ECOMMERCE-1797
    Ben Crouse

*   Run search index tasks for all locales.

    When building the ElasticSearch index, we were not truly respecting all
    locales configured in Rails' i18n and Workarea.config.locales, because we
    instantiated the Search::Repository (which defines what index we're
    placing the content in) *before* iterating through all of the locales.
    We need to place the instantiation code inside the `for_each_locale`
    loop to get this to work.

    Note that this does not seem to generate a Spanish-language admin
    index..

    ECOMMERCE-1797
    Tom Scott

*   Add highlight on focus to admin autocomplete results

    ECOMMERCE-1764
    Kristen Ward

*   Switch to explicit discount compatibility

    Previous discounts were assumed to be compatible with each other
    unless marked as incompatible with specific discounts. This swaps
    this logic to assume incompatibility unless added as a compatible.

    This fits closer to the most common use cases for discounts, where
    most discounts are incompatible with all other discounts with a few
    exceptions.

    ECOMMERCE-1760
    Scott Zelley

*   Clean up ajax child menu functionality

    Pass menu-specific data attributes for child links
    (fixes 3rd level primary nav)

    Remove data attribute from secondary nav
    (removes ajax hover functionality)

    Refactor navigation item data helper to return ajax path or blank string

    Refactor menu js modules to trigger ajax load only when path is present

    ECOMMERCE-1568
    Kristen Ward

*   Free gifts have a discount value

    Free gift discounts were not getting a value set when applying to
    an order. This made it impossible to choose among incompatible
    free gift discounts based on the value of the free gift.

    This changes it so that the sell price of the sku is used to set
    the discount value on free gifts.

    ECOMMERCE-1781
    Matt Duffy

*   Fix sorting with applied browse filters

    Use fix in world_wide_stereo commit 81a5a783b91

    Add unit test for helper method

    Prevent duplicate ids when generating multiple hidden fields

    ECOMMERCE-1708
    Kristen Ward

*   Fix broken translations

    After merging the PR for ECOMMERCE-1724, tests broke due to missing
    translations. This commit simplifies the configuration of missing
    translation raising and fixes the newly found errors.

    ECOMMERCE-1724
    Ben Crouse

*   Free gift discounts honor incompatibility rules

    When two free gift discounts qualified for an order, but the
    discounts were incompatible, both free gifts would remain on the
    order. This made it appear the discount incompatibility rules were
    being ignored.

    The logic in FreeGift was using a mutating #reject! to remove items,
    but this method does not correctly persist the mutated collection in
    mongodb. This fix explicity creates a new collection of items that
    is set on the order after removing the disqualified discount
    free gift.

    ECOMMERCE-1654
    Fixes: ECOMMERCE-1759
    Matt Duffy

*   Make product name field required in admin edit form

    ECOMMERCE-1763
    Kristen Ward

*   Add feature test for saved addresses dropdown

    ECOMMERCE-1711
    Kristen Ward

*   Corrects the rendering of asset templates

    The content_assets#index action was being used for both the admin
    index page and insertion of assets into content blocks. Both uses
    caused an xhr request to the index action, but required different
    templates to render.

    This ticket resolves this conflict by creating a second action for
    asset insertion, rather than overusing the index action that resulted
    in the wrong template being rendered on the index page for secondary
    pages.

    ECOMMERCE-1553
    Matt Duffy

*   Restore checkout saved address dropdown functionality

    Remove broken dom reference and replace in js

    ECOMMERCE-1711
    Kristen Ward

*   Fix issues with pagination within the admin asset picker

    Pagination with the asset dialog would cause a trigger of pagination
    multiple times due to existing waypoints which causes a javascript
    error. This error prevents further excution of javascript that would
    allow the user to select and insert an asset into a content block

    ECOMMERCE-1657
    Matt Duffy

*   Move analytics configuration from config.js to module

    ECOMMERCE-1731
    Curt Howard

*   Upgrade lodash to v3.10.1

    This commit bumps the version of `lodash-rails` to `3.10.1` and contains
    the following global changes:

      - Rename _.compose to _.flowRight
      - Rename _.contains to _.includes
      - Rename _.each to _.forEach
      - Rename _.extend to _.assign
      - Rename _.object to _.zipObject

    ECOMMERCE-1706
    Curt Howard

*   Improve Content Editing UI

    This work also enables blocks to control the window scroll position when
    being drug to allow for easier placement when there are many blocks
    contained within an area.

    ECOMMERCE-1524
    Curt Howard

*   Removes email signup page from admin

    Under Marketing, we've removed the signup email report
    due to the likelihood that this data would be used and referenced
    from the email service provider.

    ECOMMERCE-1747
    Matt Duffy

*   Daily Status email is now opt-in from the user edit page

    This removes the status email page and model that previously
    held an array of emails. Instead, a user is opted-in to this email
    by checking the option in the user areas and the list is generated
    by on the email address of users who are opted-in.

    ECOMMERCE-1748
    Matt Duffy

*   When is a SKU present, render product detail with only that SKU's price

    Customers should see the price specific to the SKU they're selecting so
    they know how much that SKU costs.

    ECOMMERCE-1583
    Ben Crouse

*   Improve Content Block Editing UI

    Also includes:
      - Fix close button styles in admin dialog
      - Fix heading weight after arch updates

    ECOMMERCE-1684
    Curt Howard

*   Clean up and remove redundant order item attributes

    ECOMMERCE-1735
    Ben Crouse

*   Remove redundant product and sku details from order item

    This data is already available as part of the product copy on the order
    item. Also, the only place it's needed is for attribute discounts, which
    with simplification can be pretty simple to retreive.

    ECOMMERCE-1735
    Ben Crouse

*   Remove hoverZooms module from base

    This commit also adds JavaScript templates append points.

    ECOMMERCE-1625
    Curt Howard

*   Consolidate locale config to one place.

    Workarea currently requires locale configuration to be defined
    twice...first in the application config itself and then in the workarea
    initializer. The reasoning behind this was so one could customize the
    name of the language in the locale selector. However, it's much more
    conventional to place this translation text in each locale file,
    allowing us to only configure locales in application.rb.

    ECOMMERCE-1719
    Tom Scott

*   Corrects the adjustment of tender amounts

    When determing the amount of an order to apply to each
    tender on the order, we correctly loop through all tenders
    setting any unneeded tender's amount to 0 rather than breaking
    through the loop.

    ECOMMERCE-1713
    Matt Duffy

*   Redirects admins to admin dashboard

    upon login, admin users will be redirected to the admin
    dashboard instead of the user accounts page.

    ECOMMERCE-1726
    Matt Duffy

*   Removes mongoid indexes on reseed

    Resolves an issue where Mongoid throws an error on duplicate indexes
    when rerunning the workarea sample data by explicitly removing the
    existing indexes before recreating them.

    ECOMMERCE-1729
    Matt Duffy

*   Add helper to set a current user in integration tests

    ECOMMERCE-1734
    Ben Crouse

*   Change default message state in storefront to match admin

    The admin's default `.message` was informational, whereas the
    storefront's default was a warning. This commit allows implementors to
    throw informational messages around much more easily, ie. negates the
    need for a modifier for simple messaging.

    ECOMMERCE-1651
    Curt Howard

*   Require users to re-login when ip or user agent change

    This is a feature for PCI compliance and general security.

    ECOMMERCE-1732
    Ben Crouse

*   Allow formSubmittingControls module to resubmit after invalid form

    There was a bug reported that a `[data-form-submitting-control]` field
    works as expected until an invalid value is input. At that point
    `formSubmittingControls` alerted the form that it had been submitted,
    which normally prevents the form from being submitted twice, but in this
    case it rendered that form unsubmittable until the form was manually
    submitted by the user.

    ECOMMERCE-1644
    Curt Howard

*   Raise error during test if missing translation

    The default behavior for a missing translation is to display a message in place of the translation that says that the translation is missing. This commit changes this behavior in the test environment to raise an error.

    See http://stackoverflow.com/questions/8066901/rails-how-to-treat-locale-translation-missing-as-error-during-test

    ECOMMERCE-1724
    Mike Dalton

*   Raise `Exception`s during Capybara JS feature specs instead of displaying a blank page

    Capybara defaults to only raising `StandardError`s during feature specs. When an error is raised that inherits from `Exception` but not from `StandardError` a blank page is displayed. This commit 1) changes the Capybara configuration setting to raise errors on `Exception`s and 2) increases the version constraint on Capybara to a version with this configuration setting.

    ECOMMERCE-1725
    Mike Dalton

*   Restrict decorate calls to only the Workarea module

    By restricting decorate calls to only be possible in the Workarea module,
    we can remove the number of constant defined and associated loading
    errors because decorators explicitly reference the constant they
    intend to decorate.

    ECOMMERCE-1721
    Ben Crouse

*   Improve naming on controller mixins

    This should help prevent confusion between what's a controller and
    what's a controller mixin.

    ECOMMERCE-1722
    Ben Crouse

*   Refactor and simplify authentication and authorization

    We had a lot of code that was unused, overly-complicated, and hard to
    follow. This commit strips back the auth system to a leaner approach.

    ECOMMERCE-1575

    Squashed commit of the following:

    commit e401c744375e857c75ac10b5d8852f5660959374
    Author: Ben Crouse <bcrouse@workarea.com>
    Date:   Fri Oct 30 13:05:17 2015 -0400

        Simplify authorization/permissions

    commit d52807930ae2dcc6bd708bb59039c4dfa0beb527
    Author: Ben Crouse <bcrouse@workarea.com>
    Date:   Thu Oct 29 16:28:13 2015 -0400

        Move authorization models into core

    commit ee140090fad6733a65c057bb7d540a97b98971f1
    Author: Ben Crouse <bcrouse@workarea.com>
    Date:   Thu Oct 29 16:08:17 2015 -0400

        Start on authorization

    commit 59b1d349bdefb4ccdb837b4e3d37418cbc2ee6c3
    Author: Ben Crouse <bcrouse@workarea.com>
    Date:   Thu Oct 29 15:33:46 2015 -0400

        Simplify authentication
    Ben Crouse

*   Move configuration from vars to components

    ECOMMERCE-1675
    Curt Howard

*   Translate Quantity title in cart summary

    ECOMMERCE-1590
    Kristen Ward

*   Remove search explanations feature

    ECOMMERCE-1718
    Ben Crouse

*   Reorganize admin navigation

    ECOMMERCE-1701

    Squashed commit of the following:

    commit 708dea4db5956b3a1ddb1074c3f6cbd038d307ed
    Author: Ben Crouse <bcrouse@workarea.com>
    Date:   Thu Oct 29 12:24:48 2015 -0400

        Update individual views

    commit 69d1d09d9da7a70bf92b347bc88ce0e9edeb32ab
    Author: Ben Crouse <bcrouse@workarea.com>
    Date:   Thu Oct 29 11:21:45 2015 -0400

        Remove unused files

    commit c8e9178245d04cd6d76314f90cb2efe13b87d9e7
    Author: Ben Crouse <bcrouse@workarea.com>
    Date:   Thu Oct 29 11:16:00 2015 -0400

        Minor clean up

    commit 98cf92369fdfedd025f6e55f4090e1c6cf1b1189
    Merge: f362bea 411617c
    Author: Ben Crouse <bcrouse@workarea.com>
    Date:   Thu Oct 29 11:08:09 2015 -0400

        Merge branch 'master' into admin-navigation-reorganization

        Conflicts:
        	admin/app/views/layouts/workarea/admin/application.html.haml

    commit f362bea6eccc9f0c68083fbd3c4a7dd8af2ab5b2
    Author: Ben Crouse <bcrouse@workarea.com>
    Date:   Fri Oct 16 10:15:34 2015 -0400

        Rough draft of navigation
    Ben Crouse

*   Configuration & API Cleanup in JavaScript

    Configuration added to:
      - storefront:
        + searchFields
        + popupButtons
      - core:
        + jumpToMenuFields
        + deletionForms
        + messages
        + pagination
      - admin:
        + dateRangePickers
        + productImagesSortables
        + recommendationsSortables
        + searchResultsSortables

    Configuration files now have three sections:
      - Module config, named after module
        + `WORKAREA.config.searchFields = {}`, for example
        + These objects wrap various properties used for configuration
      - Other configuration,
        + `WORKAREA.config.creditCardNumberWhiteList`, for example
        + Configuration for non-module specific uses
      + Config Methods
        + Extension methods, like Credit Card Validation for jQuery Validate

    Many methods were cleaned up. A few modules underwent light refactoring.

    ECOMMERCE-1673
    Curt Howard

*   Change references to "merchandised" to "manual" for UI consistency

    ECOMMERCE-1643
    Ben Crouse

*   Remove box pattern

    Implementers have said that the `.box` pattern is more harmful than
    helpful.

    ECOMMERCE-1610
    Curt Howard

*   Rename workarea_jump_to -> categorized_autocomplete

    ECOMMERCE-1672
    Curt Howard

*   Change cart item order to newest first

    ECOMMERCE-1716
    Ben Crouse

*   Add Heap analytics to the admin

    ECOMMERCE-1714
    Ben Crouse

*   Refactor User class and accompanying classes

    This is clean up and simplification work on old classes/modules in preparation
    for v1.0.

    ECOMMERCE-1577
    Ben Crouse

*   Reduce contextual overrides & various spot cleaning

    Wherever possible contextually overridden classes have been removed from
    the codebase. Minor cleanup was also done as part of this ticket.

    ECOMMERCE-1612
    Curt Howard

*   Fix admin toolbar permissions

    After moving/standardizing admin routing and controllers, the
    permissions checking in the toolbar broke. This commit fixes with a less
    hacky way of grabbing the resource name from Rails conventions.

    ECOMMERCE-1697
    Ben Crouse

*   Add indication of why a product is in a category

    ECOMMERCE-1643
    Ben Crouse

*   Don't render anything for non-HTML 404s

    ECOMMERCE-1667
    Ben Crouse

*   Merge branch 'merge-category-types'

    Using the Elasticsearch percolator functionality, we can determine a product's
    categories based on the category rules. Given that, it's much simpler and
    easier to combine smart and standard categories.

    ECOMMERCE-1643
    Ben Crouse

*   Allow case-insensitive strings or symbols in browse option keys

    Add unit test for browse link options

    ECOMMERCE-1668
    Kristen Ward

*   Increase depth of admin's date range picker

    ECOMMERCE-1615
    Curt Howard

*   Merge branch 'feature/ECOMMERCE-1616-adopt-itcss-architecture'

    This branch merge introduces a fundimental change to the CSS architecture.

    ECOMMERCE-1616
    Curt Howard

*   Merge branch 'master' of ssh://stash.tools.workarea.com:7999/wl/workarea into feature/ECOMMERCE-1616-adopt-itcss-architecture

    Conflicts:
    	admin/app/mailers/workarea/admin/application_mailer.rb
    Curt Howard

*   Merge branch 'master' of ssh://stash.tools.workarea.com:7999/wl/workarea into feature/ECOMMERCE-1616-adopt-itcss-architecture

    Conflicts:
    	admin/app/views/layouts/workarea/admin/application.html.haml
    	admin/app/views/workarea/admin/catalog_products/edit.html.haml
    	storefront/app/views/layouts/workarea/storefront/application.html.haml
    	storefront/app/views/workarea/storefront/carts/show.html.haml
    	storefront/app/views/workarea/storefront/carts/summary.html.haml
    	storefront/app/views/workarea/storefront/checkouts/addresses.html.haml
    	storefront/app/views/workarea/storefront/products/show.html.haml
    	storefront/app/views/workarea/storefront/searches/no_results.html.haml
    	storefront/app/views/workarea/storefront/users/accounts/show.html.haml
    Curt Howard

*   Prevent notification email error in admin user comments

    Include I18n module in application mailer
    Set host in default url options
    Remove unneeded var in comment mailer
    Remove unneeded default url options in status report mailer

    ECOMMERCE-1530
    Kristen Ward

*   Use relative paths throughout Admin

    Using absolute URLs throughout the application complicates the code
    base and development environments and is no longer believed to provide
    a significant SEO benefit.

    Use relative paths instead. Replace *_url routing helpers with *_path
    routing helpers.

    This commit applies the changes throughout the Admin. A previous commit
    applied the changes throughout the Store Front.

    ECOMMERCE-1205
    Chris Cressman

*   Rename link helper for clarity

    ECOMMERCE-1205
    Ben Crouse

*   Revert local variable name `share_path` back to `share_url`

    Also remove check for `email_share_path` since it isn't used.

    ECOMMERCE-1205
    Chris Cressman

*   Use relative paths throughout Store Front

    Using absolute URLs throughout the application complicates the code
    base and development environments and is no longer believed to provide
    a significant SEO benefit.

    Use relative paths instead. Replace *_url routing helpers with *_path
    routing helpers. Remove domain name from `url_for` default options.

    This commit completes the change in the Store Front. A previous commit
    applied the change to most Store Front views.

    ECOMMERCE-1205
    Chris Cressman

*   Restore absolute url in mailer

    ECOMMERCE-1205
    Chris Cressman

*   Remove unnecessary regex queries from promo codes

    ECOMMERCE-1628
    Ben Crouse

*   Use relative paths in storefront views

    Using absolute URLs throughout the application complicates the code
    base and development environments and is no longer believed to provide
    a significant SEO benefit.

    Use relative paths instead. Replace *_url routing helpers with *_path
    routing helpers.

    This commit touches Store Front views only.

    ECOMMERCE-1205
    Chris Cressman

*   Remove unnecessary regex query from discount redemption

    ECOMMERCE-1628
    Ben Crouse

*   Use downcased link names for search auto-redirection

    We were previously using case-insensitive regex queries on various
    models for the search auto-redirecting. These queries were slow and it
    didn't allow easy extension for plugins.

    This solution queries navigation links for exact matches - links save a
    downcased link name for matching. This allows easy extension for any
    plugins.

    ECOMMERCE-1628
    Ben Crouse

*   Remove inventory sell through tracking

    There is a problem with tracking sell through, which is that it depends
    on the merchant correctly stocking their products. It has also caused
    performance problems with the number of queries.

    To fix it, this commit replaces the sell through tracking with a simpler
    sales score based on orders, which is decayed weekly.

    ECOMMERCE-1636
    Ben Crouse

*   Specify named route helpers in app and plugin templates

    When copying tests into the host app, some routes helpers are undefined.

    Ensure all mounted engines have a named route helper so that all routes
    are accessible in specs.

    ECOMMERCE-1501
    Chris Cressman

*   Remove indexing from rake workarea:install

    We don't need indexing at the point of installing the system - if it's
    the initial environment provisioning, there's no data to index, and if
    it's adding a server to the environment, the data is already indexed.

    This was causing pain the hosting team because of accidential
    dropping/reindexing of index data when adding an additional server to
    the environment.

    ECOMMERCE-1593
    Ben Crouse

*   Switch to use the money-rails gem

    We've been using a manual integration between money, Rails, and Mongoid.
    Switching so we can offload this maintenance and take advantage of the
    additional configuration/features that money-rails provides.

    ECOMMERCE-1582
    Ben Crouse

*   Fix typo in error class name when booting an app w/o config/mongoid.yml

    ECOMMERCE-1574
    Ben Crouse

*   Upgrade to Mongoid 5

    ECOMMERCE-1574
    Ben Crouse

*   Allow different classes to embed `Workarea::Catalog::Product::Image`

    Changing references to `product` to `_parent` in `Workarea::Catalog::Product::Image` to allow other classes to embed this class

    ECOMMERCE-1535
    Mike Dalton

*   Validate `type_id` field on `Workarea::Content::Block`

    The `Workarea::Content::Block#type_id` field is used to determine which partial and which view model to use. Without this field, there will be errors when the content is loaded. Adding validation to this field prevents developers from creating content blocks without a type.

    ECOMMERCE-1532
    Mike Dalton

*   Refactor fulfillment to allow easier extension

    This work allows more flexibility for adding new fulfillment and order
    statuses by introducing the StatusCalculator. It also cleans up and
    simplifies the logic and modeling around the fulfillment functionality
    in the system.

    ECOMMERCE-1544

    Merge branch 'refactor-fulfillment'

    Conflicts:
    	admin/app/controllers/workarea/admin/fulfillments_controller.rb
    	admin/app/view_models/workarea/admin/fulfillment_view_model.rb
    	admin/app/views/workarea/admin/orders/edit.html.haml
    	admin/spec/requests/fulfillments_spec.rb
    	admin/spec/requests/orders_spec.rb
    Ben Crouse
