module Workarea
  class DockerGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    desc File.read(File.expand_path('../USAGE', __FILE__))

    class_option 'webpack',
      type: :boolean,
      aliases: '-W',
      desc: 'include configuration for webpack/yarn'
    class_option 'sync',
      type: :boolean,
      aliases: '-S',
      desc: 'include configuration for docker-sync'

    def create_dockerfile
      template('Dockerfile.erb', 'Dockerfile')
      template('docker-entrypoint.sh.erb', 'docker-entrypoint.sh')
      template('docker-wait.sh', 'docker-wait.sh')
    end

    def create_docker_compose
      template('docker-compose.yml.erb', 'docker-compose.yml')
    end

    def create_docker_environment_files
      template('docker.env', 'docker.env')
      template('.env.erb', '.env')
    end

    def create_docker_initializer
      template('docker_init.rb.erb', 'config/initializers/z_docker.rb')
    end

    def create_docker_sync
      return unless include_docker_sync?
      template('docker-sync.yml.erb', 'docker-sync.yml')
    end

    def update_gitignore
      append_file '.gitignore', "\n\n# Ignore docker caches\ndocker"

      if include_docker_sync?
        append_file '.gitignore', "\n.docker-sync"
      end
    end

    private

    def app_name
      @app_name ||= Rails.root.to_s.split('/').last
    end

    def include_webpack?
      !!options['webpack']
    end

    def include_docker_sync?
      !!options['sync']
    end
  end
end
