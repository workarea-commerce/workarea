# frozen_string_literal: true

# Rack 3 removed `rack/file` in favor of `rack/files`.
# Some third-party gems (e.g. serviceworker-rails <= 0.6.0) still require the
# old path. Provide a small shim so Rails can boot under Rack 3 / Rails 7.2.

require 'rack/files'
