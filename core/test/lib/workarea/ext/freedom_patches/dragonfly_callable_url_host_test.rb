require 'test_helper'

module Workarea
  class DragonflyCallableUrlHostTest < TestCase
    def test_callable_url_host
      app = Dragonfly::App.instance(name)
      app.datastore = Dragonfly::MemoryDataStore.new
      app.secret = "test secret"
      uid = app.store('HELLO THERE')
      server = Dragonfly::Server.new(app)
      job = app.fetch(uid)
      server.url_format = '/media/:job'
      server.url_host = proc { |_| "https://#{SecureRandom.random_number}.example.com" }
      url = server.url_for(job)

      assert_includes(url, 'example.com')
      refute_includes(url, 'Proc')
    end
  end
end
