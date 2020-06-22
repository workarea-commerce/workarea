module Dragonfly
  class Job
    class FetchUrl < Step
      class ProxyError < RuntimeError
        def initialize(url)
          super <<~TXT
            Error fetching '#{url}' with Dragonfly!

            This URL is not allowed through the proxy, and therefore the
            request was blocked by the Workarea Commerce Cloud firewall.

            To allow the host through your proxy server, run the following
            command on your local development workstation:

                workarea [qa|staging|production] edit proxy

            Thanks for using Commerce Cloud, and keeping your Workarea
            application safe.
          TXT
        end
      end

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

        response = http.request(request)

        raise ProxyError, url if blocked?(response)

        response
      end

      def blocked?(response)
        response.code.to_i == 403 &&
          response.header['X-Squid-Error'] == 'ERR_ACCESS_DENIED 0'
      end
    end
  end
end
