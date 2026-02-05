# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# Ruby 2.6 + Rails 6 can crash early if Logger isn't loaded yet.
require 'logger'

$:.unshift File.expand_path('../../../../lib', __FILE__)
