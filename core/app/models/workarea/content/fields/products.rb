module Workarea
  class Content
    module Fields
      class Products < Field
        def typecast(value)
          Array(value).map(&:to_s)
        end
      end
    end
  end
end
