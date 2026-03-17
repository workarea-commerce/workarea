# Rails 7.2 appraisal notes (Workarea)

Primary tracking:

* Umbrella: https://github.com/workarea-commerce/workarea/issues/768
* **Current bundler blocker (canonical):** https://github.com/workarea-commerce/workarea/issues/841
  * Specific repro/details: https://github.com/workarea-commerce/workarea/issues/839
  * Also impacts security snapshots (Brakeman / bundler-audit): https://github.com/workarea-commerce/workarea/issues/840

## Summary

Rails 7.2 appraisal (`gemfiles/rails_7_2.gemfile`) currently **cannot bundle**.

This is **no longer** blocked by a Workarea Rails upper-bound constraint (e.g. `workarea-core` allows `rails < 7.3` as of current `next`).

**The active blocker is the Mongoid dependency line:** `workarea-core` depends on `mongoid ~> 7.4`, and Mongoid 7.x constrains `activemodel < 7.1`, which makes Rails 7.1/7.2 unsatisfiable.

## Repro

Rails 7.2 requires Ruby >= 3.1, and Workarea’s `.ruby-version` is currently **3.2.7**.

```sh
# Ensure you're using the repo Ruby (example uses rbenv)
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" && eval "$(rbenv init - zsh)"
rbenv shell 3.2.7

cd /path/to/workarea
BUNDLE_GEMFILE=gemfiles/rails_7_2.gemfile bundle install
```

## Bundler failure (key excerpt)

From #839:

```text
Because every version of workarea-core depends on mongoid ~> 7.4
  and mongoid >= 7.3.4, < 8.0.7 depends on activemodel >= 5.1, < 7.1, != 7.0.0,
  every version of workarea-core requires activemodel >= 5.1, < 7.1, != 7.0.0.
Thus, every version of workarea-core is incompatible with rails >= 7.2.0.
```

## Intended path forward

1. **Unblock bundling by upgrading Mongoid/ODM dependencies** to a version line compatible with Rails/ActiveModel 7.1 and 7.2.
   * Canonical issue: https://github.com/workarea-commerce/workarea/issues/841
2. Once Bundler resolves under `gemfiles/rails_7_2.gemfile`, run the test suite + verification tasks and triage failures.

## Known follow-up failures (after bundling is restored)

These issues are expected to be relevant once the appraisal can bundle/run in CI:

* Rack::Cache constant load error in integration test: https://github.com/workarea-commerce/workarea/issues/787
* Catalog slug caching test failure (Rails 7.2 / Mongoid 8): https://github.com/workarea-commerce/workarea/issues/788
* User password reuse validation test failure (Rails 7.2 / Mongoid 8): https://github.com/workarea-commerce/workarea/issues/789

## Rails 7.2 upstream references

* https://edgeguides.rubyonrails.org/7_2_release_notes.html
* https://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-1-to-rails-7-2
