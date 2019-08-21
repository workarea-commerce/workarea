module Workarea
  module Configuration
    # This gets around a configuration problem where we want field definition
    # to depend on configuration, but fields are defined before configuration.
    # So this redefines the active field if we're doing localized active fields
    # (which will become the default in v3.4).
    #
    # TODO remove this in v4.0
    #
    module LocalizedActiveFields
      extend self

      def load
        return if Workarea.config.localized_active_fields

        ::Mongoid.models.each do |klass|
          if klass < Releasable
            klass.localized_fields.delete('active')
            klass.field(:active, type: Boolean, default: true, localize: false)
            klass.index(active: 1)
          end
        end
      end
    end
  end
end
