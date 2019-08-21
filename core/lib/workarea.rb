module Workarea
  class << self
    delegate :add_append, to: :'Workarea::Plugin'

    %w(stylesheets javascripts partials).each do |type|
      delegate :"append_#{type}", :"#{type}_appends", to: :'Workarea::Plugin'
    end
  end

  # Colors used for styling executable output
  COLOR_CODES = {
    red: 31,
    green: 32,
    yellow: 33
  }

  # Shortcut for configuration, passes config
  # to the block given.
  #
  # @example Set an option
  #   Workarea.configure do |config|
  #     config.some_value = true
  #   end
  #
  def self.configure
    yield(config)
  end

  # A shortcut to the Rails' application config
  # relevant to Workarea.
  #
  # @return [ActiveSupport::Configurable::Configuration]
  #
  def self.config
    @custom_config.presence || Configuration.config
  end

  def self.with_config
    @custom_config ||= config.deep_dup
    yield(@custom_config)
  ensure
    @custom_config = nil
  end

  # A [Redis] client for general application use.
  #
  # @return [Redis]
  #
  def self.redis
    @redis ||= Redis.new(Configuration::Redis.persistent.to_h)
  end

  # The [Elasticsearch::Client] for general application use.
  #
  # @return [Elasticsearch::Client]
  #
  def self.elasticsearch
    @elasticsearch ||= ::Elasticsearch::Client.new(
      Configuration::Elasticsearch.find
    )
  end

  # The [Fog::Storage::AWS] instance for internal application S3 use.
  #
  # @return [Fog::Storage::AWS]
  #
  def self.s3
    @s3 ||= begin
      options = { region: Configuration::S3.region.to_s }

      if Configuration::S3.use_iam_profile?
        options.merge!(use_iam_profile: true)
      else
        options.merge!(
          aws_access_key_id: Configuration::S3.access_key_id.to_s,
          aws_secret_access_key: Configuration::S3.secret_access_key.to_s
        )
      end

      Fog.mock! unless Configuration::S3.configured?
      Fog::AWS::Storage.new(options)
    end
  end
end

require 'workarea/core'
require 'workarea/admin'
require 'workarea/storefront'
