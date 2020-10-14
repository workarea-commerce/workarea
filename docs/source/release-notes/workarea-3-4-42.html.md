---
title: Workarea 3.4.42
excerpt: Patch release notes for Workarea 3.4.42.
---

# Workarea 3.4.42

Patch release notes for Workarea 3.4.42

## Try to clarify how to use search synonyms

There has been repeated confusion around why/how to use synonyms, so this is an
attempt to clarify.

### Pull Requests

- [529](https://github.com/workarea-commerce/workarea/pull/529)

## Patch RefererParser for Android URLs

Android App URLs have a special `android-app://` scheme that is rejected
by the currently released version of the `referer-parser` gem. The code
in this patch already exists in the master branch of the gem, but this
has not yet been released, and if Android users browse the storefront it
can generate an error when collecting referer information. In case a
referer cannot be parsed, Workarea also rescues the error so that
checkout requests are not blocked.

### Pull Requests

- [533](https://github.com/workarea-commerce/workarea/pull/533)

## Prevent clearing out navigable when saving taxons

The `WORKAREA.newNavigationTaxons` module was looking in the wrong place
for the selected navigable item, therefore the `selected` var would
always return `undefined`, causing the `navigable_id` param to be
blank every time. Fix this by querying for the correct DOM node (the
`[data-new-navigation-taxon]` element) and pulling the selected ID from
its data.

### Pull Requests

- [539](https://github.com/workarea-commerce/workarea/pull/539)
