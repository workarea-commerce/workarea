module Workarea
  module Admin
    module Discounts
      module Products
        def products
          @products ||= product_ids.map do |id|
            Catalog::Product.where(id: id).first
          end.compact
        end
      end
    end
  end
end
