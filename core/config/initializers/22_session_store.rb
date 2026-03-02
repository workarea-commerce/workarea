# This extends session expiration longer than Rails defaults, to keep
# carts around longer. Many retailers have requested this.

# NOTE: this must be set in seconds
env_expire_after = ENV['WORKAREA_SESSION_STORE_EXPIRE_AFTER']

Rails.application.config.session_store(
  :cookie_store,
  key: "_#{Rails.application.class.name.deconstantize.underscore}_session",
  expire_after: env_expire_after.present? ? env_expire_after.to_i : 30.minutes
)

# Rails 7 changed the default cookie serializer from Marshal to JSON.
# Using :hybrid allows reading existing Marshal-serialized cookies while
# writing all new cookies as JSON. This enables a zero-downtime migration:
# existing user sessions (carts, logins) survive the upgrade, and all new
# sessions are written in the JSON format going forward.
#
# ROLLOUT STRATEGY:
# Phase 1 (deploy with Rails 7): Set serializer to :hybrid (below).
#         Existing Marshal sessions are still readable; new sessions use JSON.
# Phase 2 (after all user sessions have naturally expired, typically 30min-24h):
#         Optionally switch to :json for a clean JSON-only configuration.
#         This is safe once no Marshal-encoded sessions remain in the wild.
#
# See: https://github.com/workarea-commerce/workarea/issues/725
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
