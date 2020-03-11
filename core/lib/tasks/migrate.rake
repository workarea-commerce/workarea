require 'workarea/tasks/migrate'

namespace :workarea do
  namespace :migrate do
    desc 'Migrate the database from v3.4 to v3.5'
    task v3_5: :environment do
      Workarea::Tasks::Migrate.v3_5
    end
  end
end
