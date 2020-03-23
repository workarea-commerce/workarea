#
# MongoDB monitoring
#
Easymon::Repository.add(
  'mongodb',
  Workarea::Monitoring::MongoidCheck.new,
  :critical
)

#
# Elasticsearch monitoring
#
Easymon::Repository.add(
  'elasticsearch',
  Workarea::Monitoring::ElasticsearchCheck.new,
  :critical
)

#
# Redis monitoring
#
Easymon::Repository.add(
  "redis",
  Easymon::RedisCheck.new(
    Workarea::Configuration::Redis.persistent.to_h
  ),
  :critical
)

#
# Sidekiq queue length monitoring
#
Easymon::Repository.add(
  'sidekiq-queue',
  Workarea::Monitoring::SidekiqQueueSizeCheck.new
)

#
# Load balancing monitoring
#
Easymon::Repository.add(
  'load-balancing',
  Workarea::Monitoring::LoadBalancingCheck.new
)
