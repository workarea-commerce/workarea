module Workarea
  class ApplicationMailer < ActionMailer::Base
    include I18n::DefaultUrlOptions

    add_template_helper Workarea::PluginsHelper
    add_template_helper Workarea::ApplicationHelper
    default from: -> (*) { Workarea.config.email_from }

    def default_url_options(options = {})
      super.merge(host: Workarea.config.host)
    end
  end
end
