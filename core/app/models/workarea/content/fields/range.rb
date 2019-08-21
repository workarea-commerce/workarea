module Workarea
  class Content
    module Fields
      class Range < Field
        def min
          options[:min].to_f
        end

        def max
          options[:max].to_f
        end

        def step
          options[:step].to_f
        end

        def typecast(value)
          value.to_f
        end
      end
    end
  end
end
