require 'test_helper'

module RefererParser
  class ParserTest < Workarea::TestCase
    def test_parse_android_app_referrers
      referrers = [
        'android-app://com.linkedin.android',
        'android-app://org.telegram.plus',
        'android-app://com.twitter.android'
      ]

      referrers.each do |uri|
        referrer = Parser.new.parse(uri)

        refute(referrer[:known])
        assert_equal(uri, referrer[:uri])
      end
    end
  end
end
