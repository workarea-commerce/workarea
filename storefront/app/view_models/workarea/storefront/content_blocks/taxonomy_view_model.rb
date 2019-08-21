module Workarea
  module Storefront
    module ContentBlocks
      class TaxonomyViewModel < ContentBlockViewModel
        include TaxonLookup

        def left_image?
          data[:image].present? && data[:image_position].casecmp('left').zero?
        end

        def right_image?
          data[:image].present? && data[:image_position].casecmp('right').zero?
        end
      end
    end
  end
end
