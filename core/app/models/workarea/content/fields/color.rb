module Workarea
  class Content
    module Fields
      class Color < Field
        def presets
          options[:presets]
        end
      end
    end
  end
end
