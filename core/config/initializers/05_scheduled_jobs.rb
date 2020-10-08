unless Workarea.skip_services?
  Sidekiq.logger.log_at(:error) do
    Sidekiq::Cron::Job.create(
      name: 'Workarea::CleanInventoryTransactions',
      klass: 'Workarea::CleanInventoryTransactions',
      cron: "0 5 * * * #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::CleanOrders',
      klass: 'Workarea::CleanOrders',
      cron: "0 6 * * * #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::ProcessProductRecommendations',
      klass: 'Workarea::ProcessProductRecommendations',
      cron: "30 1 * * 6 #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::ProcessSearchRecommendations',
      klass: 'Workarea::ProcessSearchRecommendations',
      cron: "30 2 * * 6 #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::KeepProductIndexFresh',
      klass: 'Workarea::KeepProductIndexFresh',
      cron: "5,20,35,50 * * * * #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::DeactivateStaleDiscounts',
      klass: 'Workarea::DeactivateStaleDiscounts',
      cron: "30 1 * * * #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::GenerateContentMetadata',
      klass: 'Workarea::GenerateContentMetadata',
      cron: "0 3 1 * * #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::StatusReporter',
      klass: 'Workarea::StatusReporter',
      cron: "0 4 * * * #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::OrderReminder',
      klass: 'Workarea::OrderReminder',
      cron: "20 * * * * #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::VerifyScheduledReleases',
      klass: 'Workarea::VerifyScheduledReleases',
      cron: "55 * * * * #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::GenerateInsights',
      klass: 'Workarea::GenerateInsights',
      cron: "0 1 * * * #{Time.zone.tzinfo.identifier}",
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::BulkIndexSearches',
      klass: 'Workarea::BulkIndexSearches',
      cron: '0 1 * * 1',
      queue: 'low'
    )

    Sidekiq::Cron::Job.create(
      name: 'Workarea::GenerateSitemaps',
      klass: 'Workarea::GenerateSitemaps',
      cron: '0 5 * * *',
      queue: 'low'
    )
  end
end
