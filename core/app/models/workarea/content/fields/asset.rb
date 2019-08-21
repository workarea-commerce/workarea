module Workarea
  class Content
    module Fields
      class Asset < Field
        def file_types
          Array(options[:file_types]).presence || []
        end

        def typecast(value)
          value.to_s
        end
      end
    end
  end
end
