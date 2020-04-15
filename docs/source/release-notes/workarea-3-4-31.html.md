---
title: Workarea 3.4.31
excerpt: Patch release notes for Workarea 3.4.31.
---

# Workarea 3.4.31

Patch release notes for Workarea 3.4.31

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
