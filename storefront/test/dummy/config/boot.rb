# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# Ruby 2.6+ + Rails 6.1 can hit `uninitialized constant ...::Logger` if stdlib
# Logger isn't loaded before ActiveSupport initializes.
require 'logger'

$:.unshift File.expand_path('../../../../lib', __FILE__)
