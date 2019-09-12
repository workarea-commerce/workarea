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
        @locals ||= model
          .data
          .merge(hidden_breakpoints: model.hidden_breakpoints, view_model: self)
          .merge(asset_alt_text) do |_, block_alt, asset_alt|
            block_alt.presence || asset_alt
          end
      end

      def find_asset(id)
        return Content::Asset.image_placeholder if id.blank?
        return assets[id.to_s] if assets[id.to_s].present?

        assets[id.to_s] = Content::Asset.find(id)
      rescue Mongoid::Errors::DocumentNotFound
        assets[id.to_s] = Content::Asset.image_placeholder
      end

      def assets
        @assets ||= begin
          asset_ids = model
            .type
            .fields
            .select { |field, _memo| field.type == :asset }
            .map { |field| model.data[field.slug] }
            .reject(&:blank?)
            .map(&:to_s)

          assets = Content::Asset.in(id: asset_ids)

          asset_ids.each_with_object({}) do |id, memo|
            memo[id] = assets.detect { |a| a.id.to_s == id } ||
                       Content::Asset.image_placeholder
          end
        end
      end

      def asset_alt_text
        @asset_alt_texts ||= model.type
          .fields
          .select { |f| f.options[:alt_field].present? }
          .each_with_object({}) do |field, memo|
            key = field.options[:alt_field].systemize.to_sym
            memo[key] = find_asset(model.data[field.slug])&.alt_text
          end
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
            duplicate = Content::Block.instantiate(model.as_document)
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
