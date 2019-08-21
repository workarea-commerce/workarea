module Workarea
  class UpdateElasticsearchSettings
    include Sidekiq::Worker
    sidekiq_options queue: 'high'

    def perform(settings)
      Elasticsearch::Document.all.each do |klass|
        klass.current_index.wait_for_health # For initial setup

        klass.current_index.while_closed do
          # number_of_shards cannot be updated, ES will return
          # a 400 error
          Workarea.elasticsearch.indices.put_settings(
            index: klass.current_index.name,
            body: {
              settings: settings.except(
                'number_of_shards',
                'number_of_replicas'
              )
            }
          )
        end

        klass.current_index.wait_for_health # For running inline (e.g. tests)
      end
    end
  end
end
