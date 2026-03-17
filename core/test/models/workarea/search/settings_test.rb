require 'test_helper'

module Workarea
  module Search
    class SettingsTest < TestCase

      def test_sanitized_synonyms
        settings = Settings.new
        settings.synonyms = "t-shirt, tee-shirt \n foo, bar \n BeN , cRoUsE"

        assert_equal(
          ['t shirt,tee shirt', 'foo,bar', 'ben,crouse'],
          settings.sanitized_synonyms
        )
      end

      def test_current_is_idempotent
        Settings.create_indexes
        Thread.current[:current_search_settings] = nil

        first = Settings.current
        second = Settings.current

        assert_equal(first.id, second.id)
        assert_equal(1, Settings.where(index: first.index).count)
      ensure
        Thread.current[:current_search_settings] = nil
      end
    end
  end
end
