module Workarea
  class Content
    module Fields
      class Options < Field
        def values
          Array(options[:values])
        end
      end
    end
  end
end
