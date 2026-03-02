# frozen_string_literal: true
module Workarea
  class ApplicationMailer < ActionMailer::Base
    include I18n::DefaultUrlOptions

    # Rails 6.1 removed ActionMailer::Base.add_template_helper in favour of
    # the standard `helper` class method. Provide a shim here so that existing
    # client mailers that still call +add_template_helper+ keep working on both
    # Rails 6.1 and Rails 7 without requiring client code changes.
    #
    # Because ApplicationMailer is the base class for all Workarea mailers,
    # subclasses inherit this class method automatically.
    def self.add_template_helper(mod)
      helper(mod)
    end unless respond_to?(:add_template_helper)

    # Register Workarea's view helpers using the standard Rails 6.1+ API.
    # The add_template_helper shim above ensures client code that calls
    # add_template_helper on their own subclasses continues to work.
    helper Workarea::PluginsHelper
    helper Workarea::ApplicationHelper
    helper Workarea::SchemaOrgHelper

    default from: -> (*) { Workarea.config.email_from }

    # Build URL options for mailer links.
    #
    # Rails 6.1 and 7 do not automatically merge
    # +config.action_mailer.default_url_options+ when this method is overridden,
    # so we pull them in explicitly. +Workarea.config.host+ takes precedence for
    # the +host+ key so that all Workarea mailer links point to the configured
    # storefront host.
    def default_url_options(options = {})
      configured = Rails.application.config.action_mailer.default_url_options.to_h
      super.reverse_merge(configured).merge(host: Workarea.config.host)
    end
  end
end
