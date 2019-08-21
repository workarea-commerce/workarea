require 'test_helper'
require 'generators/workarea/docker/docker_generator'

module Workarea
  class DockerGeneratorTest < GeneratorTest
    tests Workarea::DockerGenerator
    destination Dir.mktmpdir
    setup :prepare_destination

    setup :make_gitignore

    def make_gitignore
      FileUtils.touch("#{destination_root}/.gitignore")
    end

    def test_optionless_generator
      run_generator
      assert_file 'docker.env'
      assert_no_file 'docker-sync.yml'

      assert_file '.env' do |file|
        assert_match('GEM_HOME=/gems', file)
      end

      assert_file 'Dockerfile' do |file|
        refute_match('EXPOSE 3035', file)
      end

      assert_file 'docker-compose.yml' do |file|
        assert_match('.:${APP_PATH}', file)
        refute_match('webpack_server:', file)
        assert_match('gem_cache:/gems', file)
      end

      assert_file 'docker-entrypoint.sh' do |file|
        assert_match('bin/rails server', file)
      end

      assert_file 'config/initializers/z_docker.rb' do |file|
        assert_match('ActiveSupport::FileUpdateChecker', file)
        assert_match('config.web_console.whitelisted_ips', file)
      end

      assert_file '.gitignore' do |file|
        assert_match('# Ignore docker caches', file)
      end
    end

    def test_generator_with_sync
      run_generator %w(--sync)
      assert_file 'docker.env'
      assert_file 'docker-sync.yml'

      assert_file '.env' do |file|
        assert_match('GEM_HOME=/workarea/docker', file)
      end

      assert_file 'Dockerfile' do |file|
        refute_match('EXPOSE 3035', file)
      end

      assert_file 'docker-compose.yml' do |file|
        refute_match('.:${APP_PATH}', file)
        assert_match('-sync:${APP_PATH}:nocopy', file)
        refute_match('webpack_server:', file)
        refute_match('gem_cache:/gems', file)
      end

      assert_file 'docker-entrypoint.sh' do |file|
        assert_match('bin/rails server', file)
      end

      assert_file 'config/initializers/z_docker.rb' do |file|
        refute_match('ActiveSupport::FileUpdateChecker', file)
        assert_match('config.web_console.whitelisted_ips', file)
      end

      assert_file '.gitignore' do |file|
        assert_match('# Ignore docker caches', file)
        assert_match('.docker-sync', file)
      end
    end

    def test_generator_with_webpack
      FileUtils.touch("#{destination_root}/Gemfile")

      run_generator %w(--webpack)
      assert_file 'docker.env'
      assert_no_file 'docker-sync.yml'

      assert_file '.env' do |file|
        assert_match('GEM_HOME=/gems', file)
      end

      assert_file 'Dockerfile' do |file|
        assert_match('EXPOSE 3035', file)
      end

      assert_file 'docker-compose.yml' do |file|
        assert_match('.:${APP_PATH}', file)
        assert_match('webpack_server:', file)
        assert_match('gem_cache:/gems', file)
      end

      assert_file 'docker-entrypoint.sh' do |file|
        assert_match('yarn install', file)
      end

      assert_file 'config/initializers/z_docker.rb' do |file|
        assert_match('ActiveSupport::FileUpdateChecker', file)
      end

      assert_file '.gitignore' do |file|
        assert_match('# Ignore docker caches', file)
        refute_match('.docker-sync', file)
      end
    end

    def test_generator_with_webpack_and_sync
      FileUtils.touch("#{destination_root}/Gemfile")

      run_generator %w(-WS)
      assert_file 'docker.env'
      assert_file 'docker-sync.yml'

      assert_file '.env' do |file|
        assert_match('GEM_HOME=/workarea/docker', file)
      end

      assert_file 'Dockerfile' do |file|
        assert_match('EXPOSE 3035', file)
      end

      assert_file 'docker-compose.yml' do |file|
        refute_match('.:${APP_PATH}', file)
        assert_match('-sync:${APP_PATH}:nocopy', file)
        assert_match('webpack_server:', file)
        refute_match('gem_cache:/gems', file)
      end

      assert_file 'docker-entrypoint.sh' do |file|
        assert_match('yarn install', file)
      end

      assert_file 'config/initializers/z_docker.rb' do |file|
        refute_match('ActiveSupport::FileUpdateChecker', file)
        assert_match('config.web_console.whitelisted_ips', file)
      end

      assert_file '.gitignore' do |file|
        assert_match('# Ignore docker caches', file)
        assert_match('.docker-sync', file)
      end
    end
  end
end
