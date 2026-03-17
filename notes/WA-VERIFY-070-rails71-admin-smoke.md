# WA-VERIFY-070 — Rails 7.1 admin smoke test (Issue #1034)

Date: 2026-03-17

## Goal
Smoke-test core admin views under the Rails 7.1 appraisal by:

```sh
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rails runner 'puts Rails.version'
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rake test TEST=admin/test/integration
```

## Result
Blocked at Bundler resolution for the Rails 7.1 appraisal.

### What fails
```sh
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle install
```

### Error (dependency resolution)
Bundler reports that Workarea (via `workarea-core`) depends on `mongoid ~> 7.4`, and all Mongoid versions `< 8.0.7` constrain `activemodel` to `< 7.1`, which conflicts with Rails 7.1.x:

```
Because every version of workarea-core depends on mongoid ~> 7.4
  and mongoid >= 7.3.4, < 8.0.7 depends on activemodel >= 5.1, < 7.1, != 7.0.0,
  every version of workarea-core requires activemodel >= 5.1, < 7.1, != 7.0.0.
And because rails >= 7.1.5.1, < 7.1.5.2 depends on activemodel = 7.1.5.1,
every version of workarea-core is incompatible with rails >= 7.1.5.1, <
7.1.5.2.
So, because rails_7_1.gemfile depends on workarea-core >= 0
  and rails_7_1.gemfile depends on rails = 7.1.5.1,
  version solving has failed.
```

## Conclusion
- App boot + admin integration test execution could not be performed under Rails 7.1 because the appraisal Gemfile currently does not resolve.
- Follow-up work is required to add Mongoid 8+ support (and adjust related Mongoid adapter gem constraints) before Rails 7.1 appraisals can run.

Client impact: None (verification only).
