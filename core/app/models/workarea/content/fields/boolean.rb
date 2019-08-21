module Workarea
  class Content
    module Fields
      class Boolean < Field
        def typecast(value)
          value.to_s != 'false'
        end
      end
    end
  end
end
