# This extends session expiration longer than Rails defaults, to keep
# carts around longer. Many retailers have requested this.

# NOTE: this must be set in seconds
env_expire_after = ENV['WORKAREA_SESSION_STORE_EXPIRE_AFTER']

Rails.application.config.session_store(
  :cookie_store,
  key: "_#{Rails.application.class.name.deconstantize.underscore}_session",
  expire_after: env_expire_after.present? ? env_expire_after.to_i : 30.minutes
)
