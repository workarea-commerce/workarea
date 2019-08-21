module Workarea
  module Elasticsearch
    module Document
      extend ActiveSupport::Concern

      included do
        Constants.register(:search_documents, self)

        class_attribute :type
        self.type = name.demodulize.underscore.to_sym

        attr_reader :model, :options
        delegate :id, to: :model
      end

      class << self
        def all
          Constants.find(:search_documents)
        end

        def current_index_prefix
          locale = I18n.locale.to_s.underscore
          "#{Workarea.config.site_name.optionize}_#{Rails.env}_#{locale}"
        end
      end

      class_methods do
        delegate :url, :scroll, :clear_scroll, to: :current_index

        def create_indexes!(force: false)
          I18n.for_each_locale { current_index.create!(force: force) }
        end

        def delete_indexes!
          I18n.for_each_locale { current_index.delete! }
        end

        def reset_indexes!
          I18n.for_each_locale do
            current_index.create!(force: true)
            current_index.wait_for_health
          end
        end

        def save(document, options = {})
          options = options.merge(type: type)
          I18n.for_each_locale { current_index.save(document, options) }
        end

        def bulk(documents, options = {})
          options = options.merge(type: type)
          I18n.for_each_locale { current_index.bulk(documents, options) }
        end

        def update(document, options = {})
          options = options.merge(type: type)
          I18n.for_each_locale { current_index.update(document, options) }
        end

        def delete(id, options = {})
          options = options.merge(type: type)
          I18n.for_each_locale { current_index.delete(id, options) }
        end

        def count(query = nil, options = {})
          current_index.count(query, options.merge(type: type))
        end

        def search(query, options = {})
          current_index.search(query, options.merge(type: type))
        end

        def current_index
          prefix = Elasticsearch::Document.current_index_prefix
          Index.new("#{prefix}_#{type}", mappings)
        end

        def mappings
          Workarea.config.elasticsearch_mappings[type]
        end
      end

      def initialize(model, options = {})
        @model = model
        @options = options
      end

      def as_document
        raise(
          NotImplementedError,
          "#{self.class} must implement #as_document to be saved"
        )
      end

      def as_bulk_document(action = :index)
        as_document.merge(Serializer.serialize(model)).merge(bulk_action: action)
      end

      def save(options = {})
        document = as_document.merge(Serializer.serialize(model))
        self.class.save(document, options)
      end

      def destroy(options = {})
        self.class.delete(id, options)
      end
    end
  end
end
