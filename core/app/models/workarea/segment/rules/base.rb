module Workarea
  class Segment
    module Rules
      class Base
        include ApplicationDocument

        embedded_in :segment, class_name: 'Workarea::Segment', inverse_of: :rules
        delegate :slug, to: :class

        def self.slug
          name.demodulize.underscore.to_sym
        end
      end
    end
  end
end
