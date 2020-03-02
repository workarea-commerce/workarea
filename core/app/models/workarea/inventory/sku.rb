module Workarea
  module Inventory
    class Sku
      class InvalidPolicy < RuntimeError; end
      include ApplicationDocument

      policies = Workarea.config.inventory_policies.map(&:demodulize).map(&:underscore)
      default_inventory_policy = policies.first

      field :_id, type: String
      field :policy, type: String,  default: default_inventory_policy
      field :available, type: Integer, default: 0
      field :backordered, type: Integer, default: 0
      field :backordered_until, type: Time
      field :purchased, type: Integer, default: 0
      field :reserve, type: Integer, default: 0

      # @!attribute sellable
      #   Experimental field to persist #available_to_sell. Currently only
      #   used for reporting on low inventory. It is not recommended at this
      #   time to use sellable for any critical business logic and is subject
      #   to removal.
      #
      #   @return [Integer] The inventory that can be sold, based on policy.
      #
      field :sellable, type: Integer, default: 0

      validates :policy, presence: true, inclusion: { in: policies }
      validates :available, presence: true
      validates :backordered, presence: true

      delegate :available_to_sell, :displayable?, :purchase, to: :policy_object

      before_validation :set_sellable

      index({ sellable: 1 })

      scope :with_low_inventory, -> do
        where(:sellable.lt => Workarea.config.low_inventory_threshold)
      end

      Workarea.config.inventory_policies.each do |class_name|
        define_method "#{class_name.demodulize.underscore}?" do
          policy == class_name.demodulize.underscore
        end
      end

      def self.sorts
        [Sort.modified, Sort.newest, Sort.available, Sort.sku, Sort.purchased]
      end

      # This is for compatibility with the admin, all models must implement this
      #
      # @return [String]
      #
      def name
        I18n.t('workarea.inventory_sku.name', id: id)
      end

      # Determines if a sku is available from backorder
      #
      # @return [Boolean] Sku available via backorder
      #
      def backordered?
        available == 0 && allow_backorder? && backordered > 0
      end

      # Whether the sku is purchasable based on policy and stock
      #
      # @param quantity [Integer]
      # @return [Boolean]
      #
      def purchasable?(quantity = 1)
        quantity <= available_to_sell
      end

      # Returns the difference betweent the requested quantity
      # and the available quantity. Used for determining how
      # to auto-limit the quantity you can have in a cart.
      #
      # @param quantity [Integer]
      # @return [Integer]
      #
      def insufficiency_for(quantity)
        if available_to_sell >= quantity
          0
        else
          quantity - available_to_sell
        end
      end

      # Atomically decrement units for this SKU. Used when purchasing from
      # a {Inventory::Policies::Base} class. Will raise an {InsufficientError}
      # if there is not enough inventory on the SKU to capture.
      #
      # If there is a failure, this means the in memory {Sku} model is out of
      # sync with the database, so this method will call #reload (but not try
      # to capture again, since different arguments will be required).
      #
      # The returned value is a Hash with keys for success, number of available
      # captured and number of backordered captured.
      #
      # @param desired_available [Integer]
      # @param desired_backordered [Integer]
      #
      # @return [Hash]
      #
      def capture(desired_available, desired_backordered = 0)
        capture = Capture.new(self, desired_available, desired_backordered)
        capture.perform

        reload unless capture.result[:success]
        capture.result
      end

      # Atomically free inventory units that were previously captured
      # in a purchase. Used to rollback an inventory capture that
      # succeeded after one fails in a transaction. Also reduces the
      # purchase count to reflect the rollback.
      #
      # @param release_available [Integer]
      # @param release_backordered [Integer]
      #
      # @return [Boolean]
      #
      def release(release_available, release_backordered = 0)
        total = release_available + release_backordered
        return true if total.zero?

        inc(
          available: release_available,
          backordered: release_backordered,
          sellable: total,
          purchased: 0 - total
        )
      end

      private

      def policy_object
        @policy_object ||= policy_class.new(self)
      end

      def policy_class
        "Workarea::Inventory::Policies::#{policy.camelize}".constantize
      rescue NameError
        raise(
          InvalidPolicy,
          "Workarea::Inventory::Policies::#{policy.camelize} must be a policy class"
        )
      end

      def set_sellable
        self.sellable = available_to_sell
      end
    end
  end
end
