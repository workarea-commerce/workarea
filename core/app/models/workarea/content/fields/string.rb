module Workarea
  class Content
    module Fields
      class String < Field
        def multi_line?
          !!options[:multi_line]
        end
      end
    end
  end
end
