# HAML Rails 7 Compatibility Research

**Issue:** [workarea-commerce/workarea#711](https://github.com/workarea-commerce/workarea/issues/711)  
**Branch:** `wa-rails7-010-haml`  
**Date:** 2026-03-02  
**Conclusion: HAML 5.2 is Rails 7 compatible. No upgrade required.**

---

## Summary

Workarea uses HAML 5.2.2 with 751 `.haml` templates across core, admin, and storefront engines.
The investigation confirms that HAML 5.2.2 works with Rails 7 without modification.
The gemspec constraint `~> 5.2` is correct and no template changes are needed.

---

## Key Finding: Template Handler Arity

Rails 7.0 removed deprecated support for single-arity template handlers.
Template handlers must accept two arguments: `call(template, source)`.

HAML 5.2.2's `Haml::Plugin` correctly implements two-arity:

```ruby
# haml-5.2.2/lib/haml/plugin.rb
def self.call(template, source = nil)
  source ||= template.source
  new.compile(template, source)
end
```

The `source = nil` default maintains backward compatibility while satisfying Rails 7's
two-parameter requirement. **This is the critical check — and HAML 5.2.2 passes.**

---

## Workarea Audit: Template Handler Registration

A repo-wide search for `ActionView::Template.register_template_handler` found **no calls in
Workarea itself** (other than this research note). This means Workarea does **not** ship any
custom ActionView template handlers.

HAML integration is provided by the `haml` gem's Railtie, which registers the handler using
a two-arity `call(template, source)` implementation (see below).

## HAML 5.2.2 Rails Integration Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Two-arity template handler | ✅ PASS | `call(template, source = nil)` |
| `ActionView::OutputBuffer` usage | ✅ PASS | Referenced correctly in plugin preamble |
| `ActionView::Template.register_template_handler` | ✅ PASS | Standard registration, unchanged in Rails 7 |
| Rails 6.1 `annotate_rendered_view_with_filenames` | ✅ PASS | Added in haml 5.2.2 (released Jul 2021) |
| Ruby 2.7 / 3.x compatibility | ✅ PASS | HAML 5.2.2 supports both |

---

## HAML 6 Breaking Changes (Why We're Deferring)

HAML 6.0 (released September 2022) replaced the implementation with Hamlit and removed
numerous helpers. Client impact would be HIGH — any client with custom HAML templates
using removed helpers would need to migrate.

**Helpers removed in HAML 6** (may exist in client custom templates):
- `haml_concat`, `haml_tag`, `haml_tag_if`, `haml_indent`, `html_attrs`
- `html_escape` (Haml's version — ActionView's `html_escape` is unaffected)
- `init_haml_helpers`, `is_haml?`, `block_is_haml?`
- `list_of`, `non_haml`, `tab_down`, `tab_up`, `with_tabs`
- `flatten`, `haml_io` (in `:ruby` filter)

**HAML 6 behavior changes:**
- `escape_html` defaults to `true` (was `false` in HAML 4, already `true` in Workarea)
- Script lines (`-`) no longer support capturing; only `=` yields nested blocks
- Non-data/aria attributes no longer support nested Hash → hyphenated expansion
- `:erb` filter no longer executes in template context (fixed in 6.0.10)

### Workarea Template Using Removed Helper

One Workarea template uses `haml_tag_if` (removed in HAML 6):

**`admin/app/views/workarea/admin/shared/_active_field.html.haml`** (line 6):
```haml
- haml_tag_if model.segments.present?, :strong do
  = t('workarea.admin.shared.active_field.by_segment', ...)
```

If HAML 6 migration is ever pursued, this should be replaced with:
```haml
- if model.segments.present?
  %strong= t('workarea.admin.shared.active_field.by_segment', ...)
- else
  = t('workarea.admin.shared.active_field.by_segment', ...)
```

Or use a helper method with `content_tag`.

---

## Decision

**Keep `haml ~> 5.2`. Defer HAML 6.**

Rationale:
1. HAML 5.2.2 is fully Rails 7 compatible
2. HAML 6 migration requires template changes and has HIGH client impact
3. Workarea has 751 HAML templates — full audit needed before any HAML 6 work
4. One known `haml_tag_if` usage in admin views would need migration
5. Clients with custom themes are much more likely to use removed HAML helpers

---

## If HAML 6 Migration Is Pursued (Future Work)

1. Run `bundle exec haml-lint` across all three engines to identify template issues
2. Search codebase for removed helpers: `haml_tag_if`, `haml_tag`, `haml_concat`, etc.
3. Update `_active_field.html.haml` (see above)
4. Audit `escape_html` behavior — already `true` in Workarea, so this should be fine
5. Test admin and storefront system tests with `haml ~> 6.0`
6. Publish migration guide for clients with custom HAML templates
7. Consider haml-lint CI gate before upgrading

**Estimated effort:** 2-4 days for Workarea core. Client migration effort is additional.
