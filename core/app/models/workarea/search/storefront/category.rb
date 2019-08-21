module Workarea
  module Search
    class Storefront
      class Category < Storefront
        def content
          { name: model.name }
        end

        def slug
          model.slug
        end

        def active
          { now: model.active? }
        end
      end
    end
  end
end
