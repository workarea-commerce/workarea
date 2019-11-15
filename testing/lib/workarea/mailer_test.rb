module Workarea
  class MailerTest < ActionMailer::TestCase
    extend TestCase::Decoration
    extend TestCase::RunnerLocation
    include TestCase::Setup
    include TestCase::Teardown
    include TestCase::Configuration
    include Factories
    include TestCase::Workers
    include TestCase::RunnerLocation
    include TestCase::Locales
    include TestCase::S3
    include TestCase::Encryption
    include TestCase::SearchIndexing
    include TestCase::Mail
  end
end
