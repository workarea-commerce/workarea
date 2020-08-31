require 'workarea/tasks/search'

namespace :workarea do
  namespace :search_index do
    def setup
      Workarea::Tasks::Search.setup
    end

    desc 'Reindex all data'
    task all: :environment do
      Rake::Task['workarea:search_index:storefront'].invoke
      Rake::Task['workarea:search_index:admin'].invoke
      Rake::Task['workarea:search_index:help'].invoke
    end

    desc 'Reindex admin'
    task admin: :environment do
      setup
      puts 'Indexing admin...'
      Workarea::Tasks::Search.index_admin
    end

    desc 'Reindex storefront'
    task storefront: :environment do
      setup
      puts 'Indexing storefront...'
      Workarea::Tasks::Search.index_storefront
    end

    desc 'Reindex help'
    task help: :environment do
      setup
      puts 'Indexing help...'
      Workarea::Tasks::Search.index_help
    end
  end
end
