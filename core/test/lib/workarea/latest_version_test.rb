require 'test_helper'

module Workarea
  class LatestVersionTest < TestCase
    def test_get
      VCR.use_cassette 'get_latest_version' do
        assert_equal('3.4.21', Workarea::LatestVersion.get)
      end
    end
  end
end
