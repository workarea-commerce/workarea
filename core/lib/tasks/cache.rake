require 'workarea/tasks/cache'

namespace :workarea do
  namespace :cache do
    desc 'Prime images cache'
    task prime_images: :environment do
      Workarea::Tasks::Cache.prime_images
    end
  end
end
