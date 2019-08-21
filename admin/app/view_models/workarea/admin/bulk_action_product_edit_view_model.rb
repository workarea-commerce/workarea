module Workarea
  module Admin
    class BulkActionProductEditViewModel < ApplicationViewModel
      def template_options
        ProductViewModel.new.templates
      end

      def selected?(hash, field)
        model.send(hash).key?(field)
      end

      def selected_true?(hash, field)
        !selected?(hash, field) || send(hash)[field] == 'true'
      end

      def selected_false?(hash, field)
        send(hash)[field] == 'false'
      end

      def pricing_prices
        pricing.fetch('prices', []).first || {}
      end
    end
  end
end
