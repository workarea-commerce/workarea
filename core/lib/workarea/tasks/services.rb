module Workarea
  module Tasks
    module Services
      extend self

      def assert_docker_compose_installed!
        unless system('docker-compose -v > /dev/null 2>&1')
          STDERR.puts <<~eos
  **************************************************
  ⛔️ ERROR: workarea:services tasks depend on Docker Compose being installed. \
  See https://docs.docker.com/compose/install/ for how to install.
  **************************************************
            eos
          exit
        end
      end

      def compose_file_path
        File.join(Gem::Specification.find_by_name('workarea').gem_dir, 'docker-compose.yml')
      end

      def compose_env
        require 'workarea/version'

        {
          'COMPOSE_FILE' => compose_file_path,
          'COMPOSE_PROJECT_NAME' => File.basename(Dir.pwd),

          'MONGODB_VERSION' => Workarea::VERSION::MONGODB::STRING,
          'MONGODB_PORT' => ENV['WORKAREA_MONGODB_PORT'] || '27017',

          'REDIS_VERSION' => Workarea::VERSION::REDIS::STRING,
          'REDIS_PORT' => ENV['WORKAREA_REDIS_PORT'] || '6379',

          'ELASTICSEARCH_VERSION' => Workarea::VERSION::ELASTICSEARCH::STRING,
          'ELASTICSEARCH_PORT' => ENV['WORKAREA_ELASTICSEARCH_PORT'] || '9200'
        }
      end

      def up
        assert_docker_compose_installed!

        if system(compose_env, "docker-compose up -d #{ENV['COMPOSE_ARGUMENTS']} #{ENV['WORKAREA_SERVICES']}")
          puts '✅ Success! Workarea services are running in the background. Run workarea:services:down to stop them.'
        else
          STDERR.puts '⛔️ Error! There was an error starting Workarea services.'
        end
      end

      def down
        assert_docker_compose_installed!

        if system(compose_env, "docker-compose down #{ENV['COMPOSE_ARGUMENTS']}")
          puts '✅ Success! Workarea services are stopped. Run workarea:services:up to start them.'
        else
          STDERR.puts '⛔️ Error! There was an error stopping Workarea services.'
        end
      end

      def clean
        assert_docker_compose_installed!

        if system(compose_env, "docker-compose down -v #{ENV['COMPOSE_ARGUMENTS']}")
          puts '✅ Success! Workarea service volumes have been removed. Run workarea:services:up to start services and recreate volumes.'
        else
          STDERR.puts '⛔️ Error! There was an error removing Workarea service volumes.'
        end
      end
    end
  end
end
