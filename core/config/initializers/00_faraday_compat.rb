# frozen_string_literal: true

# elasticsearch-transport 5.x expects Faraday 0.x/1.x error constants under
# Faraday::Error::* (e.g. Faraday::Error::ConnectionFailed). Faraday 2.x
# removed these namespaces.

# Faraday 2 moved adapters into separate gems; without explicitly loading one,
# you can hit "Faraday::Connection without adapter".
begin
  require 'faraday/net_http'
rescue LoadError
  # Adapter gem may not be installed yet; tests will surface this clearly.
end

Faraday.default_adapter ||= :net_http if Faraday.respond_to?(:default_adapter)

module Faraday
  # In Faraday 2.x, Faraday::Error is a class. elasticsearch-transport expects
  # Faraday::Error::ConnectionFailed and Faraday::Error::TimeoutError.
  class Error
    ConnectionFailed = ::Faraday::ConnectionFailed unless const_defined?(:ConnectionFailed)
    TimeoutError = ::Faraday::TimeoutError unless const_defined?(:TimeoutError)
  end
end
