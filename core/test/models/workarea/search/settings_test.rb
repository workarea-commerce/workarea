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
    end
  end
end
