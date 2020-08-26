module Workarea
  module Tasks
    module Migrate
      extend self

      def v3_5
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

        Workarea::Tax::Category.all.each_by(100) do |category|
          category.rates.each_by(500) do |rate|
            rate.postal_code_percentage = rate.percentage
            rate.percentage = nil
          end

          category.save!
          count += 1
        end

        puts "✅ #{count} tax categories updated."

        count = 0
        failed_ids = []
        backup = Mongo::Collection.new(Mongoid::Clients.default.database, 'workarea_legacy_segments')

        legacy_segments = Workarea::Segment.collection.find.to_a
        legacy_segments.each do |doc|
          backup.insert_one(doc)
          Workarea::Segment.collection.delete_one(doc.slice('_id'))

          segment = Workarea::Segment.new(
            id: doc['_id'],
            name: doc['name'],
            subscribed_user_ids: doc['subscribed_user_ids'],
            created_at: doc['created_at'],
            updated_at: doc['updated_at']
          )

          doc['conditions'].each do |condition|
            if condition['_type'] =~ /UserTag/
              segment.rules << Workarea::Segment::Rules::Tags.new(tags: condition['tags'])
            elsif condition['_type'] =~ /TotalSpent/
              rule = Workarea::Segment::Rules::Revenue.new

              if condition['operator'] == 'equals'
                rule.minimum = rule.maximum = Money.demongoize(condition['amount'])
              elsif condition['operator'] == 'less_than_or_equals'
                rule.maximum = Money.demongoize(condition['amount'])
              elsif condition['operator'] == 'less_than'
                rule.maximum = (Money.demongoize(condition['amount']) - 0.01.to_m)
              elsif condition['operator'] == 'greater_than_or_equals'
                rule.minimum = Money.demongoize(condition['amount'])
              elsif condition['operator'] == 'greater_than'
                rule.minimum = (Money.demongoize(condition['amount']) + 0.01.to_m)
              end

              segment.rules << rule
            end
          end

          if doc['conditions'].size == segment.rules.size && segment.save
            count += 1
          else
            failed_ids << doc['_id']
          end
        end

        puts "✅ #{count} segments have been migrated." if count > 0
        if failed_ids.any?
          puts "⛔️ #{failed_ids.count} segments failed to migrate."
          puts "You can find copies of the original segments in the workarea_legacy_segments collection."
          puts "The segments that failed are #{failed_ids.to_sentence}."
        end

        Workarea::Segment::LifeCycle.create!
        puts "✅ Life cycle segments have been created."

        admin_ids = Workarea::User.admins.pluck(:id)
        admin_ids.each do |id|
          Workarea::SynchronizeUserMetrics.new.perform(id)
        end
        puts "✅ #{admin_ids.count} admins have had their metrics synchronized." if admin_ids.count > 0

        puts "\nMigration complete!"
      end
    end
  end
end
