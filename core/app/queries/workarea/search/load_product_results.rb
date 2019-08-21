module Workarea
  module Search
    module LoadProductResults
      def load_model_from(document)
        source = document['_source']
        product = Elasticsearch::Serializer.deserialize(source)

        {
          id: source['id'],
          catalog_id: product.id, # TODO v4 retire this, use result[:model].id instead
          model: product,
          option: source['keywords']['option'],
          pricing: load_pricing_from(source),
          inventory: load_inventory_from(source),
          raw: document
        }
      end

      def load_pricing_from(source)
        pricing = (source['cache']['pricing'] || []).map do |serialized|
          Elasticsearch::Serializer.deserialize(serialized)
        end

        Workarea::Pricing::Collection.new(pricing.map(&:id), pricing)
      end

      def load_inventory_from(source)
        inventory = (source['cache']['inventory'] || []).map do |serialized|
          Elasticsearch::Serializer.deserialize(serialized)
        end

        Workarea::Inventory::Collection.new(inventory.map(&:id), inventory)
      end
    end
  end
end
