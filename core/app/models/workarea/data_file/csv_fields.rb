module Workarea
  module DataFile
    module CsvFields
      extend self

      def serialize_to(result, field:, value:)
        serialize_method = "serialize_#{field.type.name.parameterize.underscore}"

        if respond_to?(serialize_method)
          send(serialize_method, result, field.name, value)
        else
          result[field.name] = value
        end

        result
      end

      def deserialize_from(hash, field:, model:)
        deserialize_method = "deserialize_#{field.type.name.parameterize.underscore}"

        if respond_to?(deserialize_method)
          send(deserialize_method, hash, field.name, model)
        else
          hash[field.name]
        end
      end

      #
      # Type based serialization/deserialization
      #

      def serialize_array(result, name, value)
        result[name] = value&.join(',')
      end

      def deserialize_array(hash, name, model)
        hash[name].to_s.split(',')
      end

      def serialize_hash(result, name, value)
        value&.each do |key, value|
          result["#{name}_#{key}"] = value.is_a?(Array) ? value.join(',') : value
        end
      end

      def deserialize_hash(hash, name, model)
        current_value = model.send(name) || {}
        parsed = Hash[
          hash.select { |k, v| k =~ /^#{name}_.*/ }.map do |key, value|
            destination_key = key.gsub(/^#{name}_/, '')

            if value.present?
              [destination_key, value.include?(',') ? value.split(',') : value]
            end
          end.compact
        ]

        current_value.merge(parsed)
      end

      def serialize_country(result, name, value)
        result[name] = value.is_a?(Country) ? value.alpha2 : value
      end

      def serialize_activemerchant_billing_response(result, name, value)
        serialize_hash(result, name, flatten_hash(value.as_json))
      end

      def deserialize_time(hash, name, model)
        return unless parsable_timestamp?(hash[name])
        Time.parse(hash[name])
      end

      def deserialize_datetime(hash, name, model)
        return unless parsable_timestamp?(hash[name])
        DateTime.parse(hash[name])
      end

      def deserialize_date(hash, name, model)
        return unless parsable_timestamp?(hash[name])
        Date.parse(hash[name])
      end

      private

      # Mongoid uses ActiveSupport::TimeWithZone to mongoize strings into
      # times and dates. TimeWithZone uses Date.parse, just as this method does,
      # which can cause unpadded years to be returned. When parsing a CSV we
      # can make sure the year is above a sensible threshold of 1970 to ensure
      # marshalling data from mongoid models to elasticsearch does not cause
      # errors.
      #
      def parsable_timestamp?(value)
        return unless value.present?
        Date.parse(value, false).year >= 1970
      rescue ArgumentError
        false
      end

      def flatten_hash(hash, key = nil)
        return { key => hash } unless hash.is_a?(Hash)

        hash.inject({}) do |memo, (new_key, value)|
          memo.merge(
            flatten_hash(value, "#{key}_#{new_key}".gsub(/(^_|_$)/, ''))
          )
        end
      end
    end
  end
end
