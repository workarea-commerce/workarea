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
          first || create!(name: instance_name, rules: default_rules)
        end

        def instance_id
          name.demodulize.underscore.to_sym
        end

        def instance_name
          name.demodulize.underscore.titleize
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

      def destroy
        false
      end
    end
  end
end
