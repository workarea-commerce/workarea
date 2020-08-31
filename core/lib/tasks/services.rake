require 'workarea/tasks/services'

namespace :workarea do
  namespace :services do
    desc 'Start Workarea background services for this app'
    task :up do
      puts 'Starting Workarea services...'
      Workarea::Tasks::Services.up
    end

    desc 'Stop Workarea external services for this app'
    task :down do
      puts 'Stopping Workarea services...'
      Workarea::Tasks::Services.down
    end

    desc 'Remove data volumes associated with Workarea external services. Stops containers.'
    task :clean do
      puts 'Removing Workarea service data...'
      Workarea::Tasks::Services.clean
    end
  end
end
