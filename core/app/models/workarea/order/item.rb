module Workarea
  class Order::Item
    include ApplicationDocument

    field :product_id, type: String
    field :sku, type: String
    field :quantity, type: Integer, default: 1
    field :category_ids, type: Array, default: []
    field :customizations, type: Hash, default: {}
    field :free_gift, type: Boolean, default: false
    field :discountable, type: Boolean, default: true
    field :product_attributes, type: Hash, default: {}
    field :total_value, type: Money, default: 0
    field :total_price, type: Money, default: 0
    field :via, type: String
    field :fulfillment, type: String, default: -> { Workarea.config.fulfillment_policies.first.demodulize.underscore }

    scope :by_newest, -> { desc(:created_at) }

    embedded_in :order, inverse_of: :items
    embeds_many :price_adjustments,
      class_name: 'Workarea::PriceAdjustment',
      extend: PriceAdjustmentExtension

    validates :product_id, presence: true
    validates :sku, presence: true
    validates :quantity, presence: true,
      numericality: {
        greater_than_or_equal_to: 1,
        only_integer: true
      }

    # To allow for custom policies defining their own methods here
    Workarea.config.fulfillment_policies.each do |class_name|
      define_method "#{class_name.demodulize.underscore}?" do
        fulfilled_by?(class_name.demodulize.underscore)
      end
    end

    # These methods exist for findability
    def shipping?
      fulfilled_by?('shipping')
    end

    def download?
      fulfilled_by?('download')
    end

    # Whether this order has any items that need to be fulfilled by a particular
    # fulfillment policy.
    #
    # @param [Array<String,Symbol>]
    # @return [Boolean]
    #
    def fulfilled_by?(*types)
      types.map(&:to_s).include?(fulfillment)
    end

    # Whether this item is a digital (not-shipped) type of item.
    #
    # @return [Boolean]
    #
    def digital?
      !!product_attributes['digital']
    end
    Workarea.deprecation.deprecate_methods(
      Order::Item,
      digital?: :fulfilled_by?
    )

    # Adds a price adjustment to the item. Does not persist.
    #
    # @return [self]
    #
    def adjust_pricing(options = {})
      price_adjustments.build(options)
    end

    # Whether the item is in any of the category ids
    # passed. Used in discount qualification.
    #
    # @param ids [Array]
    # @return [Boolean]
    #
    def matches_categories?(*ids)
      match_ids = Array(ids).flatten.map(&:to_s)
      (category_ids.map(&:to_s) & match_ids).any?
    end

    # Whether the item is for any of the product ids
    # passed. Used in discount qualification.
    #
    # @param ids [Array]
    # @return [Boolean]
    #
    def matches_products?(*ids)
      match_ids = Array(ids).flatten.map(&:to_s)
      product_id.to_s.in?(match_ids)
    end

    # The base price per-unit for this item.
    #
    # @return [Money]
    #
    def original_unit_price
      return 0.to_m if price_adjustments.blank?
      price_adjustments.first.unit.to_m
    end

    # The unit price of the item including all currently attached price
    # adjustments.
    #
    # @return [Money]
    #
    def current_unit_price
      return 0.to_m if price_adjustments.blank?
      price_adjustments.adjusting('item').sum.to_m / quantity
    end

    # Whether this item is on sale (as of the last time the
    # order was priced).
    #
    # @return [Boolean]
    #
    def on_sale?
      return false if price_adjustments.blank?
      !!price_adjustments.first.data['on_sale']
    end

    # Customizations to the item, beyond what the
    # variant options were. Examples would include
    # engraving, monogramming, etc. This should be
    # a sanitized hash that has passed through
    # the {Catalog::Customizations} system.
    #
    # @return [Hash]
    #
    def customizations
      super || {}
    end

    # Whether this item has any customizations.
    #
    # @return [Boolean]
    #
    def customized?
      customizations.present?
    end

    # Determine whether the additional fields on this item are
    # equivalent to the passed-in Hash of parameters. Uses the
    # `distinct_order_item_attributes` configuration setting to filter
    # down which parameters it will be checking equivalence on.
    #
    # @param [Hash] params - Updated order item parameters.
    # @return [Boolean] whether this item's attributes is equal to the
    #                   passed-in parameters.
    def attributes_eql?(params = {})
      params = params.to_h.with_indifferent_access
      attrs = params.slice(*Workarea.config.distinct_order_item_attributes)
      customizations = params[:customizations]&.stringify_keys
      distinct = attrs.all? do |attribute, value|
        self[attribute] == value
      end

      distinct && customizations_eql?(customizations)
    end

    # Determine whether the customizations of this item
    # are equivalent to the customizations of another.
    # This is used when updating/adding items so we can
    # see whether we should merge items that have the
    # same SKU but different customizations.
    #
    # @param [Hash] test
    # @return [Boolean]
    #
    def customizations_eql?(test)
      if test.present? && customizations.present?
        test.inject(true) do |memo, tuple|
          key, value = *tuple
          memo && customizations[key].to_s == value.to_s
        end
      else
        test.blank? && customizations.blank?
      end
    end
  end
end
