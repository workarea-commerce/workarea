module Workarea
  module Search
    # This class exists to provide plugins and host applications a single
    # point of modification for changing the logic around indexing products
    # See workarea-browse_option or workarea-package_products for example.
    #
    class ProductEntries
      include Enumerable
      delegate :any?, :empty?, :each, :size, to: :entries

      def initialize(products)
        @products = Array.wrap(products)
      end

      def entries
        @entries ||= live_entries + release_entries
      end

      def live_entries
        @live_entries ||= @products.flat_map do |product|
          index_entries_for(product.without_release)
        end
      end

      def release_entries
        @release_entries ||= @products.flat_map do |product|
          ProductReleases.new(product).releases.map do |release|
            index_entries_for(product.in_release(release))
          end
        end
      end

      def index_entries_for(product)
        Search::Storefront::Product.new(product)
      end
    end
  end
end
