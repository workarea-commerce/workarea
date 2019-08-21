require 'faker'
I18n.reload! # For faker

module Workarea
  module Seeds
    def self.run
      Workarea.with_config do |config|
        config.send_email = false

        puts_with_color "== Setting up...", :yellow
        reset

        puts_with_color "\n== Loading MongoDB data", :yellow
        Workarea.config.seeds.each { |c| c.constantize.new.perform }

        puts_with_color "\n== Loading Elasticsearch data", :yellow
        Rake::Task['workarea:search_index:all'].invoke
        Catalog::Category.all.each { |c| IndexCategorization.perform(c) }

        puts_with_color "\nSuccess!", :green
      end
    end

    def self.reset
      delete_search_indexes
      delete_mongoid_data
      delete_redis_data
      install

      Rails.cache.clear
    end

    def self.delete_search_indexes
      puts 'Deleting Elasticsearch indexes...'
      Elasticsearch::Document.all.each(&:delete_indexes!)
    end

    def self.delete_mongoid_data
      puts 'Cleaning MongoDB collections...'
      Mongoid::AuditLog::Entry
        .where(audited_type: /^Workarea::/)
        .delete_all

      Mongoid::Clients
        .with_name('default')
        .collections
        .select { |c| c.name =~ /workarea_/ }
        .each(&:drop)
    end

    def self.delete_redis_data
      puts 'Flushing Redis database...'
      Workarea.redis.flushdb
    end

    def self.install
      puts 'Ensuring MongoDB indexes...'
      Rake::Task['db:mongoid:create_indexes'].invoke

      puts 'Ensuring Elasticsearch indexes...'
      Elasticsearch::Document.all.each(&:create_indexes!)
      Search::Storefront.ensure_dynamic_mappings
    end

    def self.puts_with_color(string, color)
      puts "\e[#{Workarea::COLOR_CODES[color]}m#{string}\e[0m"
    end
  end
end
