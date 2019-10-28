require 'test_helper'

module Workarea
  class Segment
    module Rules
      class BrowserInfoTest < TestCase
        def test_qualifies?
          refute(BrowserInfo.new.qualifies?(create_visit))

          visit = create_visit('HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.2 Safari/605.1.15')
          refute(BrowserInfo.new(general: %w(chrome)).qualifies?(visit))
          assert(BrowserInfo.new(general: %w(safari)).qualifies?(visit))
          refute(BrowserInfo.new(device: %w(mobile)).qualifies?(visit))
          assert(BrowserInfo.new(device: %w(unknown)).qualifies?(visit))
          refute(BrowserInfo.new(platform: %w(android)).qualifies?(visit))
          assert(BrowserInfo.new(platform: %w(mac)).qualifies?(visit))
          refute(BrowserInfo.new(general: %w(chrome), device: %w(mobile)).qualifies?(visit))
          assert(BrowserInfo.new(general: %w(safari), device: %w(mobile)).qualifies?(visit))

          visit = create_visit('HTTP_USER_AGENT' => 'Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10')
          refute(BrowserInfo.new(general: %w(chrome)).qualifies?(visit))
          assert(BrowserInfo.new(general: %w(safari)).qualifies?(visit))
          refute(BrowserInfo.new(device: %w(mobile)).qualifies?(visit))
          assert(BrowserInfo.new(device: %w(ipad)).qualifies?(visit))
          refute(BrowserInfo.new(platform: %w(android)).qualifies?(visit))
          assert(BrowserInfo.new(platform: %w(ios)).qualifies?(visit))
          refute(BrowserInfo.new(general: %w(chrome), platform: %w(mobile)).qualifies?(visit))
          assert(BrowserInfo.new(general: %w(chrome), platform: %w(ios)).qualifies?(visit))
        end
      end
    end
  end
end
