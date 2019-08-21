module Workarea
  class Content
    module Fields
      class Integer < Field
        def typecast(value)
          value.to_i
        end
      end
    end
  end
end
