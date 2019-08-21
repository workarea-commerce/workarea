module Workarea
  class ReleaseServerMiddleware
    def initialize(options = {})
      @options = options
    end

    def call(worker, msg, queue)
      Release.with_current(nil) { yield }
    end
  end
end
