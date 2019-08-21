module Workarea
  module Admin
    module Discounts
      module Categories
        def categories
          @categories ||= category_ids.map do |id|
            Catalog::Category.where(id: id).first
          end.compact
        end
      end
    end
  end
end
