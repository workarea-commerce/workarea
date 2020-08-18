module Workarea
  class ApplicationMailer < ActionMailer::Base
    include I18n::DefaultUrlOptions

    add_template_helper Workarea::PluginsHelper
    add_template_helper Workarea::ApplicationHelper
    add_template_helper Workarea::SchemaOrgHelper
    default from: -> (*) { Workarea.config.email_from }

    def default_url_options(options = {})
      # super isn't returning the configured options, so manually merge them in
      super
        .merge(Rails.application.config.action_mailer.default_url_options.to_h)
        .merge(host: Workarea.config.host)
    end
  end
end
