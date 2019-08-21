module Workarea
  module Admin::PagesHelper
    def page_templates
      @page_templates ||= [
        [t('workarea.admin.content_pages.templates.generic'), 'generic']
      ]
    end
  end
end
