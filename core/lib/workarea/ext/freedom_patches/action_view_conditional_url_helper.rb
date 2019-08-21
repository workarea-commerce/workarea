module ActionView
  module Helpers
    module ConditionalUrlHelper
      def link_to_if_with_block(condition, link, html_options = {}, &block)
        if condition
          link_to link, html_options, &block
        else
          capture &block
        end
      end

      def link_to_unless_with_block(condition, link, html_options = {}, &block)
        unless condition
          link_to link, html_options, &block
        else
          capture &block
        end
      end
    end
  end

  ActionView::Helpers.include(Helpers::ConditionalUrlHelper)
end
