module Workarea
  module Configuration
    # This gets around a configuration problem where we want field definition
    # to depend on configuration, but fields are defined before configuration.
    #
    # TODO:
    #  When we upgrade Elasticsearch we will require reindexing anyways, so we
    #  can use that opportunity to provide a Mongo migration script that will
    #  make these hacks unnecessary. The data in Elasticsearch will get
    #  reindexed and corrected.
    #
    module LocalizedFields
      extend self

      def load
        unless Workarea.config.localized_active_fields
          ::Mongoid.models.each do |klass|
            if klass < Releasable
              klass.localized_fields.delete('active')
              klass.field(:active, type: Boolean, default: true, localize: false)
              klass.index(active: 1)
            end
          end
        end

        unless Workarea.config.localized_image_options
          Catalog::ProductImage.localized_fields.delete('option')
          Catalog::ProductImage.field(:option, type: String, localize: false)
        end
      end
    end
  end
end
