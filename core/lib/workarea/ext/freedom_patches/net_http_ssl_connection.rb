require 'net/http'

# ActiveMerchant 1.79.2 introduced a bug in their refinement of
# +Net::HTTP+ when using with +VCR+, since VCR overrides the
# +Net::HTTP#start+ method as a means of sandboxing HTTP requests from
# being actually run in favor of using the stored response. This sets
# all the other variables Net::HTTP is expecting except for +@socket+,
# resulting in an error when using a real payment gateway with AM.

if Rails.env.test?
  NetHttpSslConnection.module_eval do
    refine Net::HTTP do
      def ssl_connection
        return {} unless @socket.present?
        { version: @socket.io.ssl_version, cipher: @socket.io.cipher[0] }
      end
    end
  end
end
