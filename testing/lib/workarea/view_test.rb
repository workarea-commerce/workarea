# This fix allows us to default locale to nil so routes in helper tests can be
# generated as expected. This is unbelievably shitty and makes me really sad.
# Details on this can be found here: https://github.com/rspec/rspec-rails/issues/255
#

class ActionView::TestCase::TestController
  def default_url_options(options = {})
    if options.key?(:locale) || options.key?('locale')
      options
    else
      { locale: nil }.merge(options)
    end
  end
end

module Workarea
  class ViewTest < ActionView::TestCase
    extend TestCase::Decoration
    include TestCase::RunnerLocation
    include Factories
    include TestCase::Workers
    include TestCase::Locales

    setup do
      Mongoid.truncate!
      Workarea.redis.flushdb
      WebMock.disable_net_connect!(allow_localhost: true)
      Workarea.config.send_email = false
      ActionMailer::Base.deliveries.clear

      Sidekiq::Testing.inline!
      Sidekiq::Callbacks.inline
      Sidekiq::Callbacks.disable
    end

    teardown do
      travel_back
    end
  end
end
