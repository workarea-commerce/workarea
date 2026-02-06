# frozen_string_literal: true

# elasticsearch-transport 5.x expects Faraday 0.x/1.x error constants under
# Faraday::Error::* (e.g. Faraday::Error::ConnectionFailed). Faraday 2.x
# removed these namespaces.

module Faraday
  # In Faraday 2.x, Faraday::Error is a class. elasticsearch-transport expects
  # Faraday::Error::ConnectionFailed and Faraday::Error::TimeoutError.
  class Error
    ConnectionFailed = ::Faraday::ConnectionFailed unless const_defined?(:ConnectionFailed)
    TimeoutError = ::Faraday::TimeoutError unless const_defined?(:TimeoutError)
  end
end
