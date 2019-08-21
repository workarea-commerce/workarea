require 'test_helper'

module Workarea
  class ExportReportTest < TestCase
    setup :add_product_sales_data

    def add_product_sales_data
      Metrics::ProductByDay.inc(key: { product_id: 'foo' }, orders: 1)
      Metrics::ProductByDay.inc(key: { product_id: 'bar' }, orders: 2)
      create_product(id: 'foo')
    end

    def test_persistence
      Workarea.config.reports_max_results = 1
      csv = CSV.new(Tempfile.new)
      export = ExportReport.new(Reports::SalesByProduct.new, csv)

      export.save!
      assert_equal(2, export.collection.count)

      export.destroy!
      assert_equal(0, export.collection.count)
    end

    def test_csv_construction
      Workarea.config.reports_max_results = 1

      csv = CSV.new(Tempfile.new)
      export = ExportReport.new(
        Reports::SalesByProduct.new(sort_by: 'orders', sort_direction: 'desc'),
        csv
      )

      export.perform!
      results = csv.tap(&:rewind).read

      assert_equal(3, results.size)
      assert_equal(10, results.first.size)
      assert_equal('_id', results.first[0])
      assert_equal('orders', results.first[1])
      assert_equal(10, results.second.size)
      assert_equal('bar', results.second[0])
      assert_equal('2', results.second[1])
      assert_equal(10, results.third.size)
      assert_equal('foo', results.third[0])
      assert_equal('1', results.third[1])

      assert_equal(0, export.collection.count)

      csv = CSV.new(Tempfile.new)
      export = ExportReport.new(
        Reports::SalesByProduct.new(sort_by: 'orders', sort_direction: 'asc'),
        csv
      )

      export.perform!
      results = csv.tap(&:rewind).read
      assert_equal('foo', results.second[0])
      assert_equal('bar', results.third[0])
    end
  end
end
