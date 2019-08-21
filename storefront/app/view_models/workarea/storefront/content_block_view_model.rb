module Workarea
  module Storefront
    class ContentBlockViewModel < ApplicationViewModel
      def self.wrap(model, options = {})
        return model.map { |m| wrap(m, options) } if model.is_a?(Enumerable)
        model.type.view_model.constantize.new(model, options)
      rescue NameError
        new(model, options)
      end

      def partial
        "workarea/storefront/content_blocks/#{model.type.slug}"
      end

      def locals
        @locals ||= model.data.merge(
          hidden_breakpoints: model.hidden_breakpoints,
          view_model: self
        )
      end

      # This ensures memoization happens
      def find_asset(id)
        @assets ||= {}
        return @assets[id.to_s] if @assets[id.to_s].present?

        @assets[id.to_s] = Content::Asset.find(id) rescue
                           Content::Asset.image_placeholder
      end

      def series
        @series ||= options[:base].try(:series) || generate_series
      end

      private

      def generate_series
        model.type.series.reduce([]) do |results, fieldset|
          fields = fieldset.fields.map(&:slug)
          data = model.data.slice(*fields)

          if data.present? && data.values.any?(&:present?)
            duplicate = Content::Block.new(model.attributes)
            duplicate.data = data
                              .map { |k, v| [k.gsub(/_\d+/, ''), v] }
                              .to_h
                              .merge(non_series_fields_data)

            results << self.class.new(duplicate, options.merge(base: self))
          end

          results
        end
      end

      def non_series_fields_data
        series_fields = model.type.series.map(&:fields).reduce(&:+).map(&:slug)
        model.data.except(*series_fields)
      end
    end
  end
end
