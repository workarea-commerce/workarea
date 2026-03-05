# WA-VERIFY-003 — Audit `config.load_defaults` behavioral flags for Rails 7.0 / 7.1

Closes #772

## Current state in Workarea

Workarea does **not** set `config.load_defaults` in a top-level `core/config/application.rb` (Workarea is an engine). The only `config.load_defaults` usage in this repo is in the test dummy applications:

- `admin/test/dummy/config/application.rb` → `config.load_defaults 6.1`
- `core/test/dummy/config/application.rb` → `config.load_defaults 6.1`
- `storefront/test/dummy/config/application.rb` → `config.load_defaults 6.1`

So, unless overridden elsewhere, Rails 7.0 / 7.1 *versioned defaults* are **not enabled** by default in Workarea.

### Explicit overrides related to Rails 7

Workarea *does* explicitly set cookie serialization in core:

- `core/config/initializers/22_session_store.rb` sets:
  - `Rails.application.config.action_dispatch.cookies_serializer = :hybrid`
  - Rationale: zero-downtime migration from Marshal → JSON (see #725).

The dummy apps also include a `cookies_serializer.rb` initializer setting `:json`.

---

## Rails 7.0 defaults — status in Workarea

Reference: Rails 7.0 `Rails::Application::Configuration#load_defaults("7.0")`.

| Rails 7.0 default | Workarea status | Notes |
| --- | --- | --- |
| `action_dispatch.default_headers = { ... Referrer-Policy: strict-origin-when-cross-origin }` | **Safe (not enabled)** | Remains on 6.1 defaults in dummies. |
| `action_dispatch.return_only_request_media_type_on_content_type = false` | **Safe (not enabled)** | No Workarea override found. |
| `action_dispatch.cookies_serializer = :json` | **Compensated** | Workarea sets `:hybrid` in `22_session_store.rb` to support rolling upgrades. Dummies set `:json`. |
| `action_view.button_to_generates_button_tag = true` | **Safe (not enabled)** | No override found. |
| `action_view.apply_stylesheet_media_default = false` | **Safe (not enabled)** | No override found. |
| `active_support.hash_digest_class = SHA256` | **Safe (not enabled)** | No override found. |
| `active_support.key_generator_hash_digest_class = SHA256` | **Safe (not enabled)** | No override found. |
| `active_support.remove_deprecated_time_with_zone_name = true` | **Safe (not enabled)** | No override found. |
| `active_support.cache_format_version = 7.0` | **Safe (not enabled)** | No override found. Important when upgrading cache stores. |
| `active_support.use_rfc4122_namespaced_uuids = true` | **Safe (not enabled)** | No override found. |
| `active_support.executor_around_test_case = true` | **Safe (not enabled)** | No override found. |
| `active_support.isolation_level = :thread` | **Safe (not enabled)** | No override found. |
| `active_support.disable_to_s_conversion = true` | **Safe (not enabled)** | No override found. |
| `action_mailer.smtp_timeout = 5` | **Safe (not enabled)** | No override found. |
| `active_storage.variant_processor = :vips` | **Safe (not enabled)** | No override found. |
| `active_storage.multiple_file_field_include_hidden = true` | **Safe (not enabled)** | No override found. |
| `active_storage.video_preview_arguments = ...` | **Safe (not enabled)** | No override found. |
| `active_record.verify_foreign_keys_for_fixtures = true` | **Safe (not enabled)** | No override found. |
| `active_record.partial_inserts = false` | **Safe (not enabled)** | No override found. |
| `active_record.automatic_scope_inversing = true` | **Safe (not enabled)** | No override found. |
| `action_controller.raise_on_open_redirects = true` | **Safe (not enabled)** | No override found. |
| `action_controller.wrap_parameters_by_default = true` | **Safe (not enabled)** | No override found. |

---

## Rails 7.1 defaults — status in Workarea

Reference: Rails 7.1 `Rails::Application::Configuration#load_defaults("7.1")`.

| Rails 7.1 default | Workarea status | Notes |
| --- | --- | --- |
| `add_autoload_paths_to_load_path = false` | **Safe (not enabled)** | Important for `$LOAD_PATH` assumptions; no override found. |
| `precompile_filter_parameters = true` | **Safe (not enabled)** | No override found. |
| `dom_testing_default_html_version = :html5 (when Nokogiri::HTML5 available)` | **Safe (not enabled)** | No override found. |
| `log_file_size = 100MB (local envs)` | **Safe (not enabled)** | No override found. |
| `action_dispatch.debug_exception_log_level = :error` | **Safe (not enabled)** | No override found. |
| `active_job.use_big_decimal_serializer = true` | **Safe (not enabled)** | Potentially relevant for job args containing `BigDecimal`/`Money` via ActiveJob; no override found. |
| `active_support.cache_format_version = 7.1` | **Safe (not enabled)** | No override found. |
| `active_support.message_serializer = :json_allow_marshal` | **Safe (not enabled)** | No override found. |
| `active_support.use_message_serializer_for_metadata = true` | **Safe (not enabled)** | No override found. |
| `active_support.raise_on_invalid_cache_expiration_time = true` | **Safe (not enabled)** | No override found. |
| `action_controller.allow_deprecated_parameters_hash_equality = false` | **Safe (not enabled)** | No override found. |
| `active_record.*` (commit callbacks ordering, query log tags, encryption digests, marshalling format, etc.) | **Safe (not enabled)** | No override found. These will need a targeted review when Workarea moves dummies (and downstream apps) to `load_defaults 7.1`. |
| `action_view/action_text sanitizer_vendor = best_supported_vendor` | **Safe (not enabled)** | No override found. |

---

## Conclusion

- **Current `load_defaults` in repo:** `6.1` (in all dummy apps).
- **Rails 7.0 / 7.1 defaults are therefore not active** unless Workarea explicitly opts into them.
- The only notable explicit Rails-7-related behavior today is **cookie serialization**, where Workarea intentionally uses `:hybrid` to support rolling upgrades.

No follow-up issues were created from this audit because no new-risk defaults are currently enabled in Workarea itself.
