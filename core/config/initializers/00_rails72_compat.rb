# Rails 7.2 removed config.autoloader since Zeitwerk is now the only supported
# autoloader. The rails-decorators gem (workarea-commerce fork) checks
# Rails.configuration.autoloader == :zeitwerk in an after_initialize hook.
# Provide a shim so the check passes on Rails 7.2+ where the method is absent.
if Rails::VERSION::MAJOR > 7 || (Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR >= 2)
  unless Rails.application.config.respond_to?(:autoloader)
    Rails.application.config.define_singleton_method(:autoloader) { :zeitwerk }
  end

  # ActiveRecord::SecureToken#has_secure_token (used in Workarea::UrlToken) calls
  # ActiveRecord.generate_secure_token_on as a default argument in Rails 7.2+.
  # This attribute is defined in active_record.rb but not in active_record/secure_token.rb.
  # When ActiveRecord is loaded partially, define the attribute as a shim to avoid
  # triggering a full require 'active_record' (which would cause AR test setup conflicts).
  if defined?(ActiveRecord) && !ActiveRecord.respond_to?(:generate_secure_token_on)
    ActiveRecord.singleton_class.attr_accessor :generate_secure_token_on
    ActiveRecord.generate_secure_token_on = :create
  end
end
