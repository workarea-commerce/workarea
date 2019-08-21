module Workarea
  module DataFile
    class Csv < Format
      def import!
        index = 2 # start at 1 and skip headers
        failed_new_record_ids = []
        options = Workarea.config.csv_import_options.merge(headers: true)

        CSV.foreach(file.path, options) do |row|
          attrs = row.to_h
          next if attrs.values.all?(&:blank?)

          id = attrs['_id'].presence || attrs['id']
          model_class = model_class_for(attrs)
          root = id.present? ? model_class.find_or_initialize_by(id: id) : model_class.new

          assign_attributes(root, attrs)
          assign_embedded_attributes(root, attrs)

          if root.save || failed_new_record_ids.exclude?(id)
            log(index, root)
          else
            operation.total += 1 # ensure line numbers remain consistent
          end

          failed_new_record_ids << id if root.new_record?
          index += 1
        end
      end

      def export!
        headers = {}
        models.each { |m| serialize_root(m).each { |r| headers.merge!(r) } }
        headers = headers.keys

        CSV.open(tempfile.path, 'w') do |csv|
          csv << headers

          models.each do |model|
            serialize_root(model).each do |row|
              csv << headers.map { |h| row[h] }
            end
          end
        end
      end

      private

      def assign_attributes(model, attrs)
        model.fields.each do |name, metadata|
          value = CsvFields.deserialize_from(attrs, field: metadata, model: model)
          model.send("#{name}=", value) if value.present?
        end

        model.updated_at ||= Time.current
        model.created_at ||= Time.current

        assign_dragonfly_attributes(model, attrs)
        assign_password(model, attrs['password'])
      end

      def assign_dragonfly_attributes(model, attrs)
        return unless model.class.is_a?(Dragonfly::Model)

        model.dragonfly_attachments.each do |name, attachment|
          attachment_attrs = attrs.select { |a| a.starts_with?("#{name}_") }

          attachment_attrs.each do |attribute, value|
            model.send("#{attribute}=", value) if value.present?
          end

          # Ensure Dragonfly saves the attachment, since if this is embedded, we
          # aren't calling #save directly on the model in some cases.
          attachment.save!
        end
      end

      def assign_embedded_attributes(root, attrs)
        root.embedded_relations.each do |name, metadata|
          unnamespaced_attrs = Hash[
            attrs.map do |key, value|
              if key.starts_with?(name)
                [key.gsub(/#{name}_/, ''), value]
              end
            end.compact
          ]

          if unnamespaced_attrs.values.any?(&:present?)
            if metadata.many?
              id = attrs["#{name}_id"]
              instance = if id.present?
                root.send(name).find_or_initialize_by(id: id)
              else
                root.send(name).build
              end

              assign_attributes(instance, unnamespaced_attrs)
            else
              instance = root.send(name) || root.send("build_#{name}")
              assign_attributes(instance, unnamespaced_attrs)
            end
          end
        end
      end

      def serialize_model(model)
        without_ignored = model.fields.except(*Workarea.config.data_file_ignored_fields)

        without_ignored.reduce({}) do |memo, (name, metadata)|
          value = if metadata.localized?
            model.localized_fields[name].send(:lookup, model.attributes[name] || {})
          else
            model.send(name)
          end

          CsvFields.serialize_to(memo, field: metadata, value: value)
          memo
        end
      end

      def serialize_root(model)
        result = [serialize_model(model)]

        model.class.embedded_relations.values.each do |metadata|
          if metadata.many?
            append_many_embedded(result, model, metadata)
          else
            append_one_embedded(result, model, metadata)
          end
        end

        result
      end

      def append_many_embedded(result, model, metadata)
        model.send(metadata.name).each_with_index do |embedded, i|
          hash = serialize_embedded(embedded, metadata)
          hash['_id'] = model.id

          if i.zero?
            result.first.merge!(hash)
          else
            result << hash
          end
        end
      end

      def append_one_embedded(result, model, metadata)
        hash = serialize_embedded(model.send(metadata.name), metadata)
        result.first.merge!(hash)
      end

      def serialize_embedded(embedded, metadata)
        return {} if embedded.blank?

        hash = serialize_model(embedded)
        hash.transform_keys { |k| "#{metadata.name}_#{k}".squeeze('_') }
      end
    end
  end
end
