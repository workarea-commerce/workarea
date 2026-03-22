# ActionView Template Handler Rails 7.1 Compatibility

**Issue:** WA-VERIFY-113 / workarea-commerce/workarea#1137  
**Branch:** `wa-verify-113-template-handler-compat`  
**Date:** 2026-03-21  
**Conclusion:** No Workarea-side template handler breakage found for Rails 7.1.

## Summary

This audit checked Workarea for:

- custom `ActionView` template handler registrations
- nonstandard view rendering hooks that could depend on handler internals
- existing template engines used by the app (`haml`, `jbuilder`, `builder`)

Result: **Workarea does not register custom ActionView template handlers**, and the
repo's view-layer extensions stay at the normal partial/render API level. No
Workarea code changes are required for Rails 7.1 template handler compatibility.

## What was searched

Repo-wide targeted searches covered `core/`, `admin/`, and `storefront/` for:

- `ActionView::Template.register_template_handler`
- `ActionView::Template::Handlers`
- `register_renderer`
- `render_to_body`
- `lookup_context`
- `view_paths`
- `render inline:`
- direct `JbuilderTemplate` extensions
- template engine usage (`.haml`, `.jbuilder`, `.builder`)

## Findings

### 1) No custom template handler registrations in Workarea

Searches found **no** uses of:

- `ActionView::Template.register_template_handler`
- `ActionView::Template::Handlers`
- custom handler classes/modules

That means Workarea is not depending on deprecated handler registration APIs or
single-arity handler implementations in its own code.

### 2) HAML remains the primary template engine

Current engine usage in the repo:

- `793` `.haml` templates
- `13` `.jbuilder` templates
- `1` `.builder` template

Workarea already documents HAML compatibility in
`docs/research/haml-rails7-compat.md`.
That research confirms `haml 5.2.2` exposes a Rails-compatible two-argument
handler entrypoint:

```ruby
Haml::Plugin.call(template, source = nil)
```

That is the relevant Rails 7+ contract for template handlers.

### 3) Jbuilder usage extends rendering behavior, not handler registration

Workarea has two Jbuilder extensions:

- `core/lib/workarea/ext/jbuilder/jbuilder_append_partials.rb`
- `core/lib/workarea/ext/jbuilder/jbuilder_cache.rb`

These modify `JbuilderTemplate` behavior via `prepend` / decoration, but they do
**not** register a custom template handler or bypass normal ActionView rendering.
They continue to operate through standard `@context.render(...)` and cache hooks.

### 4) Nonstandard rendering hooks are limited and Rails 7.1-safe on inspection

The only notable view lookup customizations found were standard `lookup_context`
usage, such as:

- checking for optional partials before rendering
- verifying style guide template existence

These calls use normal ActionView lookup APIs and do not depend on template
handler internals.

## Rails 7.1 appraisal status

The repo contains `gemfiles/rails_7_1.gemfile`, pinned to `rails 7.1.5.1`, but
it currently includes this note:

> As of 2026-03-17, this appraisal does not resolve due to mongoid (< 8.0.7)
> constraining activemodel to < 7.1, while Rails 7.1 pins activemodel 7.1.x.

So a live Rails 7.1 smoke test for this area is presently blocked by dependency
resolution unrelated to ActionView template handlers.

## Compatibility result

**PASS** — No Workarea-owned template handler compatibility gap was found for
Rails 7.1.

### Verified safe

- No custom ActionView template handler registrations in Workarea
- No Workarea-owned single-arity template handlers
- HAML compatibility already documented and aligned with Rails 7 handler arity
- Jbuilder customizations stay within public rendering/template APIs
- `lookup_context` usage is standard and not handler-internal

### Known limitation

- Rails 7.1 runtime smoke-testing is currently blocked by the existing
  `mongoid` / `activemodel` appraisal resolution issue, so this verification is
  based on code audit plus existing HAML compatibility research

## Client impact

None expected.
