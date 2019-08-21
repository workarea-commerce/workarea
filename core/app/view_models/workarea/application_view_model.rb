module Workarea
  class ApplicationViewModel
    attr_reader :model, :options

    def self.wrap(input, options = {})
      if input.is_a?(Enumerable)
        input.map { |i| new(i, options) }
      else
        new(input, options)
      end
    end

    def initialize(model = nil, options = {})
      @model = model
      @options = if options.respond_to?(:to_unsafe_h)
                   options.to_unsafe_h.with_indifferent_access
                 else
                   options.to_h.with_indifferent_access
                 end
    end

    def method_missing(method, *args, &block)
      if model && model.respond_to?(method)
        # Define a method so the next call is faster
        self.class.send(:define_method, method) do |*args, &blok|
          model.send(method, *args, &blok)
        end

        send(method, *args, &block)
      else
        super
      end

    rescue NoMethodError => no_method_error
      super if no_method_error.name == method
      raise no_method_error
    end

    def respond_to_missing?(method_name, include_private = false)
      super || (model && model.respond_to?(method_name))
    end

    def to_param
      model.to_param
    end

    def to_model
      model
    end

    def present?
      model.present?
    end

    def blank?
      model.blank?
    end

    def nil?
      model.nil?
    end

    def ==(other)
      (other.class == self.class && other.id == id) || other == model
    end

    def translate(key, options = {})
      I18n.translate(key, options)
    end
    alias :t :translate
  end
end
