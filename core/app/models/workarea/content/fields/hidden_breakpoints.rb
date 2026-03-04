# frozen_string_literal: true

module Workarea
  class Content
    module Fields
      class HiddenBreakpoints < Field
        def typecast(value)
          Array(value)
        end
      end
    end
  end
end
