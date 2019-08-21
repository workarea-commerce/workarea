---
title: Workarea 3.2.5
excerpt:  Use the /g option on the replacement regular expression so that all spaces are accounted for in a dasherized String with JavaScript. 
---

# Workarea 3.2.5

## Replace all spaces with dashes in WORKAREA.string.dasherize()

Use the `/g` option on the replacement regular expression so that all spaces are accounted for in a dasherized String with JavaScript.

### Issues

- [ECOMMERCE-5886](https://jira.tools.weblinc.com/browse/ECOMMERCE-5886)

### Pull Requests

- 3235

### Commits

- [e16e34a129b634e12043223f01ec585e9afd806a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e16e34a129b634e12043223f01ec585e9afd806a)

## Fix CSS selectors in email template layout

Update syntax so email layout CSS applies to the correct elements.

### Issues

- [ECOMMERCE-5828](https://jira.tools.weblinc.com/browse/ECOMMERCE-5828)

### Pull Requests

- [3193](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3193)

### Commits

- [8a6134d3aa637a38bdde7171431b081655fc18dc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8a6134d3aa637a38bdde7171431b081655fc18dc)

## Fix view test setup logic

View (helper) tests were failing because they didn't include the same setup code as integration and system tests, resulting in a pollution of the global state. Add logic for disabling Sidekiq callbacks and ActionMailer emails in helper tests.

### Issues

- [ECOMMERCE-5867](https://jira.tools.weblinc.com/browse/ECOMMERCE-5867)

### Pull Requests

- [3213](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3213)

### Commits

- [436291026906279c9700e327058d42b5d6f4ace3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/436291026906279c9700e327058d42b5d6f4ace3)

## Remove unused focus-ring CSS cruft

Since we no longer use a custom focus-ring for all focusable elements in v2.x, this reset code and extra CSS for maintaining that architecture got left behind. In v3.x, we only offer a focus-ring to custom UIs.

### Issues

- [ECOMMERCE-5872](https://jira.tools.weblinc.com/browse/ECOMMERCE-5872)

### Pull Requests

- [3221](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3221)

- [55db0f2f53610dd6ec9e38ab53ddf46d23f908f5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/55db0f2f53610dd6ec9e38ab53ddf46d23f908f5)

## Scroll browser to the bottom of the page in pagination system tests

Changing the default grid widths on category browse/search pages can potentially cause a failure stemming from paginated content that needs to be clicked, but isn't visible in the viewport at that time. This resolves those potential failures by scrolling the headless browser to the bottom of the page so it can see the elements that need to be clicked.

### Issues

- 

### Pull Requests

- [3228](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3228)

### Commits

- [40947914a5664a077f434f399849e582a5ea5c36](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/40947914a5664a077f434f399849e582a5ea5c36)

## Prevent duplicate shipping charge

We added a `data-disable-with` attribute to checkout buttons in v3.1 and above, but never backported the fix to v3.0, where the problem was still occurring. This should backport that fix and resolve a potential race condition where shipping charges can double on a checkout.

### Issues

- [ECOMMERCE-1712](https://jira.tools.weblinc.com/browse/ECOMMERCE-1712)

### Pull Requests

- [3196](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3196)

### Commits

- [0e75aac1ccc1ba97568f8ecf3c9b3b22ad052640](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0e75aac1ccc1ba97568f8ecf3c9b3b22ad052640)

## New Address dialog opens in the middle of viewport on iOS Safari

For older iOS Safari users, the "New Address" dialog will sometimes open in the middle of the page and cause the top half of the form to get cut off. Apply a `max-height` of `90vh` in order to center the dialog in the viewport as it opens. We also needed to add the **!important** flag because jQuery UI Dialog applies an inline style that overrides our customization.

### Issues

- [ECOMMERCE-5191](https://jira.tools.weblinc.com/browse/ECOMMERCE-5191)

### Pull Requests

- [3184](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3184)
- [3225](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3225)

### Commits

- [8e3c5d44547cf17c0e0ad4a60b0fe4faf5f6aa17](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8e3c5d44547cf17c0e0ad4a60b0fe4faf5f6aa17)
- [d65e9aff336f98e62f7e95422685403467670cc2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d65e9aff336f98e62f7e95422685403467670cc2)

## Fix style guide links for components that don't have their own page

There are certain components that do not have their own dedicated page for styles. Make sure these can be navigated to by way of adding a potential custom anchor to the `#link_to_style_guide` helper, allowing components to define the anchor for a link on the page they live on.

### Issues

- [ECOMMERCE-5687](https://jira.tools.weblinc.com/browse/ECOMMERCE-5687)

### Pull Requests

- [3181](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3181)
- [3216](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3216)

### Commits

- [519649ef43dfd29c35085b0957f7f87e749425ba](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/519649ef43dfd29c35085b0957f7f87e749425ba)
- [aa970a63052b9bf7824c3ee7b2fbb5080f3c74b9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/aa970a63052b9bf7824c3ee7b2fbb5080f3c74b9)

## Output category name instead of ID in product rules activity feed

When creating product rules that key off of a `Catalog::Category`, ensure that the category name is being found and rendered rather than its BSON Object ID. This improves the legibility of the category activity feed.

### Issues

- [ECOMMERCE-5688](https://jira.tools.weblinc.com/browse/ECOMMERCE-5688)

### Pull Requests

- [3183](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3183)

### Commits

- [d75ae97de697aeabdc90ee754b45bc342d6d32d2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d75ae97de697aeabdc90ee754b45bc342d6d32d2)

## Fix 500 error when editing help articles

While testing help article editing, we discovered that the activity feed partials for help articles had the wrong route helper method referenced. The correct helper method is now being used, and thus a 500 error has been prevented from view in the admin when help articles are created or saved.

### Issues

- [ECOMMERCE-5846](https://jira.tools.weblinc.com/browse/ECOMMERCE-5846)

### Pull Requests

- [3215](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3215)

### Commits

- [9af2896690e89534c651259a75d56a59ff73b45a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9af2896690e89534c651259a75d56a59ff73b45a)

## Reject promise when src is undefined on WORKAREA.image

Discovered in [ONETHEME-111](https://jira.tools.weblinc.com/browse/ONETHEME-111), this prevents a promise never getting resolved if a `src` URL is undefined.

### Issues

- [ECOMMERCE-5874](https://jira.tools.weblinc.com/browse/ECOMMERCE-5874)

### Pull Requests

- [3223](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3223)

### Commits

- [c84f962d0303416fca11ba27589b58a12d802426](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ic84f962d0303416fca11ba27589b58a12d802426)
- [50a881e02f3a577aec6c007cabbe512af9eb4349](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/50a881e02f3a577aec6c007cabbe512af9eb4349)

