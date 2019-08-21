require 'test_helper'

module Workarea
  module Insights
    class BaseTest < TestCase
      def test_reporting_on
        travel_to Time.zone.local(2019, 1, 9, 11)
        assert_equal(Time.zone.local(2019, 1, 8, 11), Base.create!.reporting_on)
      end

      def test_by_dashboard
        one = Base.create!(dashboards: %w(catalog people))
        two = Base.create!(dashboards: %w(catalog))
        three = Base.create!(dashboards: %w(people))

        assert_equal([three, two, one], Base.by_dashboard('catalog', 'people').to_a)
      end

      def test_current
        assert_instance_of(Base, Base.current)

        last_month = Base.create!(created_at: 1.month.ago)
        assert_equal(last_month, Base.current)

        last_week = Base.create!(created_at: 1.week.ago)
        assert_equal(last_week, Base.current)
      end

      def test_include?
        id = BSON::ObjectId.new
        instance = Base.create!(results: [{ 'category_id' => id }])

        assert(instance.include?(category_id: id))
        assert(instance.include?(category_id: id.to_s))
        assert(instance.include?('category_id' => id))
        assert(instance.include?('category_id' => id.to_s))
        refute(instance.include?(category_id: 'foo'))
      end
    end
  end
end
