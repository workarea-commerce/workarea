module Workarea
  module Admin
    module SettingsHelper
      def sanitize_config_value(value)
        return if value.blank? && value.to_s != 'false'

        case value
        when ActiveSupport::Duration
          amount, unit = value.parts.first.reverse
          duration = pluralize(amount, unit.to_s.singularize)
          tag.code html_escape(duration), class: 'code code--block'
        when SwappableList
          tag.pre data: { expandable: '' } do
            tag.code JSON.pretty_generate(value.to_a), class: 'code code--block'
          end
        when Hash, Array
          tag.pre data: { expandable: '' } do
            tag.code JSON.pretty_generate(value), class: 'code code--block'
          end
        else
          tag.code html_escape(value.to_s), class: 'code code--block'
        end
      end
    end
  end
end
