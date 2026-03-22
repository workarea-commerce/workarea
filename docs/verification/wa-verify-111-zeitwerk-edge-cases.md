# WA-VERIFY-111 — Zeitwerk Edge Cases Across Decorators, Overrides, and Extension Points

## Summary

Audited the Workarea extension patterns most commonly used by downstream applications and plugins for Zeitwerk compatibility:

- Ruby decorators (`app/**/*.decorator`)
- test decorators (`test/**/*.decorator`)
- front-end overrides generated under app/view/layout/asset paths
- plugin extension hooks that load files outside normal autoload paths
- mailer preview loading

## Result

**Status: ✅ Compatible for the audited downstream extension patterns.**

No downstream client code changes are expected.

The audit did identify one **existing core-side autoload workaround** in `Workarea::Core::Engine`: two explicit `require` calls in `config.to_prepare` for constants that do not reliably autoload during boot/runtime in current dummy-app environments.

That workaround is already scoped to core boot behavior and does **not** change the documented downstream decorator/override patterns.

## Catalog of audited patterns

### 1. Ruby decorators

Relevant files:

- `core/lib/generators/workarea/decorator/decorator_generator.rb`
- `core/lib/generators/workarea/decorator/templates/decorator.rb.erb`

Observed pattern:

- Decorators are generated as `app/**/*.decorator`, not as Zeitwerk-managed `*.rb` constants.
- The generator resolves an existing source file first, then creates a parallel `.decorator` path.
- The decorator template uses `decorate <Constant>, with: :name do ... end`, which is an explicit decoration hook rather than implicit autoload discovery.

Zeitwerk assessment:

- **Compatible.** These files are not relying on Zeitwerk constant-to-file inference.
- Decoration is an explicit extension mechanism, so the `.decorator` suffix is not itself a Zeitwerk problem.

### 2. Test decorators

Relevant files:

- `testing/lib/workarea/test_case.rb`
- `core/lib/tasks/tests.rake`

Observed pattern:

- `Workarea::TestCase` derives the current test file path and looks for a same-path `test/**/*.decorator` file across installed plugins and the host app.
- Decorator files are loaded explicitly with `load` and tracked in `loaded_decorators` to avoid duplicate loads.
- The decorated test rake task enforces path parity between the original test and its decorator.

Zeitwerk assessment:

- **Compatible.** This path is explicit file loading, not autoloading.
- The same-path requirement avoids ambiguous constant/file resolution.

### 3. View/layout/asset overrides

Relevant files:

- `core/lib/generators/workarea/override/USAGE`

Observed pattern:

- Overrides are generated as application/plugin-owned copies of views, layouts, stylesheets, javascripts, images, fonts, etc.
- These are resolved by Rails view lookup / asset lookup, not by Zeitwerk constant loading.

Zeitwerk assessment:

- **Compatible.** These override patterns do not depend on Zeitwerk naming conventions.

### 4. Mailer previews and other file-based extension points

Relevant files:

- `core/config/initializers/19_mailer_previews.rb`

Observed pattern:

- Preview files are loaded from plugin roots and preview paths using `load` inside `config.to_prepare`.
- This is intentionally reload-friendly and independent from Zeitwerk autoloading.

Zeitwerk assessment:

- **Compatible.** The pattern is explicit and reload-aware.

### 5. Engine-managed autoload extensions

Relevant files:

- `core/lib/workarea/core/engine.rb`

Observed pattern:

- Core adds non-standard app directories to `config.autoload_paths`:
  - `app/queries`
  - `app/seeds`
  - `app/services`
  - `app/view_models`
  - `app/workers`
- These paths remain conventional from a Zeitwerk perspective when file names and constants match.

Zeitwerk assessment:

- **Compatible, with one notable exception below.**

## Notable core-side exception

`core/lib/workarea/core/engine.rb` currently includes:

```ruby
config.to_prepare do
  require 'workarea/bulk_index_products'
  require 'workarea/metrics/user'
end
```

The surrounding comments already document that these are needed because the constants do not reliably autoload in current runtime paths.

Assessment:

- This is **not a downstream decorator/override incompatibility**.
- It is an **existing core autoload edge case** that is already handled safely with explicit requires.
- No additional change was made here because removing the workaround would be speculative and could re-introduce runtime `NameError`s.

## Verification performed

### Repository audit

Searched the core engines and shared test support for:

- `.decorator` usage
- `config.to_prepare`
- `require_dependency`
- custom autoload/eager-load path additions
- preview loading and other explicit file-loading patterns

### Targeted command check

Attempted:

- `./scripts/verify-zeitwerk.sh`

Result:

- The script could not complete in this environment because Bundler rejected `workarea.gemspec` under the available Ruby/Bundler combination before Rails booted.
- Failure was environmental/tooling-related, not an application autoload failure:
  - `Illformed requirement [">= 2.7.0, < 3.5.0"]`

Because of that environment constraint, this verification was completed through targeted source audit rather than a fresh successful runtime Zeitwerk pass in this session.

## Conclusion

For the extension patterns downstream Workarea implementations commonly use:

- decorators are explicitly loaded and remain Zeitwerk-safe
- test decorators are explicitly loaded and path-validated
- front-end overrides are lookup-based, not autoload-based
- mailer preview loading is explicit and reload-safe

The only notable edge case found in the audited area is an **already-contained core workaround** for two constants that are explicitly required during `to_prepare`.

## Client impact

**None expected.**
