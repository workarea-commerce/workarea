# WA-VERIFY-112 — Verify ActiveRecord attribute API assumptions in Rails 7.1 migration paths

Closes #1136

## Scope

This audit looked for places where Workarea might accidentally assume **ActiveRecord attribute internals** while operating across mixed persistence boundaries (primarily Mongoid documents, serialized objects, and integration/view-model rebuild paths).

The concern for Rails 7.1 is whether code paths rely on ActiveRecord-specific attribute internals or pre-7.1 behavior that would break once downstream apps upgrade Rails while still running Workarea’s Mongoid-heavy core.

## Search summary

Repository searches covered:

- `read_attribute` / `write_attribute`
- `attribute_before_type_cast` / `attributes_before_type_cast`
- `attribute_types` / `type_for_attribute` / `column_for_attribute`
- direct `attributes[...]` mutation
- `serializable_hash` / `as_json` / `as_document`
- `instantiate(...)` / `Mongoid::Factory.from_db(...)`
- docs references to Rails 7.1 and ActiveRecord behavior

## Relevant touchpoints reviewed

### 1) Mongoid-backed model attribute access

These uses remain within Mongoid/ActiveModel-supported APIs and do **not** depend on ActiveRecord’s internal attribute objects:

- `core/app/models/workarea/content.rb`
  - `read_attribute(:name)`
- `core/app/models/workarea/inventory/capture.rb`
  - `read_attribute(:sellable)`
- `core/app/models/workarea/search/customization.rb`
  - `read_attribute(:redirect)`
- `core/app/models/workarea/data_file/import.rb`
  - `read_attribute(:file_type)`

### 2) Release changeset replay / dirty tracking

`core/app/models/workarea/release/changeset.rb` replays persisted changes with:

- `model.send(:attribute_will_change!, field)`
- `model.attributes[field] = ...`
- `releasable_from_document_path.attributes[key]`

This path operates on **Mongoid documents**, not ActiveRecord models. The API surface used here is still available through ActiveModel dirty tracking and Mongoid attribute hashes. No Rails 7.1-specific ActiveRecord attribute object assumptions were found.

### 3) Serialization / rehydration boundaries

The mixed persistence/integration boundaries that were most likely to expose AR-attribute assumptions already use document/hash serialization rather than ActiveRecord internals:

- `core/lib/workarea/elasticsearch/serializer.rb`
  - Mongoid models serialize via `as_document`
  - deserialize via `klass.instantiate(...)`
  - explicitly avoids `Mongoid::Factory.from_db`
- `storefront/app/view_models/workarea/storefront/order_item_view_model.rb`
- `admin/app/view_models/workarea/admin/order_item_view_model.rb`
  - use `Mongoid::Factory.from_db(...)` with document hashes
- `core/app/models/workarea/content/block.rb`
- `core/app/models/workarea/content/block_draft.rb`
- `core/app/models/workarea/pricing/request.rb`
  - clone/save flows operate on `as_document` payloads and plain hashes

These paths do not reach into `ActiveRecord::AttributeSet`, `attribute_types`, `attributes_before_type_cast`, or similar Rails 7.1-sensitive APIs.

### 4) Docs / migration guidance

No Rails 7.1 migration document in this repo currently instructs downstream apps to depend on ActiveRecord attribute internals for Workarea-managed code paths.

## Findings

### Result: **no Rails 7.1 ActiveRecord attribute API incompatibility found**

I did **not** find any Workarea core/admin/storefront code path that:

- assumes ActiveRecord’s internal attribute container structure,
- depends on pre-7.1 ActiveRecord dirty-tracking internals,
- mixes Mongoid documents with ActiveRecord-only attribute APIs at runtime, or
- requires downstream clients to change attribute-access code as part of a Rails 7.1 upgrade.

The reviewed touchpoints use either:

- Mongoid’s document/hash APIs (`as_document`, `instantiate`, `attributes`), or
- ActiveModel-compatible attribute/dirty APIs (`read_attribute`, `attribute_will_change!`).

Those are compatible with the Rails 7.1 migration concern being audited here.

## Verification notes

Targeted existing tests identified for the reviewed areas:

- `core/test/models/workarea/content_test.rb`
- `core/test/models/workarea/release/changeset_test.rb`
- `core/test/elasticsearch/workarea/elasticsearch/serializer_test.rb`

Attempting to run them in this checkout is currently blocked before test boot by an existing Bundler/gemspec parsing issue:

- `workarea.gemspec`: `s.required_ruby_version = '>= 2.7.0, < 3.5.0'`

On this machine/toolchain, Bundler fails while parsing that combined requirement string, so the verification for this issue is based on code audit plus existing test coverage review rather than a green local test execution.

## Recommendation

No code change is recommended for WA-VERIFY-112.

If a future Rails upgrade introduces a real regression here, the highest-risk areas to re-check first are:

1. `Release::Changeset` replay/dirtiness behavior,
2. serializer rehydration boundaries using `instantiate` / `from_db`,
3. clone/save flows in `Pricing::Request` that round-trip document hashes.
