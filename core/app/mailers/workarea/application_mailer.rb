module Workarea
  class ApplicationMailer < ActionMailer::Base
    include I18n::DefaultUrlOptions

    # Workarea historically used ActionMailer::Base.add_template_helper, which
    # no longer exists in Rails 6.1+. Provide a shim so existing mailers keep
    # working.
    def self.add_template_helper(mod)
      helper(mod)
    end unless respond_to?(:add_template_helper)

    # Rails 6.1+ uses `helper` for mailer views; older Workarea used
    # ActionMailer::Base.add_template_helper.
    if respond_to?(:add_template_helper)
      add_template_helper Workarea::PluginsHelper
      add_template_helper Workarea::ApplicationHelper
      add_template_helper Workarea::SchemaOrgHelper
    else
      helper Workarea::PluginsHelper
      helper Workarea::ApplicationHelper
      helper Workarea::SchemaOrgHelper
    end
    default from: -> (*) { Workarea.config.email_from }

    def default_url_options(options = {})
      # super isn't returning the configured options, so manually merge them in
      super
        .merge(Rails.application.config.action_mailer.default_url_options.to_h)
        .merge(host: Workarea.config.host)
    end
  end
end
