module Workarea
  module Storefront
    module SearchContent
      include DisplayContent

      def results_content
        content_blocks_for('results')
      end

      def no_results_content
        content_blocks_for('no_results')
      end

      def content_lookup
        'search'
      end
    end
  end
end
