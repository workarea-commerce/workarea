module Workarea
  class Content
    class Field
      attr_reader :name, :options

      def initialize(name, options = {})
        @name = name
        @options = options
      end

      def slug
        name.to_s.systemize.to_sym
      end

      def type
        self.class.name.demodulize.systemize.to_sym
      end

      def default
        if options[:default].respond_to?(:call)
          options[:default].call
        else
          options[:default]
        end
      end

      def partial
        options[:partial].presence ||
          self.class.name.demodulize.underscore.systemize
      end

      def required?
        !!options[:required]
      end

      def typecast(value)
        value.to_s
      end

      def note
        options[:note]
      end

      def tooltip
        options[:tooltip]
      end
    end
  end
end
