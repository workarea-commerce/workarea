require 'test_helper'

module Workarea
  class MonitoringIntegrationTest < Workarea::IntegrationTest
    def test_monitors_the_mongodb_status
      get workarea.easymon_path + '/mongodb'
      assert_includes(response.body, 'Up')
    end

    def test_monitors_the_redis_status
      get workarea.easymon_path + '/redis'
      assert_includes(response.body, 'Up')
    end

    def test_monitors_the_elasticsearch_status
      get workarea.easymon_path + '/elasticsearch'
      assert_includes(response.body, 'Up')
    end

    def test_monitors_the_sidekiq_queue_status
      get workarea.easymon_path + '/sidekiq-queue'
      assert_includes(response.body, 'Low')
    end

    def test_monitors_for_load_balancing
      get workarea.easymon_path + '/load-balancing'
      assert_includes(response.body, 'Up')
    end

    def test_critical_endpoint
      get workarea.easymon_path + "/critical"
      assert_includes(response.body, 'Up')
    end
  end
end
