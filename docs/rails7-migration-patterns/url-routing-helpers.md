# URL/routing helper behavior changes

`default_url_options` no longer applied in non-controller contexts (Background Jobs, Mailers, Console)

## Symptom
In Rails 7, `default_url_options` set in ApplicationController is not automatically applied when generating URLs in background jobs (Active Job), mailers, or the console. This causes `ActionController::UrlGenerationError` or missing host errors when apps rely on controller-level `default_url_options`.

## Root cause
Rails 7 changed this behavior so `default_url_options` set in ApplicationController is not automatically applied in non-controller contexts.

## Detection
How to find if you're affected:
```bash
grep -r "default_url_options" app/controllers
grep -r "_url" app/jobs app/mailers
```

## Fix
To resolve it, set `default_url_options` in `config/application.rb` or `config/routes.rb`, or use `Rails.application.routes.default_url_options`.

## References / Links

- [Issue #903](https://github.com/workarea-commerce/workarea/issues/903)
- [Rails 7.0 Release Notes — Routing](https://edgeguides.rubyonrails.org/7_0_release_notes.html)
- [Rails API: `default_url_options`](https://api.rubyonrails.org/classes/ActionDispatch/Routing/RouteSet.html)

## Lint rule pseudocode
```ruby
# Pseudocode check for controller-level default_url_options
if File.read('app/controllers/application_controller.rb').include?('default_url_options')
  puts "Warning: default_url_options found in ApplicationController. Move to config/application.rb or routes.rb for non-controller contexts."
end
```