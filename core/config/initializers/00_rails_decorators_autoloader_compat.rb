# frozen_string_literal: true

# rails-decorators checks `Rails.configuration.autoloader` to ensure Zeitwerk.
# Rails 7.0 removed the `autoloader` config accessor because Zeitwerk is the only
# supported code loader, which causes rails-decorators to raise a NoMethodError
# during boot.
#
# Polyfill the accessor in Rails 7+ so the gem can keep enforcing Zeitwerk while
# remaining compatible across Rails 6.1/7.0/7.1.
if Rails.configuration && !Rails.configuration.respond_to?(:autoloader)
  Rails.configuration.singleton_class.attr_accessor :autoloader
  Rails.configuration.autoloader = :zeitwerk
end
