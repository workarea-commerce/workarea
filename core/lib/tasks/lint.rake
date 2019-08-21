namespace :workarea do
  desc 'Check the application for suspicious data'
  task lint: :environment do
    require 'workarea/lint'
    Workarea::Lint.run
  end
end
