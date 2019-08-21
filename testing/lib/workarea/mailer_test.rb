module Workarea
  class MailerTest < ActionMailer::TestCase
    extend TestCase::Decoration
    extend TestCase::RunnerLocation
    include TestCase::Configuration
    include Factories
    include TestCase::Workers
    include TestCase::RunnerLocation
    include TestCase::Locales
    include TestCase::S3
    include TestCase::Encryption
    include TestCase::SearchIndexing
    include TestCase::Mail

    setup do
      Mongoid.truncate!
      Workarea.redis.flushdb
      WebMock.disable_net_connect!(allow_localhost: true)
    end

    teardown :travel_back
  end
end
