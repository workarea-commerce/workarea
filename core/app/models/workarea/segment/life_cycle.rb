module Workarea
  class Segment
    module LifeCycle
      extend ActiveSupport::Concern

      included do
        field :_id, type: String, default: -> { self.class.instance_id }
        cattr_accessor :default_rules
      end

      class_methods do
        def model_name
          Segment.model_name
        end

        def instance
          first || create!(rules: default_rules)
        end

        def instance_id
          name.demodulize.underscore.to_sym
        end
      end

      def self.create!
        [
          FirstTimeVisitor,
          ReturningVisitor,
          FirstTimeCustomer,
          ReturningCustomer,
          LoyalCustomer
        ].each(&:instance)
      end

      def name
        self.class.name.demodulize.underscore.titleize
      end

      def destroy
        false
      end
    end
  end
end
