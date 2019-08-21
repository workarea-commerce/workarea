module Workarea
  class Payment
    class MissingReference < RuntimeError; end

    module OperationImplementation
      extend ActiveSupport::Concern

      included do
        attr_reader :tender, :transaction, :options
        delegate :profile, to: :tender
      end

      def initialize(tender, transaction, options = {})
        @tender = tender
        @transaction = transaction
        @options = options
      end

      def validate_reference!
        raise MissingReference if transaction.reference.blank?
      end
    end
  end
end
