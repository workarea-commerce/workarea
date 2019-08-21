module Dragonfly
  class Job
    class FetchUrl < Step
      def get(url)
        url = parse_url(url)
        proxy_url = ENV['HTTPS_PROXY'] || ENV['HTTP_PROXY']
        proxy = URI.parse(proxy_url) if proxy_url.present?

        http = Net::HTTP.new(url.host, url.port, proxy&.host, proxy&.port)
        http.use_ssl = true if url.scheme == 'https'

        request = Net::HTTP::Get.new(url.request_uri)

        if url.user || url.password
          request.basic_auth(url.user, url.password)
        end

        http.request(request)
      end
    end
  end
end
