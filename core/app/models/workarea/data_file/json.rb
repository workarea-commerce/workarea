module Workarea
  module DataFile
    class Json < Format
      def import!
        index = 1
        file_stream = File.open(file.path, 'r')
        streamer = ::Json::Streamer.parser(file_io: file_stream)

        streamer.get(nesting_level: 1) do |attrs|
          instance = find_updated_model_for(attrs)
          assign_password(instance, attrs['password'])
          instance.save

          log(index, instance)
          index += 1
        end
      end

      def export!
        tempfile.write("[\n")

        models.each_with_index do |model, i|
          tempfile.write(JSON.pretty_generate(serialize_model(model)))
          tempfile.write(',') unless i == models.count - 1
          tempfile.write("\n")
        end

        tempfile.write("]\n")
      end

      def serialize_model(model)
        clean_ignored_fields(
          model.as_json.reverse_merge(
            _type: model.class.name
          )
        )
      end

      private

      def find_updated_model_for(attrs)
        id = attrs['_id'].presence || attrs['id'].presence || attrs[:_id].presence || attrs[:id]
        model_class = model_class_for(attrs)
        attributes = attrs.except('_type', :_type)

        if id.present?
          result = model_class.find_or_initialize_by(id: id)
          result.attributes = attributes_without_updated_at(attributes)
          result
        else
          model_class.new(attributes)
        end
      end

      def attributes_without_updated_at(attrs)
        return attrs unless attrs.respond_to?(:each_with_object)

        attrs.each_with_object({}) do |(key, value), attributes|
          next if key.to_s == 'updated_at'

          attributes[key] = case value
                            when Hash
                              attributes_without_updated_at(value)
                            when Array
                              value.map do |item|
                                attributes_without_updated_at(item)
                              end
                            else
                              value
                            end
        end
      end
    end
  end
end
