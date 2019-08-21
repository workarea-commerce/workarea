namespace :workarea do
  desc 'clear out host assets, logs, caches, and tmp files'
  task cleanup: :environment do
    puts 'Cleaning up assets...'
    Rake::Task['assets:clean'].invoke

    puts 'Cleaning up logs...'
    Rake::Task['log:clear'].invoke

    puts 'Cleaning up temp files...'
    Rake::Task['tmp:clear'].invoke
  end
end
