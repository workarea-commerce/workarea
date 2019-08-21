module Workarea
  module Factories
    module Search
      Factories.add(self)

      def create_search_settings(overrides = {})
        Workarea::Search::Settings.create!(overrides)
      end

      def create_search_customization(overrides = {})
        attributes = factory_defaults(:search_customization).merge(overrides)
        Workarea::Search::Customization.create!(attributes)
      end

      def create_product_search(options = {})
        result = Workarea::Search::ProductSearch.new

        allow(result).to receive_messages(
          create_product_browse_search_options(options)
        )

        result
      end

      def create_category_browse_search(options = {})
        result = Workarea::Search::CategoryBrowse.new

        allow(result).to receive_messages(
          create_product_browse_search_options(options)
        )

        result
      end

      def create_admin_search(options = {})
        result = Workarea::Search::AdminSearch.new
        options.reverse_merge!(factory_defaults(:admin_search))

        options[:results] = PagedArray.from(
          options[:results],
          options[:page],
          options[:per_page],
          options[:total]
        )

        allow(result).to receive_messages(options)

        result
      end

      def elasticsearch_response
        file = "#{File.dirname(__FILE__)}/../elasticsearch_response.json"
        JSON.parse(IO.read(file))
      end

      def create_product_browse_search_options(options = {})
        options.reverse_merge!(factory_defaults(:product_browse_search_options))

        options[:results] = options[:products].map do |product|
          { catalog_id: product.id, model: product, option: nil }
        end

        options.except(:products)
      end

      def update_search_settings(overrides = {})
        attributes = factory_defaults(:search_settings).merge(overrides)
        Workarea::Search::Settings.current.update_attributes!(attributes)
      end
    end
  end
end
