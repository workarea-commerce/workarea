module Workarea
  module AssetEndpoints
    class Base
      attr_reader :params, :app, :env

      def initialize(params, app, env)
        @params = params
        @app = app
        @env = env
      end

      def result
        raise(NotImplementedError, "#{self.class} must implement #result")
      end

      private

      def request
        @request ||= Rack::Request.new(env)
      end
    end
  end
end
