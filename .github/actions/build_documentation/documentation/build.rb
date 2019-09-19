require 'bundler'
require 'fileutils'
require 'aws-sdk-s3'
require 'action_dispatch/http/mime_type'
require_relative './s3'
require_relative '../github/workspace/core/lib/workarea/version'

module Documentation
  class Build
    def perform(docs_path)
      build_successful = build_documentation(docs_path, tmp_destination)
      raise('build failed') unless build_successful

      File.open(tmp_destination + '/.version', 'w') { |f| f << version }

      puts 'uploading documentation...'
      s3.upload!(version, tmp_destination) if s3_configured?

      puts 'documentation updated!'
    end

    def build_documentation(source, destination)
      puts 'building documentation...'
      Bundler.with_clean_env do
        system("cd #{source}; bundle install --path vendor/bundle --binstubs=bin && bin/middleman build --build-dir=#{destination} --verbose")
      end
    rescue
      false
    end

    def version
      @version ||= [Workarea::VERSION::MAJOR, Workarea::VERSION::MINOR].join('.')
    end

    def s3
      @s3 ||= S3.new(s3_configuration)
    end

    def s3_configured?
      %i(region bucket access_key_id secret_access_key).all? do |key|
        !s3_configuration[key].empty?
      end
    end

    def s3_configuration
      @s3_configuration ||= {
        region: ENV.fetch('S3_REGION', 'us-east-1'),
        bucket: ENV.fetch('S3_BUCKET'),
        access_key_id: ENV.fetch('S3_ACCESS_KEY_ID'),
        secret_access_key: ENV.fetch('S3_SECRET_ACCESS_KEY')
      }
    rescue KeyError
      @s3_configuration = {}
    end

    def tmp_destination
      @tmp_destination ||= File.join(Dir.tmpdir, '/workarea_documentation').tap do |dir|
        FileUtils.rm_rf(dir)
        FileUtils.mkdir_p(dir)
      end
    end
  end
end

Documentation::Build.new.perform(ARGV.first)
