module Workarea
  class Payment
    class Operation
      attr_reader :transactions, :errors

      def initialize(transactions, options = {})
        @transactions = transactions
        @options = options
        @errors = []
      end

      def success?
        errors.empty?
      end

      def complete!
        begin
          complete_each_transaction!
        rescue Exception => e
          rollback!
          raise e
        ensure
          add_transaction_errors
        end
      end

      def rollback!
        transactions
          .select(&:success?)
          .reject(&:canceled?)
          .each { |t| t.cancel!(@options) }
      end

      private

      def complete_each_transaction!
        transactions.each do |transaction|
          transaction.complete!(@options)
          rollback! and break if transaction.failure?
        end
      end

      def add_transaction_errors
        transactions.select(&:failure?).each do |transaction|
          errors << transaction.message
        end
      end
    end
  end
end
