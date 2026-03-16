module Workarea
  module LatestVersion
    def self.get
      Rails.cache.fetch('workarea/version/latest', expires_in: 3.days) do
        request = Net::HTTP::Get.new('/api/v1/gems/workarea.json')
        request.content_type = 'application/json'

        uri = URI('https://rubygems.org')
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |h|
          h.request(request)
        end

        JSON.parse(response.body)['version']
      end
    rescue Exception => e
      Workarea::ErrorReporting.report(
        e,
        handled: true,
        severity: :warning,
        context: { service: 'rubygems.org', url: 'https://rubygems.org/api/v1/gems/workarea.json' }
      )

      Rails.logger.error '-------------------------------------'
      Rails.logger.error "There was an error contacting rubygems.org!"
      Rails.logger.error e.class
      Rails.logger.error e.message
      Rails.logger.error '-------------------------------------'
    end
  end
end
