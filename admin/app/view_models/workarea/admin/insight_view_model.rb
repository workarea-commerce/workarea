module Workarea
  module Admin
    class InsightViewModel < ApplicationViewModel
      def results
        @results ||= model.results.map do |result|
          OpenStruct.new(
            Workarea.config.insights_model_classes.reduce(result) do |memo, klass|
              memo.merge(add_models(klass.constantize, memo))
            end
          )
        end
      end

      def add_models(klass, insight_result)
        result = insight_result.deep_dup
        key_name = klass.name.demodulize.underscore
        id_key_name = "#{key_name}_id"

        ids = model.results.flat_map { |r| r.select { |k| k =~ /#{id_key_name}$/ }.values }
        models = klass.any_in(id: ids).to_lookup_hash

        insight_result.each do |key, value|
          if key =~ /#{id_key_name}$/
            new_key = key.gsub(/#{id_key_name}$/, key_name)
            model = models[value]

            if model.present?
              result.merge!(new_key => ApplicationController.wrap_in_view_model(model))
            end
          end
        end

        result
      end
    end
  end
end
