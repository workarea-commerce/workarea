module Workarea
  module Admin
    module SettingsHelper
      def sanitize_config_value(value)
        return if value.blank?

        case value
        when String, Symbol
          tag.code html_escape(value.to_s), class: 'code code--block'
        when Hash, Array
          tag.pre data: { expandable: '' } do
            tag.code JSON.pretty_generate(value), class: 'code code--block'
          end
        end
      end
    end
  end
end
