require 'test_helper'

module Workarea
  module DataFile
    class CsvFieldsTest < TestCase
      class FooModel
        include Mongoid::Document

        field :test_time, type: Time
        field :test_datetime, type: DateTime
        field :test_date, type: Date
      end

      def test_deserialize_time
        field = FooModel.fields['test_time']
        model = FooModel.new

        date = '10/10/2020 15:30:00'
        assert(
          Time.parse(date),
          CsvFields.deserialize_from({ 'test_time' => date }, field: field, model: model)
        )

        date = '2020/10/30 15:30:00'
        assert(
          Time.parse(date),
          CsvFields.deserialize_from({ 'test_time' => date }, field: field, model: model)
        )

        date = '10/30/2020 15:30:00'
        assert_nil(
          CsvFields.deserialize_from({ 'test_time' => date }, field: field, model: model)
        )

        date = '10/10/20 15:30:00'
        assert_nil(
          CsvFields.deserialize_from({ 'test_time' => date }, field: field, model: model)
        )
      end

      def test_deserialize_datetime
        field = FooModel.fields['test_datetime']
        model = FooModel.new

        date = '10/10/2020 15:30:00'
        assert(
          Time.parse(date),
          CsvFields.deserialize_from({ 'test_datetime' => date }, field: field, model: model)
        )

        date = '2020/10/30 15:30:00'
        assert(
          Time.parse(date),
          CsvFields.deserialize_from({ 'test_datetime' => date }, field: field, model: model)
        )

        date = '10/30/2020 15:30:00'
        assert_nil(
          CsvFields.deserialize_from({ 'test_datetime' => date }, field: field, model: model)
        )

        date = '10/10/20 15:30:00'
        assert_nil(
          CsvFields.deserialize_from({ 'test_datetime' => date }, field: field, model: model)
        )
      end

      def test_deserialize_date
        field = FooModel.fields['test_date']
        model = FooModel.new

        date = '10/10/2020 15:30:00'
        assert(
          Time.parse(date),
          CsvFields.deserialize_from({ 'test_date' => date }, field: field, model: model)
        )

        date = '2020/10/30 15:30:00'
        assert(
          Time.parse(date),
          CsvFields.deserialize_from({ 'test_date' => date }, field: field, model: model)
        )

        date = '10/30/2020 15:30:00'
        assert_nil(
          CsvFields.deserialize_from({ 'test_date' => date }, field: field, model: model)
        )

        date = '10/10/20 15:30:00'
        assert_nil(
          CsvFields.deserialize_from({ 'test_date' => date }, field: field, model: model)
        )
      end
    end
  end
end
