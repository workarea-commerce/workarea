# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.0 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Rails 5.0 release notes for more info on each option.

# Enable per-form CSRF tokens. Previous versions had false.
Rails.application.config.action_controller.per_form_csrf_tokens = false

# Enable origin-checking CSRF mitigation. Previous versions had false.
Rails.application.config.action_controller.forgery_protection_origin_check = false

# Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
# In Rails 7+ this option accepts :zone/:utc/:local; the legacy false value is
# deprecated. Use the equivalent :utc value when running on Rails 7+.
if Rails.version >= "7.0"
  ActiveSupport.to_time_preserves_timezone = :utc
else
  ActiveSupport.to_time_preserves_timezone = false
end
