require 'workarea/tasks/help'

namespace :workarea do
  desc 'Drop and recreate help articles (Warning: all current help will be deleted!)'
  task reload_help: :environment do
    puts 'Deleting help articles...'
    Workarea::Tasks::Help.reload
    Rake::Task['workarea:search_index:help'].invoke
  end

  desc 'Upgrade help (creates only new articles that do not exist in the database)'
  task upgrade_help: :environment do
    Workarea::HelpSeeds.new.perform
    Rake::Task['workarea:search_index:help'].invoke
  end

  task dump_help: :environment do
    Workarea::Tasks::Help.dump
  end
end
