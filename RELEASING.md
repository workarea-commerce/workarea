# Releasing

This is a short document to describe the process to release a new version of Workarea.

1. Switch the branch for the minor or major version you'd like to release, e.g. `v3.5-stable` to release the next v3.5.x patch.
2. Validate commits adhere to [commit message formatting](https://developer.workarea.com/articles/contribute-code.html#commit-messages). Most importantly that irrelevant commits contain `No changelog` in the body.
3. Check that there's a passing build. This is _critical_ since tests are part of the platform, and broken ones will break CI for implementations.
4. Bump the version in `core/lib/workarea/version.rb`, and commit the changes with a `No changelog` in the body.
5. Run `rake release` from root. To successfully run this you'll need two things:
    * The `BUNDLE_GEMS__WORKAREA__COM` env var set for gem pushes to the private gems server
    * [rubygems](https://rubygems.org) authentication configured, preferrably two-factor

That's all folks!
