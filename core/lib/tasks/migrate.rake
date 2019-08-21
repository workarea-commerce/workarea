namespace :workarea do
  namespace :migrate do
    desc 'Migrate the database from v3.4 to v3.5'
    task v3_5: :environment do
      count = 0

      Workarea::Release.where(:undo_at.gte => Time.current).each do |release|
        undo = release.build_undo(publish_at: release.undo_at).tap(&:save!)

        release.changesets.each do |changeset|
          changeset.build_undo(release: undo).save!
        end

        Workarea::Scheduler.delete(release.undo_job_id)

        release.update_attributes!(undo_at: nil, undo_job_id: nil)
        count += 1
      end

      Workarea::Release.all.each { |r| Workarea::IndexAdminSearch.perform(r) }

      puts "✅ #{count} undo releases have been created."

      count = 0

      Workarea::Tax::Category.each_by(100) do |category|
        category.rates.each_by(500) do |rate|
          rate.postal_code_percentage = rate.percentage
          rate.percentage = nil
        end

        category.save!
        count += 1
      end

      puts "✅ #{count} tax categories updated."

      Workarea::Catalog::Product.each_by(500) do |product|
        next unless product.digital?

        product.skus.each do |sku|
          fulfillment = Workarea::Fulfillment::Sku.find_or_initialize_by(id: sku)
          fulfillment.policy = 'ignore'
          fulfillment.save!
        end
      end

      puts "✅ #{count} fulfillment skus for digital product have been created."
      puts "Migration complete!"
    end
  end
end
