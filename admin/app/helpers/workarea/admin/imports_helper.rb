module Workarea
  module Admin
    module ImportsHelper
      def render_validations_for(klass)
        results = ''.html_safe
        embedded_validators = klass.validators.select do |valiator|
          valiator.is_a?(Mongoid::Validatable::AssociatedValidator)
        end
        field_validators = klass.validators - embedded_validators

        field_validators.each { |v| results << render_field_validation_for(v) }
        embedded_validators.each { |v| results << render_embedded_validation_for(klass, v).to_s }

        results.present? ? content_tag(:ul, results) : ''
      end

      def render_field_validation_for(validator)
        name = validator.class.name.demodulize.gsub(/Validator/, '')
        attr_content = content_tag(:code, validator.attributes.to_sentence)

        result = t(
          'workarea.admin.imports_helper.field_validation_html',
          type: name.downcase,
          field: attr_content
        ).html_safe

        result << " #{validator.options}" if validator.options.present?

        content_tag(:li, result)
      end

      def render_embedded_validation_for(klass, validator)
        name = validator.attributes.first.to_s
        relation = klass.relations[name]

        return unless relation.embedded?

        content = render_validations_for(relation.klass)
        name_content = content_tag(:code, name)
        content_tag(:li, "#{name_content}: #{content}".html_safe) if content.present?
      end

      def render_import_format_notes_for(format)
        render("workarea/admin/data_file_imports/#{format.slug}_notes")
      rescue ActionView::MissingTemplate
        # It's ok if there aren't any notes to render
      end
    end
  end
end
