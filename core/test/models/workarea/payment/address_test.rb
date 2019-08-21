require 'test_helper'

module Workarea
  class Payment
    class AddressTest < TestCase
      def test_po_box_addresses
        address = Payment::Address.new(
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '22 S. 3rd St.',
          street_2: 'Second Floor',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19106',
          country: 'US'
        )

        Workarea.config.allow_payment_address_po_box = false

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
          address.street = po_box
          refute(address.valid?)
          refute(address.errors[:street].empty?)
        end

        address.street = '22 S. 3rd St'
        po_boxes.each do |po_box|
          address.street_2 = po_box
          refute(address.valid?)
          refute(address.errors[:street_2].empty?)
        end

        Workarea.config.allow_payment_address_po_box = true
        address.street_2 = 'Second Floor'

        po_boxes.each do |po_box|
          address.street = po_box
          assert(address.valid?)
          refute(address.errors[:street].present?)
        end

        address.street = '22 S. 3rd St'
        po_boxes.each do |po_box|
          address.street_2 = po_box
          assert(address.valid?)
          refute(address.errors[:street_2].present?)
        end

        non_po_boxes.each do |non_po_box|
          address.street = non_po_box
          assert(address.valid?)
          assert(address.errors[:street].empty?)
        end

        address.street = '22 S. 3rd St'
        non_po_boxes.each do |non_po_box|
          address.street_2 = non_po_box
          assert(address.valid?)
          assert(address.errors[:street_2].empty?)
        end

        Workarea.config.allow_payment_address_po_box = true
        address.street_2 = 'Second Floor'

        non_po_boxes.each do |non_po_box|
          address.street = non_po_box
          assert(address.valid?)
          refute(address.errors[:street].present?)
        end

        address.street = '22 S. 3rd St'
        non_po_boxes.each do |non_po_box|
          address.street_2 = non_po_box
          assert(address.valid?)
          refute(address.errors[:street_2].present?)
        end
      end

      def test_knows_about_the_addressable_it_is_embedded_in
        payment = Payment.new(
          address: {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US'
          }
        )

        assert_equal(payment, payment.address.addressable)
      end
    end
  end
end
