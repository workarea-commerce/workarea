---
title: Workarea 3.3.0
excerpt: Updates all system email views to use an improved template (improved responsiveness, more thoroughly tested across email clients). Moves shared markup into partials. Moves inline styles to external stylesheets for easier management (the styles are aut
---

# Workarea 3.3.0

## Changes System Emails to Improve Responsiveness & Developer Experience

Updates all system email views to use an improved template (improved responsiveness, more thoroughly tested across email clients). Moves shared markup into partials. Moves inline styles to external stylesheets for easier management (the styles are automatically inlined when the views are rendered). Removes plain text emails, since they are now created automatically from the HTML version.

This change modifies _all_ system email views. **Overriding all email views _before_ upgrading is highly recommended to avoid unexpected changes to system emails.** Or, if you've already upgraded, manually create overrides for all email views from the views included with your previous Workarea version.

### Issues

- [ECOMMERCE-5827](https://jira.tools.weblinc.com/browse/ECOMMERCE-5827)
- [ECOMMERCE-5894](https://jira.tools.weblinc.com/browse/ECOMMERCE-5894)
- [ECOMMERCE-5892](https://jira.tools.weblinc.com/browse/ECOMMERCE-5892)
- [ECOMMERCE-5896](https://jira.tools.weblinc.com/browse/ECOMMERCE-5896)
- [ECOMMERCE-5776](https://jira.tools.weblinc.com/browse/ECOMMERCE-5776)
- [ECOMMERCE-5827](https://jira.tools.weblinc.com/browse/ECOMMERCE-5827)
- [ECOMMERCE-5939](https://jira.tools.weblinc.com/browse/ECOMMERCE-5939)
- [ECOMMERCE-5939](https://jira.tools.weblinc.com/browse/ECOMMERCE-5939)

### Pull Requests

- [3220](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3220/overview)
- [3239](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3239/overview)
- [3238](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3238/overview)
- [3240](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3240/overview)
- [3262](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3262/overview)

### Commits

- [495d5b1c9bf2b667d2ed16d328ce0303f82dd548](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/495d5b1c9bf2b667d2ed16d328ce0303f82dd548)
- [aa89107634ae362d91f27e0c9868589d068021ad](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/aa89107634ae362d91f27e0c9868589d068021ad)
- [70428b1d16143b01e0206d7edbd9da6136359182](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/70428b1d16143b01e0206d7edbd9da6136359182)
- [1e1eaf1d43621b69e5d83bd2f6cb0a9cd09b1cf6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1e1eaf1d43621b69e5d83bd2f6cb0a9cd09b1cf6)
- [0b8b8986cf26977751db10ed7531a09274b08e71](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0b8b8986cf26977751db10ed7531a09274b08e71)
- [f8cb96a1b749abf1378d5dfb71619eece5a427be](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f8cb96a1b749abf1378d5dfb71619eece5a427be)
- [41a9053e183c79cc64172245be2a235319247db1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/41a9053e183c79cc64172245be2a235319247db1)
- [a6b9cbd6980ecd5922c05bb6a3eb07757a7be710](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a6b9cbd6980ecd5922c05bb6a3eb07757a7be710)
- [37c9a678e48d2053c2353b1e180d324b7f2c6ae0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/37c9a678e48d2053c2353b1e180d324b7f2c6ae0)
- [48fd33f658899eb70f3f9160a288eaaa31259825](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/48fd33f658899eb70f3f9160a288eaaa31259825)
- [e674557987331aa47af00a0330fc5f58cb537777](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e674557987331aa47af00a0330fc5f58cb537777)
- [d982432c9c5f89764e0e13f83e16922dace095de](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d982432c9c5f89764e0e13f83e16922dace095de)
- [c5298aa8bf4bca8e38d5e581659d0eb80fa6ffac](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c5298aa8bf4bca8e38d5e581659d0eb80fa6ffac)
- [b5d3a8e45a529ff7bb5af84ec894f194d0858cf1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b5d3a8e45a529ff7bb5af84ec894f194d0858cf1)
- [d1396d9b2401930a94b6963142ea6aeeaea501d1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d1396d9b2401930a94b6963142ea6aeeaea501d1)
- [fda271bc1888139181c8c6af996cb199d57bff1a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fda271bc1888139181c8c6af996cb199d57bff1a)

## Changes Browser/Driver for System Tests to Chrome/Selenium

Uses Chrome and Selenium for system tests instead of PhantomJS and Poltergeist.

**Existing applications and plugins should update all system tests to work with Chrome/Selenium.** Applying the following changes to your existing tests will cover most of the API differences:

- Change instances of `trigger('click')` to `click`
- Remove calls to `clear_driver_cache`
- Remove dragging and dropping within tests (tests in Base simply assert the drag and drop interface has initialized)

**If you can't update some or all of your existing tests, you can continue to use PhantomJS/Poltergeist for specific tests, test cases, or your entire suite of system tests.** See [Drive System Tests with PhantomJS/Poltergeist](drive-system-tests-with-phantomjs-poltergeist.html).

The necessary dependencies for this change are already installed in Workarea Hosting environments. For local development environments, you must have Chrome installed. The other dependencies are handled by Bundler.

This change disables HTTP caching in test environments (using Rack middleware), since Chrome does not provide a reliable way to clear the cache. If you need to re-enable HTTP caching (e.g. to test caching headers), set `Workarea.config.strip_http_caching_in_tests = false` for the duration of the test.

This change also extends Capybara to make XHR requests blocking, which reduces performance but increases stability.

### Issues

- [ECOMMERCE-5443](https://jira.tools.weblinc.com/browse/ECOMMERCE-5443)
- [ECOMMERCE-5459](https://jira.tools.weblinc.com/browse/ECOMMERCE-5459)
- [ECOMMERCE-5755](https://jira.tools.weblinc.com/browse/ECOMMERCE-5755)
- [ECOMMERCE-5718](https://jira.tools.weblinc.com/browse/ECOMMERCE-5718)
- [ECOMMERCE-5759](https://jira.tools.weblinc.com/browse/ECOMMERCE-5759)
- [ECOMMERCE-6053](https://jira.tools.weblinc.com/browse/ECOMMERCE-6053)

### Pull Requests

- [3144](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3144/overview)
- [3152](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3152/overview)
- [3163](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3163/overview)
- [3174](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3174/overview)
- [3176](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3176/overview)
- [3198](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3198/overview)
- [3202](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3202/overview)
- [3398](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3398/overview)

### Commits

- [aa7eb6daaefad18484d6535c9b2326a713be8cef](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/aa7eb6daaefad18484d6535c9b2326a713be8cef)
- [be1bf5f3dd319e07d2264caf812c7eab2c69db60](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/be1bf5f3dd319e07d2264caf812c7eab2c69db60)
- [4c47d6ceb58b3deab87ff9fcc1857fc652f48300](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4c47d6ceb58b3deab87ff9fcc1857fc652f48300)
- [b0ef1fba98aaa25b4d737ecfe0cc83cded4b53b3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b0ef1fba98aaa25b4d737ecfe0cc83cded4b53b3)
- [b5716a5066f195d06a5d87eeb6fd1fcc3418b86f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b5716a5066f195d06a5d87eeb6fd1fcc3418b86f)
- [7d7ae9bb38042ef5f2aa9095cf3ea112e7d63945](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7d7ae9bb38042ef5f2aa9095cf3ea112e7d63945)
- [ad7cae4309f4a4109ae5081e1c7a72b53af1558c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ad7cae4309f4a4109ae5081e1c7a72b53af1558c)
- [553a90a35b8745215d56a4dc20b885d4affe9f94](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/553a90a35b8745215d56a4dc20b885d4affe9f94)
- [d36448d86c13a527a3c6e538c31f74fd5ab39013](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d36448d86c13a527a3c6e538c31f74fd5ab39013)
- [13b7e16565984ece0a60a46dd06063b83c03de2b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/13b7e16565984ece0a60a46dd06063b83c03de2b)
- [9bde0e28c4e2a3d8aa1d6d8143b3fae6f75baa0b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9bde0e28c4e2a3d8aa1d6d8143b3fae6f75baa0b)
- [eb62d6755d3a28932e691f6aa5aa2584ec219399](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eb62d6755d3a28932e691f6aa5aa2584ec219399)
- [48e0529b734dfffeb9be3f4e28c533d352e0f7e5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/48e0529b734dfffeb9be3f4e28c533d352e0f7e5)
- [bf71742781474fd4341df73c0263a3a9e8a6668a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bf71742781474fd4341df73c0263a3a9e8a6668a)
- [c7e15b39e9cb8c3d394007299a0077cc09f1c6eb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c7e15b39e9cb8c3d394007299a0077cc09f1c6eb)
- [b7c37a1f2f0369a933a9f09198dcacf2e9371ff6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b7c37a1f2f0369a933a9f09198dcacf2e9371ff6)
- [5cb00146e61aee0483f779c89f9647b1ef2af53f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5cb00146e61aee0483f779c89f9647b1ef2af53f)
- [a9ade800859dc904e3c04e31a3100973649d10c7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a9ade800859dc904e3c04e31a3100973649d10c7)

## Changes “Active” to an Internationalized Field

Internationalizes `Releasable#active`, allowing admins to localize the “activeness” of each releasable.

**This change requires a data migration within existing environments.** The value of each `active` field must be updated, since prior to this change, the value is stored as a scalar boolean value rather than a hash keyed by locale.

**You may opt out of this change.** `Workarea.config.localized_active_fields` is a feature flag. Set the value to `false` to disable this feature and avoid the data migration.

### Issues

- [ECOMMERCE-5670](https://jira.tools.weblinc.com/browse/ECOMMERCE-5670)
- [ECOMMERCE-5752](https://jira.tools.weblinc.com/browse/ECOMMERCE-5752)

### Pull Requests

- [3103](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3103/overview)
- [3250](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3250/overview)

### Commits

- [fd72259df854ed072bb9c9f43a3db6d6f7cc41b7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fd72259df854ed072bb9c9f43a3db6d6f7cc41b7)
- [e7b29ba1f495e35f8815ef0370857bd715dc11a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e7b29ba1f495e35f8815ef0370857bd715dc11a9)
- [b67209acd96086938b12148a1a077e25a2706e9b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b67209acd96086938b12148a1a077e25a2706e9b)
- [e68962a18bd38a5959b50e05b6bc0d965d422a14](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e68962a18bd38a5959b50e05b6bc0d965d422a14)
- [fabf8af4431ed63fe48d5c1c55cdd589a048f60c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fabf8af4431ed63fe48d5c1c55cdd589a048f60c)

## Removes Bespoke CSV Imports; Adds Generic Import/Export from JSON/CSV; Changes Bulk Action UI; Adds Bulk Deletion

Removes CSV imports for specific model types and adds a general solution for importing and exporting most models through the Admin. Supports JSON and CSV files.

Improves the bulk selection and action UI, incorporating import/export. Also adds bulk deletion.

### Issues

- [ECOMMERCE-3360](https://jira.tools.weblinc.com/browse/ECOMMERCE-3360)
- [ECOMMERCE-3360](https://jira.tools.weblinc.com/browse/ECOMMERCE-3360)
- [ECOMMERCE-5863](https://jira.tools.weblinc.com/browse/ECOMMERCE-5863)
- [ECOMMERCE-5849](https://jira.tools.weblinc.com/browse/ECOMMERCE-5849)
- [ECOMMERCE-5855](https://jira.tools.weblinc.com/browse/ECOMMERCE-5855)
- [ECOMMERCE-5898](https://jira.tools.weblinc.com/browse/ECOMMERCE-5898)
- [ECOMMERCE-5897](https://jira.tools.weblinc.com/browse/ECOMMERCE-5897)
- [ECOMMERCE-5946](https://jira.tools.weblinc.com/browse/ECOMMERCE-5946)
- [ECOMMERCE-5946](https://jira.tools.weblinc.com/browse/ECOMMERCE-5946)
- [ECOMMERCE-5967](https://jira.tools.weblinc.com/browse/ECOMMERCE-5967)
- [ECOMMERCE-5956](https://jira.tools.weblinc.com/browse/ECOMMERCE-5956)
- [ECOMMERCE-6024](https://jira.tools.weblinc.com/browse/ECOMMERCE-6024)
- [ECOMMERCE-5993](https://jira.tools.weblinc.com/browse/ECOMMERCE-5993)
- [ECOMMERCE-6041](https://jira.tools.weblinc.com/browse/ECOMMERCE-6041)
- [ECOMMERCE-6042](https://jira.tools.weblinc.com/browse/ECOMMERCE-6042)
- [ECOMMERCE-6012](https://jira.tools.weblinc.com/browse/ECOMMERCE-6012)
- [ECOMMERCE-6048](https://jira.tools.weblinc.com/browse/ECOMMERCE-6048)
- [ECOMMERCE-6034](https://jira.tools.weblinc.com/browse/ECOMMERCE-6034)
- [ECOMMERCE-6019](https://jira.tools.weblinc.com/browse/ECOMMERCE-6019)
- [ECOMMERCE-6025](https://jira.tools.weblinc.com/browse/ECOMMERCE-6025)
- [ECOMMERCE-6026](https://jira.tools.weblinc.com/browse/ECOMMERCE-6026)
- [ECOMMERCE-6022](https://jira.tools.weblinc.com/browse/ECOMMERCE-6022)
- [ECOMMERCE-6062](https://jira.tools.weblinc.com/browse/ECOMMERCE-6062)
- [ECOMMERCE-6057](https://jira.tools.weblinc.com/browse/ECOMMERCE-6057)
- [ECOMMERCE-6069](https://jira.tools.weblinc.com/browse/ECOMMERCE-6069)
- [ECOMMERCE-6038](https://jira.tools.weblinc.com/browse/ECOMMERCE-6038)

### Pull Requests

- [3188](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3188/overview)
- [3199](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3199/overview)
- [3203](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3203/overview)
- [3218](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3218/overview)
- [3219](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3219/overview)
- [3231](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3231/overview)
- [3243](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3243/overview)
- [3251](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3251/overview)
- [3254](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3254/overview)
- [3241](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3241/overview)
- [3275](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3275/overview)
- [3298](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3298/overview)
- [3314](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3314/overview)
- [3333](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3333/overview)
- [3325](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3325/overview)
- [3339](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3339/overview)
- [3347](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3347/overview)
- [3358](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3358/overview)
- [3361](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3361/overview)
- [3351](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3351/overview)
- [3371](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3371/overview)
- [3376](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3376/overview)
- [3372](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3372/overview)
- [3384](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3384/overview)
- [3383](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3383/overview)
- [3385](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3385/overview)
- [3395](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3395/overview)
- [3402](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3402/overview)
- [3397](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3397/overview)
- [3400](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3400/overview)

### Commits

- [1a7da998914248f4c35616470f6b7cd935bed1b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1a7da998914248f4c35616470f6b7cd935bed1b0)
- [e9841bb3541469ad86af12315b5e39aad11bd7c1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e9841bb3541469ad86af12315b5e39aad11bd7c1)
- [8bb55fd6239e433692414858740176faeadf2102](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8bb55fd6239e433692414858740176faeadf2102)
- [dea2d18d5733521a03c8fe3bffbb150ab5223da5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dea2d18d5733521a03c8fe3bffbb150ab5223da5)
- [fb7683265d82fdbe91343e7250256651e456eaff](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fb7683265d82fdbe91343e7250256651e456eaff)
- [94a8f5ee494a70981f7af806b3aa2d6c85134e0d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/94a8f5ee494a70981f7af806b3aa2d6c85134e0d)
- [2a6ab1d856f8047f3964c7041d6abeb415a6343d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2a6ab1d856f8047f3964c7041d6abeb415a6343d)
- [b83b3eebefa3d05d166232fa624e1f10281d87e2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b83b3eebefa3d05d166232fa624e1f10281d87e2)
- [e82ea6cee02b99038c14caee1809a7afdbf288ee](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e82ea6cee02b99038c14caee1809a7afdbf288ee)
- [d58c3a76844b1e071987fcfd33f9042ddfd512cc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d58c3a76844b1e071987fcfd33f9042ddfd512cc)
- [4bbe1126a7780babf63513d863b63bb0cfe57a9d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4bbe1126a7780babf63513d863b63bb0cfe57a9d)
- [c874342a20ce223a3e0f24df9cd9451a69cc0242](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c874342a20ce223a3e0f24df9cd9451a69cc0242)
- [ea0acf6bd8fc8fe26dc0aad9219d319beb5f4218](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ea0acf6bd8fc8fe26dc0aad9219d319beb5f4218)
- [a2a544842659f42e362ccc021749e18dce014b65](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a2a544842659f42e362ccc021749e18dce014b65)
- [a56033fa07fd39335fe1508098ce5bb5b7c59f32](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a56033fa07fd39335fe1508098ce5bb5b7c59f32)
- [db2cbd49284255b531ad1248bebd2981cfbfb4a5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/db2cbd49284255b531ad1248bebd2981cfbfb4a5)
- [302a05d9b31d50e265d716a3b3d4ccf66bed94a6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/302a05d9b31d50e265d716a3b3d4ccf66bed94a6)
- [1b7fb901cad39e33a78d9b2aa835a5070026bb9c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1b7fb901cad39e33a78d9b2aa835a5070026bb9c)
- [58cda9486ad1c73d9f462092696dd03e52121220](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/58cda9486ad1c73d9f462092696dd03e52121220)
- [d6098b29e1bfdfd4116d8702010261547334a5a2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d6098b29e1bfdfd4116d8702010261547334a5a2)
- [410ce41a76ec39c187d818c57ca60aa48fe22c20](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/410ce41a76ec39c187d818c57ca60aa48fe22c20)
- [18233bd683a5dd90aa1a18e728860c1168ec7d70](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/18233bd683a5dd90aa1a18e728860c1168ec7d70)
- [de52b1f1dcf2851709cd65b33d53748432c498c1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/de52b1f1dcf2851709cd65b33d53748432c498c1)
- [d4bf4c09ef57ec3809be5af20c7c601bb8acc807](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d4bf4c09ef57ec3809be5af20c7c601bb8acc807)
- [e91d6055d191b235bcc9ecf0d524b8c53e4094e4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e91d6055d191b235bcc9ecf0d524b8c53e4094e4)
- [50e78c36dc55becbc9ee4f8f52679a4807d6bf91](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/50e78c36dc55becbc9ee4f8f52679a4807d6bf91)
- [4139bbbb6955fd16fa00084d9f007f53ccf6cbdb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4139bbbb6955fd16fa00084d9f007f53ccf6cbdb)
- [b17fe34146b4d2afb78d070dec82df87881969bf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b17fe34146b4d2afb78d070dec82df87881969bf)
- [4959673a5afa820f73a1f90da39b986f4beb2531](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4959673a5afa820f73a1f90da39b986f4beb2531)
- [d02e9cb809936d4d0348767f722ad15b63cf939c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d02e9cb809936d4d0348767f722ad15b63cf939c)
- [cdbff23a91317e267946056c92354ade2e88019d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cdbff23a91317e267946056c92354ade2e88019d)
- [c4574ea11b5c3e30012481213e46c985c4e96ce2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c4574ea11b5c3e30012481213e46c985c4e96ce2)
- [78c5e556e5bc9277d187163c62ecdf772e00a003](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/78c5e556e5bc9277d187163c62ecdf772e00a003)
- [78e19d4a42f742b066e8b7f6f979257f49ba13d5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/78e19d4a42f742b066e8b7f6f979257f49ba13d5)
- [790d667c8d5cf1125ab90658e890147b35782fa7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/790d667c8d5cf1125ab90658e890147b35782fa7)
- [54c73057dc7553f40326605707241983909f40eb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/54c73057dc7553f40326605707241983909f40eb)
- [5ffdfcd88813d3d4a886d68f73ddd3ac0096bfb7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5ffdfcd88813d3d4a886d68f73ddd3ac0096bfb7)
- [73174fd427c5dc8bd883922740cec3e1bde64def](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/73174fd427c5dc8bd883922740cec3e1bde64def)
- [0d332c71ff5ce9a723432c5bb5a7fda802507a4a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0d332c71ff5ce9a723432c5bb5a7fda802507a4a)
- [4bc32ba16890476adf5c91bc2fb99250e43e390f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4bc32ba16890476adf5c91bc2fb99250e43e390f)
- [1bac12871ea0b42d261c20fd157162a92d1b9a67](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1bac12871ea0b42d261c20fd157162a92d1b9a67)
- [783a24f3bb45d325fd1cb567c6cf37d83491d46d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/783a24f3bb45d325fd1cb567c6cf37d83491d46d)
- [33908ad7eb543789b6e9c250b6d32f855955654b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/33908ad7eb543789b6e9c250b6d32f855955654b)
- [904c7865e1f1b7c25ea714cb8c0b4b3f6f75992c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/904c7865e1f1b7c25ea714cb8c0b4b3f6f75992c)
- [dc9588172e09c7f13cc11d96934a6479a6c061b5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dc9588172e09c7f13cc11d96934a6479a6c061b5)
- [361283c8a29186cbf9fdc92e250a2c7af61009d3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/361283c8a29186cbf9fdc92e250a2c7af61009d3)
- [26fd15c867f672578f306e33d29e10100dfd92ac](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/26fd15c867f672578f306e33d29e10100dfd92ac)
- [4e7613d322843cc8b8a29b3f88bbc8ed839cf7f3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4e7613d322843cc8b8a29b3f88bbc8ed839cf7f3)
- [ff099923ef743ddeb23b73f9888c06d06dcf99c3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ff099923ef743ddeb23b73f9888c06d06dcf99c3)
- [5c7cc4a308b4d272c57da32b3688aee78514d75e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5c7cc4a308b4d272c57da32b3688aee78514d75e)
- [5e3d8816b049aa3fe07c9df28b90f441a81a37f8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5e3d8816b049aa3fe07c9df28b90f441a81a37f8)
- [cfef58c854de7c1d86618c3c7d03eb469254ceb5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cfef58c854de7c1d86618c3c7d03eb469254ceb5)
- [afe1103e8a492362a4092452268bcd32b8261a60](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/afe1103e8a492362a4092452268bcd32b8261a60)
- [7b29aa0e1df2233fca99dd1832f8aff2cb2f5385](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7b29aa0e1df2233fca99dd1832f8aff2cb2f5385)
- [8006e1409cba83d7b2c235e721d2bd32376d0e12](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8006e1409cba83d7b2c235e721d2bd32376d0e12)
- [c1b876b372bfd2f7ce86b5e294d29a09ce19e6e2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c1b876b372bfd2f7ce86b5e294d29a09ce19e6e2)
- [ee594b61bfa882bae6066af29d640b0d8b8bbf12](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ee594b61bfa882bae6066af29d640b0d8b8bbf12)
- [1763f318894ab4568c1c264fa18b75ef2302580c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1763f318894ab4568c1c264fa18b75ef2302580c)
- [f90a6bea987ee3b062fefe3ff7e406aeceb0e65f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f90a6bea987ee3b062fefe3ff7e406aeceb0e65f)
- [3a1367b426bd2b5efcc8155d40edc731d43914a3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3a1367b426bd2b5efcc8155d40edc731d43914a3)
- [88af3daa473b644575b4b6c08a043975ac604e90](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/88af3daa473b644575b4b6c08a043975ac604e90)
- [73062c512fec6b01e03b9d308842f195cd9eee8c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/73062c512fec6b01e03b9d308842f195cd9eee8c)
- [3139c417ed0e3cc1e124dfc7323ffcd74fdb1766](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3139c417ed0e3cc1e124dfc7323ffcd74fdb1766)
- [9a1ca6aa6f63f6741d9699ba26069982235af243](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9a1ca6aa6f63f6741d9699ba26069982235af243)
- [177902220385ad43e1b04a9f84dc7d7478974716](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/177902220385ad43e1b04a9f84dc7d7478974716)
- [f541e1c2382b331a6c9b814674bfd1adce4d31a6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f541e1c2382b331a6c9b814674bfd1adce4d31a6)
- [7a6774ff77a1c3e44cfcc3211a59ef2eaf5c2711](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7a6774ff77a1c3e44cfcc3211a59ef2eaf5c2711)
- [aec598d9d98466b6bbe04752b31d40ec7e4a3ace](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/aec598d9d98466b6bbe04752b31d40ec7e4a3ace)
- [57ec581f7856954f6f6b95e8608426800b312613](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/57ec581f7856954f6f6b95e8608426800b312613)
- [58b2608185d2dc65bfac578da6e06c5ccd1fe8dc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/58b2608185d2dc65bfac578da6e06c5ccd1fe8dc)
- [0399a6a629e1446bb0ebcc28d59d463b74e38e2c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0399a6a629e1446bb0ebcc28d59d463b74e38e2c)
- [6425a72dc802c95352733f8c1d860ec99eec69a0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6425a72dc802c95352733f8c1d860ec99eec69a0)
- [965366a9463cdb6c6386f0ec2610a4c2abc3e8bf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/965366a9463cdb6c6386f0ec2610a4c2abc3e8bf)
- [08326c1f7177d00da27fb5c0c5ae31f758c722ed](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/08326c1f7177d00da27fb5c0c5ae31f758c722ed)
- [70e73387adda26f5d7df2a7473d03b6dc5c219e8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/70e73387adda26f5d7df2a7473d03b6dc5c219e8)
- [cfb644ce422d8c1ec80f0967b30305be3f4b40e8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cfb644ce422d8c1ec80f0967b30305be3f4b40e8)
- [79d8eb8e65f0322d6d52ac8bb712fe933e50dfc4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/79d8eb8e65f0322d6d52ac8bb712fe933e50dfc4)
- [a55cda446939eba35868cb97202d1f671964b7e6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a55cda446939eba35868cb97202d1f671964b7e6)
- [74fc2e486ff596beca710ee7cfd06138d0af4442](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/74fc2e486ff596beca710ee7cfd06138d0af4442)
- [c1b256e23c751e6f955b0c5ed77cd4a066254e19](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c1b256e23c751e6f955b0c5ed77cd4a066254e19)
- [6be93dcfdd6418a4e962b0781157e5f205deec8e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6be93dcfdd6418a4e962b0781157e5f205deec8e)
- [9e90e0ba801f5c16fbb4950c8cae55c4bcfb12e8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9e90e0ba801f5c16fbb4950c8cae55c4bcfb12e8)
- [d7f0acb9a804adacbd56d26c3b704c5fb9433fe9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d7f0acb9a804adacbd56d26c3b704c5fb9433fe9)
- [f75bb4275be87faa1707556170247c6be837cf7c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f75bb4275be87faa1707556170247c6be837cf7c)
- [0afd11dc9792d56cdb33084e0f81a9cd74d47069](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0afd11dc9792d56cdb33084e0f81a9cd74d47069)
- [bab59df118bd864ff07567a8ed4e68d43bcfa93e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bab59df118bd864ff07567a8ed4e68d43bcfa93e)
- [8f31aa32d029be036f18ecbd50d6411b60a14507](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8f31aa32d029be036f18ecbd50d6411b60a14507)

## Changes Storefront Image Collection Logic; Adds Product Templates

Changes image collection logic to improve matching of images in the Storefront regardless of product template.

Adds “Option Selects” and “Option Thumbnails” product templates. Adds methods to the `Details` interface.

### Issues

- [ECOMMERCE-5226](https://jira.tools.weblinc.com/browse/ECOMMERCE-5226)
- [ECOMMERCE-5746](https://jira.tools.weblinc.com/browse/ECOMMERCE-5746)
- [ECOMMERCE-5779](https://jira.tools.weblinc.com/browse/ECOMMERCE-5779)
- [ECOMMERCE-5812](https://jira.tools.weblinc.com/browse/ECOMMERCE-5812)
- [ECOMMERCE-5881](https://jira.tools.weblinc.com/browse/ECOMMERCE-5881)
- [ECOMMERCE-5932](https://jira.tools.weblinc.com/browse/ECOMMERCE-5932)
- [ECOMMERCE-6077](https://jira.tools.weblinc.com/browse/ECOMMERCE-6077)

### Pull Requests

- [3052](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3052/overview)
- [3131](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3131/overview)
- [3171](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3171/overview)
- [3179](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3179/overview)
- [3186](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3186/overview)
- [3189](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3189/overview)
- [3190](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3190/overview)
- [3229](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3229/overview)
- [3323](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3323/overview)
- [3404](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3404/overview)

### Commits

- [b7537102b343d938baaa86443c4d7e25c5fa6199](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b7537102b343d938baaa86443c4d7e25c5fa6199)
- [fc91a717b93df80720b278b260a1d2ea43a51cc3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fc91a717b93df80720b278b260a1d2ea43a51cc3)
- [e917dc000f99b2a4c967d816feb904402575a83f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e917dc000f99b2a4c967d816feb904402575a83f)
- [0100274a53317061c6db88710ff7dda6bb846bee](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0100274a53317061c6db88710ff7dda6bb846bee)
- [ab709d7e327107273924e5f8bfb775fbe0b63c10](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ab709d7e327107273924e5f8bfb775fbe0b63c10)
- [d1621417406e6a43f4ca6f8c13672b488844dc93](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d1621417406e6a43f4ca6f8c13672b488844dc93)
- [901a1e5ed14f78e3129c44d65e295ee660fd4184](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/901a1e5ed14f78e3129c44d65e295ee660fd4184)
- [56c30a845daac71e00882029e1fc3d67037844d8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/56c30a845daac71e00882029e1fc3d67037844d8)
- [c74240c7dab7dd626274aafe9b9d35f4a8ca24a5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c74240c7dab7dd626274aafe9b9d35f4a8ca24a5)
- [c406fc962dd1451d46228fa96bdb69cc660ae29d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c406fc962dd1451d46228fa96bdb69cc660ae29d)
- [54b58a401ad6bd8baa47c7dc9c263b87cd3b8bad](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/54b58a401ad6bd8baa47c7dc9c263b87cd3b8bad)
- [714f6c57e8a3a8f325a06c7c8527a199e516dc11](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/714f6c57e8a3a8f325a06c7c8527a199e516dc11)
- [9fea89918a11ca38684f89815516d69e8f9a64ff](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9fea89918a11ca38684f89815516d69e8f9a64ff)
- [bd231c0e437f49c7dd19a56493bcb281bb9c6862](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bd231c0e437f49c7dd19a56493bcb281bb9c6862)
- [e5e3422652479c9e861446b1a93eff7134a22389](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e5e3422652479c9e861446b1a93eff7134a22389)
- [eb084f36132026c064d0624f5a82db3bf10bca68](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eb084f36132026c064d0624f5a82db3bf10bca68)
- [45d05891e5207d5df93894f0b56ba3829727f780](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/45d05891e5207d5df93894f0b56ba3829727f780)
- [70fec33197fd899df089d87f6c8ec12a2cf7d81d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/70fec33197fd899df089d87f6c8ec12a2cf7d81d)
- [0e0030f9b7b1ba298ac377005b97eae5f5877b60](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0e0030f9b7b1ba298ac377005b97eae5f5877b60)
- [42f4747fb1910be76cf3fe87dac05bcd7547492d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/42f4747fb1910be76cf3fe87dac05bcd7547492d)
- [93d020281b34f731a9a8031324ef5493c5f35f34](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/93d020281b34f731a9a8031324ef5493c5f35f34)
- [0c4f6e287e1895ab8ef37b42db801888dbef9b24](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0c4f6e287e1895ab8ef37b42db801888dbef9b24)
- [424941735549e58bb303062c12e772b92515d2d9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/424941735549e58bb303062c12e772b92515d2d9)

## Deprecates Releases Calendar; Changes Setting of Super Admin Permissions; Adds Releases Calendar Feed

Deprecates the releases calendar within the Admin, which will be removed in Workarea 3.4. Removes link to the releases calendar from the releases index. Retailers are encouraged to use the releases calendar feed instead (see below).

Changes how permissions are set for super admins.

Adds to the Admin a releases calendar feed, which is accessible to administrators with an authentication token for this feature (and super admins). Allows admins to view and subscribe to the calendar of releases within an external calendar client, such as Google Calendar, Apple Calendar, or Outlook.

### Issues

- [ECOMMERCE-5668](https://jira.tools.weblinc.com/browse/ECOMMERCE-5668)
- [ECOMMERCE-5782](https://jira.tools.weblinc.com/browse/ECOMMERCE-5782)
- [ECOMMERCE-5783](https://jira.tools.weblinc.com/browse/ECOMMERCE-5783)
- [ECOMMERCE-5784](https://jira.tools.weblinc.com/browse/ECOMMERCE-5784)
- [ECOMMERCE-5795](https://jira.tools.weblinc.com/browse/ECOMMERCE-5795)
- [ECOMMERCE-5799](https://jira.tools.weblinc.com/browse/ECOMMERCE-5799)
- [ECOMMERCE-5798](https://jira.tools.weblinc.com/browse/ECOMMERCE-5798)
- [ECOMMERCE-6031](https://jira.tools.weblinc.com/browse/ECOMMERCE-6031)
- [ECOMMERCE-5796](https://jira.tools.weblinc.com/browse/ECOMMERCE-5796)
- [ECOMMERCE-6040](https://jira.tools.weblinc.com/browse/ECOMMERCE-6040)

### Pull Requests

- [3128](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3128/overview)
- [3185](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3185/overview)
- [3187](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3187/overview)
- [3191](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3191/overview)
- [3197](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3197/overview)
- [3210](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3210/overview)
- [3297](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3297/overview)
- [3342](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3342/overview)
- [3373](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3373/overview)
- [3362](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3362/overview)
- [3393](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3393/overview)
- [3391](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3391/overview)

### Commits

- [8e2c3c9e62213a59bcd9ebeaa73f93f0863668da](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8e2c3c9e62213a59bcd9ebeaa73f93f0863668da)
- [a926f49354bbe385c439caf8731e861e8bc5bda1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a926f49354bbe385c439caf8731e861e8bc5bda1)
- [d24d8464cd507bfc1520ed99a197fd8a117c7657](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d24d8464cd507bfc1520ed99a197fd8a117c7657)
- [ee75dd00a98b79fe2792dfe56ee436c3ba22f13e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ee75dd00a98b79fe2792dfe56ee436c3ba22f13e)
- [ee4df21e044a4e91930421d96c7bec41b344ee27](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ee4df21e044a4e91930421d96c7bec41b344ee27)
- [4dcc1239126839b6ef5f07fdd22e37073861d9da](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4dcc1239126839b6ef5f07fdd22e37073861d9da)
- [4ea456dbbfef905fd09474e923ec7e9e8b436e9f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4ea456dbbfef905fd09474e923ec7e9e8b436e9f)
- [d66bfd3cbe1f775949949c97201cd56351afcf3f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d66bfd3cbe1f775949949c97201cd56351afcf3f)
- [da389c690b58522b07ed26112472e122dd260f78](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/da389c690b58522b07ed26112472e122dd260f78)
- [5c33c582ac40e2f963184fa996139031348635a5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5c33c582ac40e2f963184fa996139031348635a5)
- [17d3702a1845a39f2dc1252e5348924048b42c2c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/17d3702a1845a39f2dc1252e5348924048b42c2c)
- [611b2d3a3c0be4361520dadb92df4be86ce79857](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/611b2d3a3c0be4361520dadb92df4be86ce79857)
- [7410e2693eb6cc3b71db833520e846402580403f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7410e2693eb6cc3b71db833520e846402580403f)
- [c7a94fb878e95129be83689fd9589129adb7b70e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c7a94fb878e95129be83689fd9589129adb7b70e)
- [9a659c26bd4ff836719240847a4ff86c7b53ecea](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9a659c26bd4ff836719240847a4ff86c7b53ecea)
- [b350b2bf9cf7d5b608f843216964b06c711f4368](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b350b2bf9cf7d5b608f843216964b06c711f4368)
- [7310b3807347057548035dc2edab1903403e46d1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7310b3807347057548035dc2edab1903403e46d1)
- [852104e279f6b50c8b1b4cc64aff5350a73707c3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/852104e279f6b50c8b1b4cc64aff5350a73707c3)
- [7508dcdda90ed268f9d44ea77a703e589ea6d9f1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7508dcdda90ed268f9d44ea77a703e589ea6d9f1)
- [d5c92c2db3656c8700322b9e117f06410b1b35c7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d5c92c2db3656c8700322b9e117f06410b1b35c7)
- [ff0d0a1b53de035bdb1e8b5a373448a412985e6d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ff0d0a1b53de035bdb1e8b5a373448a412985e6d)
- [a53bd195924deb93f6aded72af965d03d8ec0446](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a53bd195924deb93f6aded72af965d03d8ec0446)
- [a356356c26c90a22be5408d389972777397aeade](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a356356c26c90a22be5408d389972777397aeade)
- [9e31941a28c489b596084e036aba740de907030e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9e31941a28c489b596084e036aba740de907030e)
- [454e294bcd92c2d2d947c85b156c3b8b79d04a21](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/454e294bcd92c2d2d947c85b156c3b8b79d04a21)

## Adds Low Inventory Report in Admin

Adds a “low inventory report” to the Admin, which includes all inventory SKUs whose `sellable` is below the configured low inventory threshold. The report is accessible from the inventory SKUs index. The `sellable` field, which is affected by inventory policy, is new in this change and considered experimental (may be removed in the future).

**Data changes are required to ensure the low inventory report is accurate in an existing environment.** Touch each existing inventory SKU to populate the `sellable` field. The field is set during the `before_validation` callback, or explicitly using `Inventory::Sku#set_sellable`.

### Issues

- [ECOMMERCE-5665](https://jira.tools.weblinc.com/browse/ECOMMERCE-5665)
- [ECOMMERCE-5704](https://jira.tools.weblinc.com/browse/ECOMMERCE-5704)

### Pull Requests

- [3105](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3105/overview)
- [3116](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3116/overview)

### Commits

- [2e35fb309583b24a4692ef25bc146403bbbe1462](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2e35fb309583b24a4692ef25bc146403bbbe1462)
- [e3a85696bd7d4dbe89cd2a59664569834d05db91](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e3a85696bd7d4dbe89cd2a59664569834d05db91)
- [bc0bc8f5a4797be23e9232103e37d306235c2be7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bc0bc8f5a4797be23e9232103e37d306235c2be7)
- [08d733d0f37701e6cb2e15028d22d66c96ea25b3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/08d733d0f37701e6cb2e15028d22d66c96ea25b3)

## Adds “Displayable When Out of Stock” Inventory Policy

Adds new inventory policy for “Displayable When Out of Stock”. Changes product display rules in the Storefront to incorporate this change (the matching product is included in results, but sorted to the bottom). Changes product `purchasable?` logic in the Storefront to include inventory.

### Issues

- [ECOMMERCE-5626](https://jira.tools.weblinc.com/browse/ECOMMERCE-5626)
- [ECOMMERCE-5937](https://jira.tools.weblinc.com/browse/ECOMMERCE-5937)
- [ECOMMERCE-5938](https://jira.tools.weblinc.com/browse/ECOMMERCE-5938)
- [ECOMMERCE-5941](https://jira.tools.weblinc.com/browse/ECOMMERCE-5941)

### Pull Requests

- [3248](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3248/overview)
- [3277](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3277/overview)
- [3279](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3279/overview)
- [3309](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3309/overview)

### Commits

- [f653c6c54ca9a1c7dff513d3c9e475a5e1fe3b0a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f653c6c54ca9a1c7dff513d3c9e475a5e1fe3b0a)
- [1c45194158344b6493959721806fa75ce9910727](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1c45194158344b6493959721806fa75ce9910727)
- [a3424016c72d979728daf1b5a7d8e7b11f4be05e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a3424016c72d979728daf1b5a7d8e7b11f4be05e)
- [3666d0ad32f2f5861ce0b8337081ca0e72d6e305](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3666d0ad32f2f5861ce0b8337081ca0e72d6e305)
- [ca84996d76d9237391d0c0e4e3ab84ab08a915e3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ca84996d76d9237391d0c0e4e3ab84ab08a915e3)
- [a6db715221077235f4e720fd0b7ac1b2e455be86](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a6db715221077235f4e720fd0b7ac1b2e455be86)
- [d1b434b00028793ff3f440686b65fbb8f2d94a02](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d1b434b00028793ff3f440686b65fbb8f2d94a02)
- [182bad20337413e7b6b80bbb9ceb9f9cff9dcaa9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/182bad20337413e7b6b80bbb9ceb9f9cff9dcaa9)

## Changes Setting of Cache Expirations; Adds Cache Varying

Moves cache expirations into configuration. This includes fragment cache expirations, which were previously declared in views/partials.

**If you are overriding any of the changed views/partials, your application will continue to use the values in the views instead of the values in configuration.**

Adds an easy way to vary Rack cache and fragment caches. _This is very dangerous, and should be used with great care._ See the documentation on `Workarea::Cache::Varies.on` for more details.

### Issues

- [ECOMMERCE-5780](https://jira.tools.weblinc.com/browse/ECOMMERCE-5780)
- [ECOMMERCE-5961](https://jira.tools.weblinc.com/browse/ECOMMERCE-5961)

### Pull Requests

- [3234](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3234/overview)
- [3295](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3295/overview)

### Commits

- [fce872afd2e197b98cc6a68b1cb2b5ef81f77025](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fce872afd2e197b98cc6a68b1cb2b5ef81f77025)
- [05d41672b2aa32125dcdcf8aec2e303388e776e4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/05d41672b2aa32125dcdcf8aec2e303388e776e4)
- [ed54abf925cf20e0fd2f4b1942f0d6cc98748cef](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ed54abf925cf20e0fd2f4b1942f0d6cc98748cef)
- [f5680cccd5958586addec3b227407991fb7039a3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f5680cccd5958586addec3b227407991fb7039a3)
- [95efe1fb6908f851afb0854da5df7d351984aff6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/95efe1fb6908f851afb0854da5df7d351984aff6)

## Changes Address Modeling; Adds Configuration for PO Box Acceptance

Restructures the modeling of addresses to introduce the idea of PO Box acceptance. Adds configs for PO Box acceptance. Improves regex for matching PO Boxes.

### Issues

- [ECOMMERCE-5664](https://jira.tools.weblinc.com/browse/ECOMMERCE-5664)
- [ECOMMERCE-5703](https://jira.tools.weblinc.com/browse/ECOMMERCE-5703)

### Pull Requests

- [3107](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3107/overview)
- [3124](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3124/overview)

### Commits

- [9a4c115d1f429cb33f5c5a73b5911024b79aec98](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9a4c115d1f429cb33f5c5a73b5911024b79aec98)
- [ee5819d79c85b38c416436ef1529a20c7eeb86c7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ee5819d79c85b38c416436ef1529a20c7eeb86c7)
- [e290a8ad24e2a7ec2cbef8c7d60a95f3d80ce912](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e290a8ad24e2a7ec2cbef8c7d60a95f3d80ce912)
- [ccca905afd87e5ffa8d52daf7b43203ee61f2a95](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ccca905afd87e5ffa8d52daf7b43203ee61f2a95)

## Changes Source Location of Categorized Autocomplete

Moves the implementation of categorized autocomplete from Core, duplicating it within Admin and Storefront. This change allows the feature to be extended separately for each UI.

**If your application is overriding the categorized autocomplete sources or the Admin or Storefront manifests, you will need to update those files accordingly.** You should see a message in the JavaScript console about these changes.

### Issues

- [ECOMMERCE-5950](https://jira.tools.weblinc.com/browse/ECOMMERCE-5950)

### Pull Requests

- [3300](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3300/overview)

### Commits

- [b3960dd1f217acf4e0b4fdcedd051e8d21d2f93e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b3960dd1f217acf4e0b4fdcedd051e8d21d2f93e)
- [15e09dfa4b78595c7ccd2dc94de139c4a8321f32](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/15e09dfa4b78595c7ccd2dc94de139c4a8321f32)

## Removes jQuery Validation from Admin

Removes jQuery Validation as an Admin dependency, relying on native validation within each browser instead. Also moves the previously shared configuration from Core to Storefront (where it is now used exclusively).

If your application happens to be overriding the JavaScript configuration file (not recommended), you'll need to move the changes from Core to Storefront manually.

### Issues

- [ECOMMERCE-6056](https://jira.tools.weblinc.com/browse/ECOMMERCE-6056)

### Pull Requests

- [3394](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3394/overview)

### Commits

- [df488ff3a07b112d5b1e40c7472fa774f33f3a66](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/df488ff3a07b112d5b1e40c7472fa774f33f3a66)
- [7a477cadd089b91a3deb06d08fa9215fcd677edf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7a477cadd089b91a3deb06d08fa9215fcd677edf)

## Removes Deprecated Feature Spec Helpers

Removes the _feature\_spec\_helper.\*_ assets, which were renamed to _feature\_test\_helper.\*_ and deprecated by Workarea 3.2.0.

### Issues

- [ECOMMERCE-6075](https://jira.tools.weblinc.com/browse/ECOMMERCE-6075)

### Commits

- [7e366e43222cd0594896fceee11ce329c661f343](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7e366e43222cd0594896fceee11ce329c661f343)

## Adds Favicon Administration & Automation

Allows admins to select images to be used as favicons. Automates the creation of the necessary images and code for user agents to support the varying favicon formats.

### Issues

- [ECOMMERCE-5769](https://jira.tools.weblinc.com/browse/ECOMMERCE-5769)
- [ECOMMERCE-5955](https://jira.tools.weblinc.com/browse/ECOMMERCE-5955)
- [ECOMMERCE-6049](https://jira.tools.weblinc.com/browse/ECOMMERCE-6049)

### Pull Requests

- [3260](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3260/overview)
- [3289](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3289/overview)
- [3382](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3382/overview)

### Commits

- [3e7873bc7eb9979ba6aaa10d2c9c5cf1b31b7cf4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3e7873bc7eb9979ba6aaa10d2c9c5cf1b31b7cf4)
- [522c93436ca6294715d742a7ff7ab0b27a666031](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/522c93436ca6294715d742a7ff7ab0b27a666031)
- [2c3f30ed28ff275d9432d2f6dac514b2080735a1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2c3f30ed28ff275d9432d2f6dac514b2080735a1)
- [355ec8704f65880ca8871f1985b2809820c36618](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/355ec8704f65880ca8871f1985b2809820c36618)
- [66b7d2592747097152e38c64b6fe11412353952c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/66b7d2592747097152e38c64b6fe11412353952c)
- [5b919e5660c959dce6636bd78c1242853b4ec23f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5b919e5660c959dce6636bd78c1242853b4ec23f)

## Adds Configurations for Search Facet Sorting

Adds several configs to allow applications to control the ordering of search facet values.

### Issues

- [ECOMMERCE-5996](https://jira.tools.weblinc.com/browse/ECOMMERCE-5996)

### Pull Requests

- [3350](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3350/overview)
- [3386](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3386/overview)

### Commits

- [54557f35ebcc95433dc44e76fa17042c8cf7442c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/54557f35ebcc95433dc44e76fa17042c8cf7442c)
- [3358273af89d8d153e19b2f811f4436291434d7d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3358273af89d8d153e19b2f811f4436291434d7d)
- [ad23839fabc38b901365711843064fd86073e0b6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ad23839fabc38b901365711843064fd86073e0b6)
- [472eb0737c3e2535fb6a9f9588a5c624f94741bc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/472eb0737c3e2535fb6a9f9588a5c624f94741bc)

## Changes Admin Alerts for Consistency; Adds New Alerts

Updates all Admin alerts messaging for consistency and internationalization. Adds two additional Admin alerts: “Variant Missing Details” and “Inconsistent Variant Details”.

### Issues

- [ECOMMERCE-5710](https://jira.tools.weblinc.com/browse/ECOMMERCE-5710)
- [ECOMMERCE-5760](https://jira.tools.weblinc.com/browse/ECOMMERCE-5760)

### Pull Requests

- [3160](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3160/overview)
- [3165](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3165/overview)

### Commits

- [509b123352018e2cbd7c77798773354897e82ea2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/509b123352018e2cbd7c77798773354897e82ea2)
- [e5fe086ea54da2354e5ed2126c4f19fea0471364](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e5fe086ea54da2354e5ed2126c4f19fea0471364)
- [ad683a200a6e20a61e8b12ee5bc7b700b4056218](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ad683a200a6e20a61e8b12ee5bc7b700b4056218)
- [773cc8d93b8d406e256dd5e8da52968e348a5a1f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/773cc8d93b8d406e256dd5e8da52968e348a5a1f)
- [56abcf90ff83f8d5547a9dce7ab4de7ac928c569](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/56abcf90ff83f8d5547a9dce7ab4de7ac928c569)

## Changes Insights Cards; Adds Sparklines to Admin

Improves the UI of insights cards throughout Admin show pages. Adds sparklines to various Admin screens to provide inline insights.

### Issues

- [ECOMMERCE-5678](https://jira.tools.weblinc.com/browse/ECOMMERCE-5678)
- [ECOMMERCE-5903](https://jira.tools.weblinc.com/browse/ECOMMERCE-5903)

### Pull Requests

- [3123](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3123/overview)
- [3288](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3288/overview)

### Commits

- [b611c8b489e5177934d996bae69b4e80e5a0fc7d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b611c8b489e5177934d996bae69b4e80e5a0fc7d)
- [b9c68e8f6a53bd63933a1802ef7fdef200fbfd69](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b9c68e8f6a53bd63933a1802ef7fdef200fbfd69)
- [96c5948d5142692498fadde92e7b9151d0452944](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/96c5948d5142692498fadde92e7b9151d0452944)
- [4b60c11ca84df53f6599746c68ffdf8a2ecdff2f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4b60c11ca84df53f6599746c68ffdf8a2ecdff2f)

## Adds Admin Guest Browsing

Adds guest browsing for admins, allowing them to create and place orders on behalf of customers without requiring the customers to have or create accounts. Accessible from the users index.

### Issues

- [ECOMMERCE-5666](https://jira.tools.weblinc.com/browse/ECOMMERCE-5666)
- [ECOMMERCE-5729](https://jira.tools.weblinc.com/browse/ECOMMERCE-5729)
- [ECOMMERCE-5731](https://jira.tools.weblinc.com/browse/ECOMMERCE-5731)

### Pull Requests

- [3102](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3102/overview)
- [3133](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3133/overview)
- [3134](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3134/overview)

### Commits

- [48b739422c711bdef82378ce8d4fa0c10f28658f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/48b739422c711bdef82378ce8d4fa0c10f28658f)
- [2b6ecaa63cddf62841cc9ee67c1194dfd31926fc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2b6ecaa63cddf62841cc9ee67c1194dfd31926fc)
- [9d5068553d0be7b50df41e83e4e09561caad21a5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9d5068553d0be7b50df41e83e4e09561caad21a5)
- [66c5f0e4e98726e2b99d087ae3baf0919884c509](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/66c5f0e4e98726e2b99d087ae3baf0919884c509)
- [f78dc68b187252692acf0b13edb93370c115ac72](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f78dc68b187252692acf0b13edb93370c115ac72)
- [5f87f27627d619979e7765835b82f3fc23c4a182](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5f87f27627d619979e7765835b82f3fc23c4a182)

## Adds Email Signups Admin

Adds email signups index page to the Admin, accessible from the primary navigation, jump-to navigation, and marketing dashboard. Allows admins to remove users from email signups and delete email signups.

### Issues

- [ECOMMERCE-5711](https://jira.tools.weblinc.com/browse/ECOMMERCE-5711)
- [ECOMMERCE-5744](https://jira.tools.weblinc.com/browse/ECOMMERCE-5744)
- [ECOMMERCE-5900](https://jira.tools.weblinc.com/browse/ECOMMERCE-5900)
- [ECOMMERCE-5901](https://jira.tools.weblinc.com/browse/ECOMMERCE-5901)

### Pull Requests

- [3136](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3136/overview)
- [3149](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3149/overview)
- [3324](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3324/overview)

### Commits

- [b0df5244bf04410ec5fa91904d71b63e621a093b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b0df5244bf04410ec5fa91904d71b63e621a093b)
- [de7b1bf911bd3389c7321bf6c3d8b2c209f3e568](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/de7b1bf911bd3389c7321bf6c3d8b2c209f3e568)
- [8b2a80c2b5c656d8953825ddf4b28de28a8e791c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8b2a80c2b5c656d8953825ddf4b28de28a8e791c)
- [1e11cf162615d0ab5e621a711a503fc1a43c552f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1e11cf162615d0ab5e621a711a503fc1a43c552f)
- [46c66b92fb979a6c64e3fde7d46aa90187533105](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/46c66b92fb979a6c64e3fde7d46aa90187533105)
- [0ea311b8a179016d6f92dd7aa1e2213f154822a9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0ea311b8a179016d6f92dd7aa1e2213f154822a9)
- [9c6e8059c9a6a7fd9476923f3cc7c20ba81a9c97](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9c6e8059c9a6a7fd9476923f3cc7c20ba81a9c97)

## Changes Error Pages

Changes error pages to always use the Workarea error page controller and view rather than falling back to Rails' static HTML pages. Creates the corresponding system content if it does not exist.

### Issues

- [ECOMMERCE-5914](https://jira.tools.weblinc.com/browse/ECOMMERCE-5914)

### Pull Requests

- [3290](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3290/overview)

### Commits

- [9d63b38033a3d24b949b6ee6081180f9de9f8afe](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9d63b38033a3d24b949b6ee6081180f9de9f8afe)
- [f6002a4f0ba57024d0a0fd833740f9d5b42e12c5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f6002a4f0ba57024d0a0fd833740f9d5b42e12c5)

## Changes Product Rule Logic & Previewing

Allows admins to include undisplayable products when previewing rules in the Storefront. Adds a “not equal” operator to _category_ product rule fields. Changes boolean values in category rules to be case insensitive.

### Issues

- [ECOMMERCE-4070](https://jira.tools.weblinc.com/browse/ECOMMERCE-4070)
- [ECOMMERCE-5104](https://jira.tools.weblinc.com/browse/ECOMMERCE-5104)
- [ECOMMERCE-5915](https://jira.tools.weblinc.com/browse/ECOMMERCE-5915)
- [ECOMMERCE-5930](https://jira.tools.weblinc.com/browse/ECOMMERCE-5930)

### Pull Requests

- [3120](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3120/overview)
- [3112](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3112/overview)
- [3264](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3264/overview)
- [3335](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3335/overview)

### Commits

- [42123a3952c1e1ef6f0c2f244981be4c81a592e4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/42123a3952c1e1ef6f0c2f244981be4c81a592e4)
- [48e3fe0c77b585936eb433b7539615cd70e72606](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/48e3fe0c77b585936eb433b7539615cd70e72606)
- [5735c28e73ebb9011d7d51d0be54e1117bbdd723](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5735c28e73ebb9011d7d51d0be54e1117bbdd723)
- [eda5398e033900253a4457a5ee5ca74351fad536](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eda5398e033900253a4457a5ee5ca74351fad536)
- [ee3785db1e3a274881ba108b14341ab2dfd387e2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ee3785db1e3a274881ba108b14341ab2dfd387e2)
- [1ed8c883eceb97dc83eab6b3bdd482b10d7c2eff](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1ed8c883eceb97dc83eab6b3bdd482b10d7c2eff)
- [12fcd3ab53608fc5b33a537edf6603e8794fb995](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/12fcd3ab53608fc5b33a537edf6603e8794fb995)
- [4f3fefc2e31ccbeab2e24d9c51d06c2331c22996](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4f3fefc2e31ccbeab2e24d9c51d06c2331c22996)

## Changes Display Logic for Flash Error Messages

Changes flash messages in the Admin and Storefront to not auto-dismiss if the message type is _error_.

### Issues

- [ECOMMERCE-5876](https://jira.tools.weblinc.com/browse/ECOMMERCE-5876)

### Pull Requests

- [3286](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3286/overview)

### Commits

- [294aac18745cd8668f7d12d9d00f0390768458ba](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/294aac18745cd8668f7d12d9d00f0390768458ba)
- [108996ff5b22abd4081afb1b37b68a432be41002](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/108996ff5b22abd4081afb1b37b68a432be41002)

## Adds Shipping Instructions

Allows consumers to provide shipping instructions during checkout. Stored on the `Shipping` instance. Displays in most order UIs throughout the Admin and Storefront.

### Issues

- [ECOMMERCE-6047](https://jira.tools.weblinc.com/browse/ECOMMERCE-6047)

### Pull Requests

- [3387](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3387/overview)

### Commits

- [1787434aee694c4148c85fe4fd178c7db86c7c61](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1787434aee694c4148c85fe4fd178c7db86c7c61)
- [dfc7de7a76a86d3dc73d66b58868da4599204e11](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dfc7de7a76a86d3dc73d66b58868da4599204e11)

## Adds “Range” Content Fields

Adds a new content field type, `Range`, which presents a range control for selecting a numerical value (float).

### Issues

- [ECOMMERCE-6027](https://jira.tools.weblinc.com/browse/ECOMMERCE-6027)

### Pull Requests

- [3370](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3370/overview)

### Commits

- [d3b629986ee972c021da12f1493dbd0b06c4561e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d3b629986ee972c021da12f1493dbd0b06c4561e)
- [ebb53c19e7789adfbc9732d6baa38398b1719fdc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ebb53c19e7789adfbc9732d6baa38398b1719fdc)

## Adds Polyfill for “Color” Fields

Adds a polyfill for `<input type=color>` elements, which are used within content fields of type `Color`. The fields are also used by platform extensions, such as the <cite>Swatches</cite> plugin.

### Issues

- [ECOMMERCE-6043](https://jira.tools.weblinc.com/browse/ECOMMERCE-6043)

### Pull Requests

- [3378](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3378/overview)

### Commits

- [9ef9f328c1c935d4be1442c4ac3dab34ce48b5a8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9ef9f328c1c935d4be1442c4ac3dab34ce48b5a8)
- [7e40797abca71de93035bb508d3521b964303f8b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7e40797abca71de93035bb508d3521b964303f8b)

## Changes Storefront UI According to Baymard Recommendations

Applies various changes throughout the Storefront user interface to improve user experience. Changes are based on research and reports from Baymard Institute.

### Issues

- [ECOMMERCE-5800](https://jira.tools.weblinc.com/browse/ECOMMERCE-5800)
- [ECOMMERCE-5764](https://jira.tools.weblinc.com/browse/ECOMMERCE-5764)
- [ECOMMERCE-5765](https://jira.tools.weblinc.com/browse/ECOMMERCE-5765)
- [ECOMMERCE-5768](https://jira.tools.weblinc.com/browse/ECOMMERCE-5768)
- [ECOMMERCE-5877](https://jira.tools.weblinc.com/browse/ECOMMERCE-5877)
- [ECOMMERCE-5890](https://jira.tools.weblinc.com/browse/ECOMMERCE-5890)
- [ECOMMERCE-5879](https://jira.tools.weblinc.com/browse/ECOMMERCE-5879)

### Pull Requests

- [3178](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3178/overview)
- [3192](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3192/overview)
- [3212](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3212/overview)
- [3217](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3217/overview)
- [3253](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3253/overview)
- [3291](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3291/overview)
- [3308](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3308/overview)
- [3307](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3307/overview)

### Commits

- [0b2143309a987f58bad5de43284c3c7a75459ac4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0b2143309a987f58bad5de43284c3c7a75459ac4)
- [d67cc06c196b2a33222a7d62c2f4c78898f392fc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d67cc06c196b2a33222a7d62c2f4c78898f392fc)
- [089577a874a1225ddc42a347dfad6f12fe6166c2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/089577a874a1225ddc42a347dfad6f12fe6166c2)
- [521f21aafd8f768f490b2187c2c5c30b3bf4d382](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/521f21aafd8f768f490b2187c2c5c30b3bf4d382)
- [34be324afe656439bd0f07fbfa4e41c46d8a4196](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/34be324afe656439bd0f07fbfa4e41c46d8a4196)
- [eabd5e189fbac0990b806b7a2a1722119ff52476](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/eabd5e189fbac0990b806b7a2a1722119ff52476)
- [77d033cb63805552b23e2292f4211d3e28e24169](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/77d033cb63805552b23e2292f4211d3e28e24169)
- [7c50c732eaadc48818b2f3c7ce500b86d947556d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7c50c732eaadc48818b2f3c7ce500b86d947556d)
- [c047b8a6c8cce0dd59461a7ebbc4f38673a34da1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c047b8a6c8cce0dd59461a7ebbc4f38673a34da1)
- [29ea4990cfa674784947f36be73418bb550e2c8f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/29ea4990cfa674784947f36be73418bb550e2c8f)
- [a8056be73f676f632e5d8e66fa281823f7dffce8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a8056be73f676f632e5d8e66fa281823f7dffce8)
- [81edaccf39f6009da84c173d999d4306678608d3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/81edaccf39f6009da84c173d999d4306678608d3)
- [20fae0cbf7d8f7858648ced400d37bb7f815e2c3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/20fae0cbf7d8f7858648ced400d37bb7f815e2c3)
- [d2730f9583f30456fcf088215be81e799ba9b88c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d2730f9583f30456fcf088215be81e799ba9b88c)
- [8657989966172cdc8e41bef6ec965880f4b1701e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8657989966172cdc8e41bef6ec965880f4b1701e)
- [c72407d93932155aaeec8ff1d7a792d10cdfc737](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c72407d93932155aaeec8ff1d7a792d10cdfc737)
- [bfa95afd10cb613327df67bdf527543e599385c3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bfa95afd10cb613327df67bdf527543e599385c3)
- [270eaf399172fb5fd195a63a96e0c1981cd3fa16](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/270eaf399172fb5fd195a63a96e0c1981cd3fa16)
- [076204698a5551dc8d5dbe0c94905c5b8e97d95a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/076204698a5551dc8d5dbe0c94905c5b8e97d95a)
- [200f2530fd177d1e113c16e4813410d8c201f504](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/200f2530fd177d1e113c16e4813410d8c201f504)
- [07212d7f24b591ed2dafe17dc3f9ed00d130812e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/07212d7f24b591ed2dafe17dc3f9ed00d130812e)
- [16cc034cac7af2db25c777c4509a7ba6227b5abc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/16cc034cac7af2db25c777c4509a7ba6227b5abc)

## Changes Admin & Storefront UIs to “Clean Up”

Applies various changes to the Admin and Storefront web interfaces and/or their implementations to clean up minor issues.

### Issues

- [ECOMMERCE-5622](https://jira.tools.weblinc.com/browse/ECOMMERCE-5622)
- [ECOMMERCE-5866](https://jira.tools.weblinc.com/browse/ECOMMERCE-5866)
- [ECOMMERCE-5882](https://jira.tools.weblinc.com/browse/ECOMMERCE-5882)
- [ECOMMERCE-5888](https://jira.tools.weblinc.com/browse/ECOMMERCE-5888)
- [ECOMMERCE-5830](https://jira.tools.weblinc.com/browse/ECOMMERCE-5830)
- [ECOMMERCE-6036](https://jira.tools.weblinc.com/browse/ECOMMERCE-6036)

### Pull Requests

- [3204](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3204/overview)
- [3236](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3236/overview)
- [3247](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3247/overview)
- [3263](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3263/overview)
- [3345](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3345/overview)
- [3396](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3396/overview)

### Commits

- [a65f7a401c8cb4c1a933dab1604fadf5f124c97a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a65f7a401c8cb4c1a933dab1604fadf5f124c97a)
- [544817a7ac91da6119f4554b035955da7669f7d5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/544817a7ac91da6119f4554b035955da7669f7d5)
- [1dfb48b0cd38e320d38b967f16a2098e668dd543](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1dfb48b0cd38e320d38b967f16a2098e668dd543)
- [89192511457610e349544cb8d6d4da61e2f926de](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/89192511457610e349544cb8d6d4da61e2f926de)
- [6c95484809df988abe898674a59c49c06e97f471](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6c95484809df988abe898674a59c49c06e97f471)
- [5ca0094be9cde3257259a268992b6f978bfc2a01](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5ca0094be9cde3257259a268992b6f978bfc2a01)
- [559e026242d535b8ecefbd9c280aff047cdd8e86](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/559e026242d535b8ecefbd9c280aff047cdd8e86)
- [38808f9cce7d43a4ed341eafd9ded593212e28f6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/38808f9cce7d43a4ed341eafd9ded593212e28f6)
- [cc6551c768ff6988e32986b6477c7ca7107268c9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cc6551c768ff6988e32986b6477c7ca7107268c9)
- [779101876617046657a8846f04fe94d484668fab](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/779101876617046657a8846f04fe94d484668fab)
- [4db77f0dd3d6fcca04671d8b2dc4e18305766c8a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4db77f0dd3d6fcca04671d8b2dc4e18305766c8a)
- [73ae0732f5086a6217046e89c795066fe978dd12](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/73ae0732f5086a6217046e89c795066fe978dd12)

## Changes Interfaces & Implementations to Support Plugins

Applies small changes throughout Base to facilitate new plugins and changes to existing plugins.

### Issues

- [ECOMMERCE-5930](https://jira.tools.weblinc.com/browse/ECOMMERCE-5930)
- [ECOMMERCE-5830](https://jira.tools.weblinc.com/browse/ECOMMERCE-5830)
- [ECOMMERCE-5721](https://jira.tools.weblinc.com/browse/ECOMMERCE-5721)
- [ECOMMERCE-5792](https://jira.tools.weblinc.com/browse/ECOMMERCE-5792)
- [ECOMMERCE-5994](https://jira.tools.weblinc.com/browse/ECOMMERCE-5994)

### Pull Requests

- [3155](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3155/overview)
- [3344](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3344/overview)
- [3126](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3126/overview)
- [3249](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3249/overview)
- [3315](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3315/overview)
- [3319](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3319/overview)
- [3363](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3363/overview)
- [3374](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3374/overview)

### Commits

- [176508df46f5384f3bb0e1a828cbdd36477f5009](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/176508df46f5384f3bb0e1a828cbdd36477f5009)
- [5803d56850e6df1183231889dab3af2e05681faf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5803d56850e6df1183231889dab3af2e05681faf)
- [1e73b16b925ac160be6c59d2aedb55cdbeea21d8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1e73b16b925ac160be6c59d2aedb55cdbeea21d8)
- [a4a0295c25ee214794bf51811fdf3064faee142d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a4a0295c25ee214794bf51811fdf3064faee142d)
- [c252201fa3ce927b4db1dce43ea69d2cacbda21c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c252201fa3ce927b4db1dce43ea69d2cacbda21c)
- [c7875d613042a1957060e324f0a39546a273bf6f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c7875d613042a1957060e324f0a39546a273bf6f)
- [5af43f672c79e5a62ec6aa3122952464e3d65d33](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5af43f672c79e5a62ec6aa3122952464e3d65d33)
- [5abc39287c9e5aa4c420afdd8493f240d6492d40](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5abc39287c9e5aa4c420afdd8493f240d6492d40)
- [0aca8cc84ed69c9bc9b987aa1b5859539ef81f5a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0aca8cc84ed69c9bc9b987aa1b5859539ef81f5a)
- [1794b5e0a1488b04a92a3df40b4197909e28911d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1794b5e0a1488b04a92a3df40b4197909e28911d)
- [9246158775fe1586482334d60d94919b43bb4c12](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9246158775fe1586482334d60d94919b43bb4c12)
- [e2d314c79ffaeeca170ab2f702c152a4298aec94](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e2d314c79ffaeeca170ab2f702c152a4298aec94)
- [e90593711a5a96c9d9fee648cfc0920ac60483a8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e90593711a5a96c9d9fee648cfc0920ac60483a8)
- [c81981ee2d2a447c847bdb722858c3a58ad1e9e6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c81981ee2d2a447c847bdb722858c3a58ad1e9e6)
- [a4e8c6f02cf6aa3976a878aa98caff1912a2b6e3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a4e8c6f02cf6aa3976a878aa98caff1912a2b6e3)
- [d665339a3318c0af9ba50615f0e1ee18285f3261](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d665339a3318c0af9ba50615f0e1ee18285f3261)
- [8d3b51893de0b5932c463f54dca317a39d80b40f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8d3b51893de0b5932c463f54dca317a39d80b40f)
- [4e1cf45dde898bb494121658cecc1d53e1561816](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4e1cf45dde898bb494121658cecc1d53e1561816)
- [b0ecc95431b7194d1dfb0af4889453b38694931c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b0ecc95431b7194d1dfb0af4889453b38694931c)
- [6a3ab5b4835e813266d7dbf1949d24d8e83ecfcf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6a3ab5b4835e813266d7dbf1949d24d8e83ecfcf)
- [8ff58d1cb10e317c877b16ef9afdb438ead05f4b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8ff58d1cb10e317c877b16ef9afdb438ead05f4b)
- [2821249437093cdadb88ff9ab11fdd61e9a8ae69](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2821249437093cdadb88ff9ab11fdd61e9a8ae69)
- [80227039aa28f373e16daf8e0e603e9d7716bc64](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/80227039aa28f373e16daf8e0e603e9d7716bc64)
- [bc278ce801383acdd9849faf0bc72eaac25aa54a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bc278ce801383acdd9849faf0bc72eaac25aa54a)

## Adds Options for Manual Search Indexing

Allows disabling the default “inlining” of search indexing, when run manually from the command line. Use `INLINE=false` to disable the default behavior. Example: `INLINE=false bin/rails workarea:search_index:storefront`

Adds `BulkIndexAdmin` worker and uses the worker to implement the `workarea:search_index:admin` task, improving performance.

### Issues

- [ECOMMERCE-5716](https://jira.tools.weblinc.com/browse/ECOMMERCE-5716)
- [ECOMMERCE-5742](https://jira.tools.weblinc.com/browse/ECOMMERCE-5742)

### Pull Requests

- [3161](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3161/overview)
- [3142](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3142/overview)

### Commits

- [ec931d8a892fa67424cb70980164daa2c7007518](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ec931d8a892fa67424cb70980164daa2c7007518)
- [89828c30e1a2c035488455d8c56a01cb83603b84](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/89828c30e1a2c035488455d8c56a01cb83603b84)
- [8521fbdf966b375ebed5c6efec22966eec985078](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8521fbdf966b375ebed5c6efec22966eec985078)
- [b8a64634997de5123bad1b11892ca3b56c3ddf87](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b8a64634997de5123bad1b11892ca3b56c3ddf87)

## Adds Test Runner for Application-Specific Tests

Adds a test runner which runs only the test files located within the application. Example usage: <samp>bin/rails test:app</samp>

### Issues

- [ECOMMERCE-5762](https://jira.tools.weblinc.com/browse/ECOMMERCE-5762)

### Pull Requests

- [3172](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3172/overview)

### Commits

- [4139a2d947d2fd1fc55e3ea2f21d87e0a8e662d7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4139a2d947d2fd1fc55e3ea2f21d87e0a8e662d7)
- [20a26997832645ca1cf97fa163e426e66c09bd67](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/20a26997832645ca1cf97fa163e426e66c09bd67)

## Adds More Analytics Seeds

Adds more analytics seeds to improve local development.

### Issues

- [ECOMMERCE-5739](https://jira.tools.weblinc.com/browse/ECOMMERCE-5739)

### Pull Requests

- [3139](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3139/overview)
- [3146](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3146/overview)

### Commits

- [c94134e4483f5af1f5b01e32f491385a9cbf10fd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c94134e4483f5af1f5b01e32f491385a9cbf10fd)
- [2f2db419991602a095813786c609f5dbb86dc1aa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2f2db419991602a095813786c609f5dbb86dc1aa)
- [1de85cb5f33a780417e816ced37e907fed298fcb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1de85cb5f33a780417e816ced37e907fed298fcb)
- [1e4e92948125b88a8bb4df79b6a2153bda15af73](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1e4e92948125b88a8bb4df79b6a2153bda15af73)

## Changes Scroll-To Buttons Top Offset to a Configurable Value

In the Storefront, makes the `WORKAREA.scrollToButtons` top offset value configurable via `WORKAREA.config.scrollToButtons.topOffset`.

### Issues

- [ECOMMERCE-6045](https://jira.tools.weblinc.com/browse/ECOMMERCE-6045)

### Pull Requests

- [3377](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3377/overview)

### Commits

- [9861d5dd957c8149898d04cbe287aa866257afc8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9861d5dd957c8149898d04cbe287aa866257afc8)
- [2681f7596a34b31d57a86d782555baba776bdc83](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2681f7596a34b31d57a86d782555baba776bdc83)

## Changes Paths to Fix View Overriding

Changes paths to explicitly specify the format as JSON when the endpoint responds to JSON and HTML. Fixes unexpected behavior from Rails when overriding only the JSON view from an application.

### Issues

- [ECOMMERCE-5841](https://jira.tools.weblinc.com/browse/ECOMMERCE-5841)

### Pull Requests

- [3211](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3211/overview)

### Commits

- [1834b1c5f522cc14770fbba48d1fd10420b33ebb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1834b1c5f522cc14770fbba48d1fd10420b33ebb)
- [6536a9d613eb7f71f1def0c12e77ed3c4b985dd9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6536a9d613eb7f71f1def0c12e77ed3c4b985dd9)

## Changes Admin Users Index JSON Response to Include All

Changes the Admin users index JSON to include all matching users, instead of excluding the current user. Use the parameter `exclude_current_user: true` to access the original behavior.

### Pull Requests

- [3360](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3360/overview)

### Commits

- [e9139f9ead3e30bce056c89fb0b7c6c4294e06fd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e9139f9ead3e30bce056c89fb0b7c6c4294e06fd)
- [0b38006decdd279b64903680b4a456e9f740201d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0b38006decdd279b64903680b4a456e9f740201d)

## Changes Logic for “Canceled” Fulfillment Status

Changes `Fulfillment::Status` to be canceled even if items have shipped.

### Pull Requests

- [3209](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3209/overview)

### Commits

- [35a54f9661cf16e80e34d7b1bdfed9ca764ae55c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/35a54f9661cf16e80e34d7b1bdfed9ca764ae55c)
- [0eed9f446bfd504d61598a0ec1e73d51549562e9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0eed9f446bfd504d61598a0ec1e73d51549562e9)

## Changes “Find Pipeline Asset” Query to Include Plugin Paths

Changes `FindPipelineAsset#path` to search plugin paths in addition to the application and Core.

### Issues

- [ECOMMERCE-5981](https://jira.tools.weblinc.com/browse/ECOMMERCE-5981)

### Pull Requests

- [3320](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3320/overview)
- [3332](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3332/overview)

### Commits

- [7447d42b8fde84fb68fdd2ab3f60293a37957ba4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7447d42b8fde84fb68fdd2ab3f60293a37957ba4)
- [ec2163f0717162cee0ca7c993ee690201279786c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ec2163f0717162cee0ca7c993ee690201279786c)
- [ba6e52aa976a6865e4a3c91d8877cbabaabab4ff](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ba6e52aa976a6865e4a3c91d8877cbabaabab4ff)
- [4049d73d7d6f59cc6cc978a3968d795d8c272afb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4049d73d7d6f59cc6cc978a3968d795d8c272afb)

## Changes Cleaning of Expired Orders

Improves order cleaning to remove all expired orders, including those that expired after starting checkout. Previously, these orders weren't cleaned due to oversight.

### Issues

- [ECOMMERCE-5669](https://jira.tools.weblinc.com/browse/ECOMMERCE-5669)
- [ECOMMERCE-5884](https://jira.tools.weblinc.com/browse/ECOMMERCE-5884)

### Pull Requests

- [3169](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3169/overview)
- [3259](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3259/overview)

### Commits

- [04a2b758714d5b16c9d46a5954c3d380b1d6068e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/04a2b758714d5b16c9d46a5954c3d380b1d6068e)
- [40c88b22fe5e97ce82505c0992c230228a9ed739](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/40c88b22fe5e97ce82505c0992c230228a9ed739)
- [c8919ce8cfa270b9a15d3e9d63aee6acb88fea7b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c8919ce8cfa270b9a15d3e9d63aee6acb88fea7b)
- [ab7e7479c5831f5936c2d1bf82a5a81b5298519f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ab7e7479c5831f5936c2d1bf82a5a81b5298519f)

## Adds Locking of Promo Code Lists

Locks promo code lists while generating to avoid unexpected behavior.

### Issues

- [ECOMMERCE-5848](https://jira.tools.weblinc.com/browse/ECOMMERCE-5848)

### Pull Requests

- [3246](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3246/overview)

### Commits

- [f877f5a4acfda929f7ff9cc29a8f2e394789eb64](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f877f5a4acfda929f7ff9cc29a8f2e394789eb64)
- [c96e543798506578cf5bb5f070c2a5c405af8d7d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c96e543798506578cf5bb5f070c2a5c405af8d7d)

## Changes Promo Code Discount Condition to Improve Performance

Changes the `PromoCodes` discount condition to disqualify immediately if there are no promo codes, thereby improving the performance of the qualification.

### Issues

- [ECOMMERCE-5726](https://jira.tools.weblinc.com/browse/ECOMMERCE-5726)

### Pull Requests

- [3130](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3130/overview)

### Commits

- [a3e7f218fb47630ac4d8f456ae7f92db083ca34e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a3e7f218fb47630ac4d8f456ae7f92db083ca34e)
- [dbd4893149469b86ffbbb2d4eeffecd1424e53b2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dbd4893149469b86ffbbb2d4eeffecd1424e53b2)
- [b885082486237c60d557a2ecb78022e44801828a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b885082486237c60d557a2ecb78022e44801828a)

## Changes Seeds to Not Send Email

Disables sending email while seeding.

### Pull Requests

- [3388](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3388/overview)

### Commits

- [234894ccf1c3b038b5635fe1764173cdc3e6bcb0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/234894ccf1c3b038b5635fe1764173cdc3e6bcb0)
- [e3b523dc1f955c2353933e26591874779e272fcf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e3b523dc1f955c2353933e26591874779e272fcf)

## Changes Credit Card Tests

Replaces several unit tests with integration tests for credit card operations. Applies minor changes to the credit card interface to improve compatibility with Active Merchant and improve extensibility.

### Issues

- [ECOMMERCE-6000](https://jira.tools.weblinc.com/browse/ECOMMERCE-6000)

### Pull Requests

- [3348](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3348/overview)

### Commits

- [8d4a718c1d231558d026ce38e2654966daec47cd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8d4a718c1d231558d026ce38e2654966daec47cd)
- [be1374d370cb885cbf3368cbf7565b1fa3267ac6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/be1374d370cb885cbf3368cbf7565b1fa3267ac6)

## Adds Automatic Sidekiq Configuration

Adds programmatic configuration of Sidekiq to the platform, removing the need to configure Sidekiq from each application. Removes the Sidekiq configuration file from the app template, since it is no longer needed for new applications.

### Issues

- [ECOMMERCE-5709](https://jira.tools.weblinc.com/browse/ECOMMERCE-5709)

### Pull Requests

- [3168](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3168/overview)

### Commits

- [4c6e283fdc03933282ee4e36e140f9f1f4e486ef](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4c6e283fdc03933282ee4e36e140f9f1f4e486ef)
- [ab00ccfa1f37225b705cf05d5070a006658cb90c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ab00ccfa1f37225b705cf05d5070a006658cb90c)

## Changes Mongoid Configuration

Updates the Mongoid configuration to match recommendations from MongoDB and the actual infrastructure configuration used in Workarea Hosting environments.

### Commits

- [ffd04c5f13773ba229403f53ebee6cc2feaaa2b2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ffd04c5f13773ba229403f53ebee6cc2feaaa2b2)

## Adds Dragonfly Configuration to Ensure CDN; Adds Warning When Data Store is File System

Adds additional Dragonfly configuration to ensure a CDN is used in Production environments. Also adds a warning on boot of the application if the Dragonfly file store is set to file system when the Rails environment is not test or development.

### Issues

- [ECOMMERCE-5842](https://jira.tools.weblinc.com/browse/ECOMMERCE-5842)
- [ECOMMERCE-6072](https://jira.tools.weblinc.com/browse/ECOMMERCE-6072)

### Pull Requests

- [3206](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3206/overview)
- [3403](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3403/overview)

### Commits

- [c4f61a1e6910423d1fcaa0a71c69a3a4a3e04d1f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c4f61a1e6910423d1fcaa0a71c69a3a4a3e04d1f)
- [20b52128bf05248ed54de64393224a05cc1d27bd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/20b52128bf05248ed54de64393224a05cc1d27bd)
- [592f5d3f23b65e3e3887e01113a120299736b5d2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/592f5d3f23b65e3e3887e01113a120299736b5d2)
- [dc481207c6c360ab5ae52327117a146ecb47d1d5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dc481207c6c360ab5ae52327117a146ecb47d1d5)

## Adds Geocoder Config to Read API Key from Secrets

Adds geocoder configuration which reads from secrets, allowing an API to be included in the configuration.

### Issues

- [ECOMMERCE-5953](https://jira.tools.weblinc.com/browse/ECOMMERCE-5953)

### Pull Requests

- [3283](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3283/overview)

### Commits

- [3846146b6395ece6ee89cf6374af0eacf5d76c10](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3846146b6395ece6ee89cf6374af0eacf5d76c10)
- [94d2ada815931acd62cd1a4aac8717bd6f5d4d11](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/94d2ada815931acd62cd1a4aac8717bd6f5d4d11)

## Deprecates `running_in_gem?` for Test Cases; Adds Alternative Test Case Methods

Deprecates the test case method `running_in_gem?`. Adds two new test case methods, which are now preferred: `running_from_source?` and `running_in_dummy_app?`.

### Issues

- [ECOMMERCE-6007](https://jira.tools.weblinc.com/browse/ECOMMERCE-6007)

### Pull Requests

- [3349](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3349/overview)

### Commits

- [bce3a9a706f21e0e46f90194515a368df0fe729f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bce3a9a706f21e0e46f90194515a368df0fe729f)
- [d8674d43149bb5f6eed94813be63afdf4488805b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d8674d43149bb5f6eed94813be63afdf4488805b)

## Removes Running Generators from Plugins

Removes the ability to run generators from plugins because the implementation was causing tests to run with the incorrect Rails environment.

### Pull Requests

- [3276](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3276/overview)

### Commits

- [5005525b3a237f21bd95b58f2ea27a43fdaa37f6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5005525b3a237f21bd95b58f2ea27a43fdaa37f6)
- [0d1cb3ae33b6a9d71409cff9715704ec0f7e4fdd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0d1cb3ae33b6a9d71409cff9715704ec0f7e4fdd)

