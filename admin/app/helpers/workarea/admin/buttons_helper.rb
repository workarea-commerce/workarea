module Workarea
  module Admin
    module ButtonsHelper
      def button_tag(*args)
        options = args.reverse.detect { |a| a.is_a?(Hash) }
        options ||= args.append({}).last

        options[:data] ||= {}
        options[:data][:disable] = true unless options[:data].key?(:disable)
        super(*args)
      end
    end
  end
end
