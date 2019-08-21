module Workarea
  # TODO: for v4, remove @order, as this can be/is used with other classes.
  class StatusCalculator
    module Status
      extend ActiveSupport::Concern

      included do
        attr_reader :order, :model
      end

      def initialize(model)
        @order = @model = model
      end

      def in_status?
        raise(NotImplementedError, 'a Status must implement the #in_status?')
      end
    end

    attr_reader :calculators, :order, :model

    def initialize(calculators, model)
      @calculators = calculators
      @order = @model = model
    end

    def result
      status = calculators.detect { |c| c.new(@model).in_status? } ||
                calculators.first

      status.name.demodulize.underscore.to_sym
    end

    def results
      calculators
        .select { |c| c.new(@model).in_status? }
        .map { |status| status.name.demodulize.underscore.to_sym }
    end
  end
end
