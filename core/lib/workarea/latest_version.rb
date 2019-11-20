module Workarea
  module LatestVersion
    def self.get
      Rails.cache.fetch('workarea/version/latest', expires_in: 3.days) do
        request = Net::HTTP::Get.new('/api/v1/gems/workarea.json')
        request.content_type = 'application/json'

        uri = URI('https://rubygems.org')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.start { |h| h.request(request) }

        JSON.parse(response.body)['version']
      end
    rescue Exception => e
      Rails.logger.error '-------------------------------------'
      Rails.logger.error "There was an error contacting rubygems.org!"
      Rails.logger.error e.class
      Rails.logger.error e.message
      Rails.logger.error '-------------------------------------'
    end
  end
end
