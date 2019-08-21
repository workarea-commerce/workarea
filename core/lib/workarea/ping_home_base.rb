module Workarea
  class PingHomeBase
    URL = 'https://homebase.weblinc.com'
    SHARED_SECRET = 'e20750f19f5acfe314050da46e6aa77e'

    class << self
      def ping
        begin
          ENV['HTTP_PROXY'] || ENV['HTTPS_PROXY']
          request = Net::HTTP::Post.new('/ping')
          request['X-WeblincClientName'] = Workarea.config.site_name
          request['X-WeblincAuthToken'] = auth_token
          request.content_type = 'application/json'
          request.body = Request.new.to_json

          uri = URI(URL)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.start { |h| h.request(request) }

        rescue Exception => e
          Rails.logger.error '-------------------------------------'
          Rails.logger.error "There was an error contacting #{URL}!"
          Rails.logger.error e.class
          Rails.logger.error e.message
          Rails.logger.error '-------------------------------------'
        end
      end

      def auth_token
        Digest::SHA256.hexdigest(Workarea.config.site_name + SHARED_SECRET)
      end
    end

    class Request
      PLUGINS_TO_SKIP = ["Workarea::Storefront", "Workarea::Admin"]
      delegate :to_json, to: :to_h

      def to_h
        {
          domain: Workarea.config.host,
          name: Workarea.config.site_name,
          version: Workarea::VERSION::STRING,
          environment: Rails.env,
          ruby_version: RUBY_VERSION,
          client_id: client_id,
          plugins: plugins
        }.compact
      end

      private

      def client_id
        return unless File.exist?(Rails.root.join('.client-id'))

        File.read(Rails.root.join('.client-id'))
      rescue
        nil
      end

      def plugins
        Workarea::Plugin.installed
          .reject { |plugin| PLUGINS_TO_SKIP.include?(plugin.to_s) }
          .map { |plugin| { name: plugin.homebase_name, version: plugin.version } }
      end
    end
  end
end
