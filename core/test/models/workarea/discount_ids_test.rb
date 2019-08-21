require 'test_helper'

module Workarea
  class DiscountIdsTest < TestCase
    class DiscountIdsModel
      include Mongoid::Document
      include DiscountIds

      embeds_many :price_adjustments,
        class_name: 'Workarea::PriceAdjustment',
        extend: PriceAdjustmentExtension
    end

    def discount_price_adjustments
      @discount_price_adjustments ||= [
        PriceAdjustment.new(data: { 'discount_id' => 1 }),
        PriceAdjustment.new(data: { 'discount_id' => 2 }),
        PriceAdjustment.new(data: { 'discount_id' => 3 })
      ]
    end

    def test_save
      discount_ids_model = DiscountIdsModel.new
      discount_ids_model.price_adjustments = discount_price_adjustments
      discount_ids_model.save!
      assert_equal([1, 2, 3], discount_ids_model.as_document['discount_ids'])
    end

    def test_discount_ids
      discount_ids_model = DiscountIdsModel.new
      discount_ids_model.price_adjustments = discount_price_adjustments
      assert_equal([1, 2, 3], discount_ids_model.discount_ids)
    end
  end
end
