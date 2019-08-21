require 'test_helper'

module Workarea
  class AddressTest < Workarea::TestCase
    def test_phone_number_stripping_special_characters
      address = Address.new
      address.phone_number = '215 925-1800'
      assert_equal(address.phone_number, '2159251800')
    end

    def test_po_box_matching
      refute(Address.new.po_box?)

      po_boxes = [
        'PO Box 123',
        'P O box 123',
        'P. O. Box 123',
        'P.O.Box 123',
        'post box 123',
        'post office box 123',
        'post office 123',
        'P.O.B 123',
        'P.O.B. 123',
        'Post Office Bin 123',
        'Postal Code 123',
        'Post Box #123',
        'Postal Box 123',
        'P.O. Box 123',
        'PO. Box 123',
        'P.o box 123',
        'Pobox 123',
        'pob 123',
        'pob123',
        'pobox123',
        'p.o. Box123',
        'po-box123',
        'p.o.-box 123',
        'PO-Box 123',
        'p-o-box 123',
        'p-o box 123',
        'box 123',
        'Box123',
        'Box-123'
      ]

      non_po_boxes = [
        '123 Box Turtle Circle',
        '123 Boxing Pass',
        '123 Poblano Lane',
        '123 P O Davis Drive',
        '123 Postal Circle'
      ]

      po_boxes.each do |po_box|
        assert(Address.new(street: po_box).po_box?)
      end

      po_boxes.each do |po_box|
        assert(Address.new(street_2: po_box).po_box?)
      end

      non_po_boxes.each do |non_po_box|
        refute(Address.new(street: non_po_box).po_box?)
      end

      non_po_boxes.each do |non_po_box|
        refute(Address.new(street_2: non_po_box).po_box?)
      end
    end

    def test_as_json
      address = Address.new(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      assert_equal('US', address.as_json['country'])
      assert_includes(address.to_json, '"country":"US"')
    end

    def test_region_name
      address = Address.new

      address.country = 'US'
      assert_equal('', address.region_name)

      address.region = 'PA'
      assert_equal('Pennsylvania', address.region_name)

      address.country = 'AW'
      address.region = nil
      assert_equal('', address.region_name)

      address.region = 'Foo'
      assert_equal('Foo', address.region_name)
    end

    def test_setting_country
      address = Address.new
      address.country = Country['US'].to_s
      address.valid?
      assert(address.errors['country'].blank?)
    end
  end
end
