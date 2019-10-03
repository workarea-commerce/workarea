module Workarea
  module Factories
    module Segment
      Factories.add(self)

      def create_life_cycle_segments
        Workarea::Segment::LifeCycle.create!
      end

      def create_segment(overrides = {})
        attributes = factory_defaults(:segment).merge(overrides)
        Workarea::Segment.create!(attributes)
      end

      def create_visit(overrides = {})
        attributes = sample_rack_env.merge(overrides.except(:email, :sessions))
        result = Workarea::Visit.new(attributes)

        if overrides[:email].present?
          result.cookies.signed[:email] = overrides[:email]
        end

        if overrides[:sessions].present?
          result.cookies[:sessions] = overrides[:sessions]
        end

        if overrides.key?(:logged_in)
          result.stubs(logged_in?: overrides[:logged_in])
        end

        result
      end

      def sample_rack_env
        Rails.application.env_config.merge(
          'rack.version' => [1, 3],
          'rack.multithread' => true,
          'rack.multiprocess' => true,
          'rack.run_once' => false,
          'REQUEST_METHOD' => 'GET',
          'SERVER_NAME' => 'www.example.com',
          'SERVER_PORT' => '80',
          'QUERY_STRING' => '',
          'PATH_INFO' => '/current_user.json',
          'rack.url_scheme' => 'http',
          'HTTPS' => 'off',
          'SCRIPT_NAME' => '',
          'CONTENT_LENGTH' => '0',
          'rack.test' => true,
          'REMOTE_ADDR' => '127.0.0.1',
          'REQUEST_URI' => '/current_user.json',
          'HTTP_HOST' => 'www.example.com',
          'CONTENT_TYPE' => nil,
          'HTTP_ACCEPT' => 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
          'HTTP_COOKIE' => '',
          'ORIGINAL_FULLPATH' => '/current_user.json',
          'ORIGINAL_SCRIPT_NAME' => ''
        )
      end
    end
  end
end
