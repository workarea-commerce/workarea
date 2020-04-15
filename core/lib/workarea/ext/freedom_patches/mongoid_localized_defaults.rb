module Mongoid
  module Fields
    module LocalizedDefaults
      def create_accessors(name, meth, options = {})
        super

        if options[:localize]
          field = fields[name]

          define_method meth do |*args|
            result = super(*args)
            return result unless result.nil?

            default_name = field.send(:default_name)
            return send(default_name) if respond_to?(default_name)

            field.default_val
          end
        end
      end
    end

    ClassMethods.prepend(LocalizedDefaults)
  end
end
