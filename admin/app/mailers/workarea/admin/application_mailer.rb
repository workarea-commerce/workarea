module Workarea
  module Admin
    class ApplicationMailer < Workarea::ApplicationMailer
      layout 'workarea/admin/email'

      before_action :set_host
      before_action :set_colors

      private

      # TODO: v4 remove
      def set_host
        @host = Workarea.config.host
      end

      # TODO: v4 remove
      def set_colors
        @email_width = '600'
        @background_color = '#ffffff'
        @layout_separator_color = '#E1E4E6'
        @layout_background_color = '#eeeff0'
        @heading_color = '#333333'
        @heading_background_color = '#eeeff0'
        @text_color = '#000000'
        @link_color = '#011eff'
        @table_background_color = '#a9a9a8'
        @positive_change_text_color = '#6dde95'
        @negative_change_text_color = '#fa775d'
      end
    end
  end
end
