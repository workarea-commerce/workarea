# frozen_string_literal: true

module Workarea
  class ReleaseServerMiddleware
    def initialize(options = {})
      @options = options
    end

    def call(worker, msg, queue)
      Release.without_current { yield }
    end
  end
end
