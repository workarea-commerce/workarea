module Workarea
  module Admin
    class CodeListViewModel < ApplicationViewModel
      def promo_codes
        @promo_codes ||= model.promo_codes.page(options[:page])
      end

      def unused_promo_codes
        @unused_promo_codes ||= model.promo_codes.unused.to_a
      end

      def used_count
        model.promo_codes.count - unused_promo_codes.count
      end

      def last_used_at
        @last_used_at ||= model.promo_codes.order(used_at: :desc).first.used_at
      end

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end
    end
  end
end
