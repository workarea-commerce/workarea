---
title: Run Sidekiq in a Local Environment
created_at: 2018/08/08
excerpt: By default, Workarea applications are configured to run Sidekiq inline for local development. In some cases, however, it could be desirable to have an application run with Sidekiq processing jobs in the background to better match a live, production environment.
---

# Run Sidekiq in a Local Environment

By default, Workarea applications are configured to run Sidekiq inline for local development. In some cases, however, it could be desirable to have an application run with Sidekiq processing jobs in the background to better match a live, production environment.

To achieve this, there are number of steps that need to be taken to allow the development environment to function in this way. The first is modifying the environment configuration that is added for development by the Workarea app template. In `config/environments/development.rb`, you will see the line below

```ruby
# Run Sidekiq tasks synchronously so that Sidekiq is not required in Development
require 'sidekiq/testing/inline'
```

Remove this line or comment it out. This stops the application from running Sidekiq jobs inline during the execution of a web request. Without this line, the application will add jobs to redis for the Sidekiq process to find and process. To run sidekiq, you will need to open a terminal, navigate to your application's directory, and start the sidekiq process, exactly as you would start a web server for the application itself.

```bash
$ cd path/to/your/app
$ bundle exec sidekiq
```

When the command executes you will see a message that sidekiq has started. This window must remain open and running for sidekiq to continue to function. If you prefer, you can run sidekiq as a daemon with the `-d` or `--daemon` flag when starting the process.
