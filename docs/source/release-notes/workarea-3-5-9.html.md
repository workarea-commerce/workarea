---
title: Workarea 3.5.9
excerpt: Patch release notes for Workarea 3.5.9.
---

# Workarea 3.5.9

Patch release notes for Workarea 3.5.9.

## Don't allow more than one valid password reset token per-user

There's no reason to keep extra password reset tokens around.

### Pull Requests

- [406](https://github.com/workarea-commerce/workarea/pull/406)

## Fix dev env autoloading problem with Categorization

Autoloading in development would sometimes break, use a fully qualified constant
path to resolve correctly.

### Pull Requests

- [408](https://github.com/workarea-commerce/workarea/pull/408)

## Add missing append points to option-based product templates

This append point was only in the generic template, but is useful for plugins.

### Commits

- [7298bae](https://github.com/workarea-commerce/workarea/commit/7298bae444e751a33ca410ca4628118fad1800c1)

## Fix locales not in cache varies

To ensure all cache varies correctly by locales, it's important that locale be
part of the Rack env's `workarea.cache_varies`. To do this, we need to move
setting the locale into middleware (where the varies is set).

### Commits

- [409](https://github.com/workarea-commerce/workarea/pull/409)

## Fix locale not passed through in return redirect when not in URL

If a return_to parameter is generated without the locale, and a request
includes a parameter to switch locale, the locale is dropped causing the
request to revert to the default locale.

The original observed bug is switching locale in content editing and
seeing the request to save always redirect to the default locale.

### Commits

- [409](https://github.com/workarea-commerce/workarea/pull/409)

## Don't include locale in hidden fields for switching locales

This can result in duplicate and conflicting locale params in the query
string, which can cause the incorrect locale to be selected.

### Commits

- [409](https://github.com/workarea-commerce/workarea/pull/409)

## Tighten up segment geolocation matching rule

This was playing a little fast and loose with matching, causing CA to
match for California and Canada, IL to match for Illinois and Israel, etc.

Matching only based on IDs chosen from the UI fixes these problems.

### Commits

- [411](https://github.com/workarea-commerce/workarea/pull/411)

## Fix duplicate key errors in metrics synchronization

It's important this be kept in sync as real-time as possible, so we need
to avoid the Sidekiq retry delay where possible.

### Commits

- [415](https://github.com/workarea-commerce/workarea/pull/415)

## Fix Mongoid not returning defaults for localized fields

If a locale is missing from the translations hash, Mongoid returns nil instead
of the default specified on the field. That causes all kinds of errors.

### Pull Requests

- [414](https://github.com/workarea-commerce/workarea/pull/414)

## Fix index serialization not happening per-locale

Previously, indexing was using the same document per-locale. This was masked by
Mongoid loading data from the cached document to look correct in most browse
scenarios. This fixes it to serialize per-locale so each locale has a separate
representation of the document.

### Pull Requests

- [414](https://github.com/workarea-commerce/workarea/pull/414)

## Fix hardcoded JS path for admin jump to dropdown

This prevents locale from being included in the path to load results.

### Commits

- [06ee3dc](https://github.com/workarea-commerce/workarea/commit/06ee3dcfc5f74155b72a0a51a553ad0ef30d5e35)
