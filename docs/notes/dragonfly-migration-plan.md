# WA-PERF-001 — Replace Dragonfly with ActiveStorage or direct libvips

> Issue: workarea-commerce/workarea#703

This document inventories how Workarea currently uses Dragonfly and proposes a migration path to remove it.

## 1) Current Dragonfly usage inventory

### Gems / runtime components

- `dragonfly ~> 1.4`
- `dragonfly-s3_data_store ~> 1.3`
- `dragonfly_libvips ~> 2.4` (optional, based on `vips -v`)
- `image_optim` + `image_optim_pack` (used by `Workarea::ImageOptimProcessor` processor)
- `fastimage` (used for type detection and some logic around JPEG)

### Initialization (`core/config/initializers/07_dragonfly.rb`)

**Plugins**
- Chooses image backend:
  - `plugin :libvips` when `Workarea::Configuration::ImageProcessing.libvips?`
  - else `plugin :imagemagick`
- When using libvips, Workarea still requires ImageMagick command wrapper for `.ico` conversion:
  - `require 'dragonfly/image_magick/commands'`

**Security / signing**
- `verify_urls true`
- `secret Workarea::Configuration::AppSecrets[:dragonfly_secret].presence || Rails.application.secret_key_base`

**URL format / serving**
- `url_format '/media/:job/:name'`
- `response_header 'Cache-Control'` is customized:
  - sitemap paths: `public, max-age=86400`
  - everything else: `public, max-age=31536000`

**Custom processor**
- `processor :optim, Workarea::ImageOptimProcessor`

**Encode whitelist extension (CVE-2021-33564 mitigation)**
- Workarea extends Dragonfly’s ImageMagick `encode` whitelist:
  - `Dragonfly::ImageMagick::Processors::Encode::WHITELISTED_ARGS.concat(%w[interlace set])`

**Additional processors defined (only if not already defined)**
- Admin:
  - `:avatar` (encode jpg + thumb 80x80 + optim)
  - `:small` (encode jpg + thumb 55x + optim) (skips SVG)
  - `:medium` (encode jpg + thumb 240x + optim) (skips SVG)
- Storefront:
  - analyser `:inverse_aspect_ratio`
  - `:small_thumb` (60x)
  - `:medium_thumb` (120x)
  - `:large_thumb` (220x)
  - `:detail` (400x)
  - `:zoom` (670x)
  - `:super_zoom` (1600x)
  - `:favicon` (special center-crop behavior differs by backend)
  - `:favicon_ico` (ImageMagick convert command)

### Configuration (`core/lib/workarea/configuration/dragonfly.rb`)

- Storage backend is derived from `Workarea.config.asset_store`:
  - `:s3` (when configured + bucket present)
    - default options include region, bucket, credentials, `use_iam_profile` and `storage_headers: { 'x-amz-acl' => 'private' }`
  - `:file` / `:file_system` coerced to `:file` with:
    - `root_path: public/system/workarea/<env>`
    - `server_root: public`
- Enforces CDN/asset host:
  - `url_host Rails.application.config.action_controller.asset_host`

### Image processing configuration (`core/lib/workarea/configuration/image_processing.rb`)

- Decides libvips support by checking `vips -v` for `vips-8*`.
- Loads `dragonfly_libvips` when available.

### Model attachment usage

Dragonfly is used via `extend Dragonfly::Model` + `dragonfly_accessor`.

**Primary consumer: `Workarea::Content::Asset`** (`core/app/models/workarea/content/asset.rb`)
- Fields mirror Dragonfly “magic attributes” populated by analysers:
  - `file_name`, `file_uid`, `file_width`, `file_height`, `file_aspect_ratio`, `file_portrait`, `file_landscape`, `file_format`, `file_image`, `file_inverse_aspect_ratio`
- Attachment:
  - `dragonfly_accessor :file, app: :workarea`
  - `after_assign` hook: if JPEG (`FastImage.type(...) == :jpeg`) then `file.encode!('jpg', Workarea.config.jpg_encode_options)`
- Delegates unknown methods to `file` attachment (`method_missing` + `respond_to_missing?`), so downstream code often calls Dragonfly attachment APIs directly.

**Other models using Dragonfly**
- `Workarea::Catalog::ProductImage` (embedded) — `dragonfly_accessor :image`
- `Workarea::Catalog::ProductPlaceholderImage` — `dragonfly_accessor :image`
- `Workarea::User::Avatar` concern — `dragonfly_accessor :avatar`, uses `avatar.process(:avatar).url`
- `Workarea::Sitemap` — `dragonfly_accessor :file`
- `Workarea::Help::Article` — `dragonfly_accessor :thumbnail`
- `Workarea::Help::Asset` — `dragonfly_accessor :file`
- `Workarea::Reports::Export` — `dragonfly_accessor :file` (CSV generated to tmp then assigned)
- `Workarea::DataFile::Operation` concern — `dragonfly_accessor :file`
- `Workarea::Fulfillment::Sku` — `dragonfly_accessor :file`

**Data import/export integration** (`core/app/models/workarea/data_file/csv.rb`)
- Special-cases Dragonfly models when importing CSV:
  - checks `model.class.is_a?(Dragonfly::Model)`
  - iterates `model.dragonfly_attachments`
  - assigns `*_uid`, `*_name`, etc. fields from CSV
  - calls `attachment.save!` to persist attachment even when embedded

### Serving / routing

- `core/config/routes.rb`
  - Dynamic product images served by `Dragonfly.app(:workarea).endpoint` calling:
    - `AssetEndpoints::ProductImages#result`
    - `AssetEndpoints::ProductPlaceholderImages#result`
- `storefront/config/routes.rb`
  - Favicon(s) served by Dragonfly endpoint calling `Workarea::AssetEndpoints::Favicons`
  - Sitemaps served by Dragonfly endpoint calling `Workarea::AssetEndpoints::Sitemaps`

### Freedom patches (core/lib/workarea/ext/freedom_patches/*)

- `dragonfly_attachment.rb`
  - Prepends module to disable datastore destroy (original content not deleted).
- `dragonfly_callable_url_host.rb`
  - Allows `url_host` to be callable (depends on rack request).
- `dragonfly_job_fetch_url.rb`
  - Overrides `Dragonfly::Job::FetchUrl#get` to respect `HTTP(S)_PROXY` and supports basic auth.

## 2) ActiveStorage vs direct libvips (for Workarea)

### Constraints unique to Workarea

- Workarea uses **Mongoid** (not ActiveRecord) for most application models.
- Dragonfly provides:
  - attachment macros for non-AR models (`Dragonfly::Model`)
  - a signed URL/job format and an endpoint/middleware
  - “magic attributes” analyzers stored on the document
  - on-the-fly processing (`thumb`, `encode`, custom processors)
  - flexible datastore support (S3 + filesystem)

These features do not map 1:1 to ActiveStorage without additional glue.

### Option A — ActiveStorage

**Pros**
- Rails standard, long-term maintained.
- Well-supported for S3 + variants + CDN.
- Integrates with `image_processing` and libvips.
- Better ecosystem (direct uploads, analyzers, mirror, etc.).

**Cons / risks for Workarea**
- ActiveStorage models (`active_storage_blobs`, `active_storage_attachments`) require **ActiveRecord tables**.
- Attaching to **Mongoid documents** is not first-class. You either:
  1) Introduce AR just for ActiveStorage tables, and create custom attachment glue for Mongoid, or
  2) Adopt a third-party bridge gem (adds maintenance risk).
- Existing Workarea code depends heavily on Dragonfly API (e.g. `asset.optim.url`, `avatar.process(:avatar).url`).
- Existing URL format `/media/:job/:name` and signed job semantics are Dragonfly-specific.

### Option B — direct libvips (custom storage + processing)

**Pros**
- Keeps Workarea “Mongoid-first”; no AR dependency required.
- Control over URL format, caching, and backward-compat endpoints.
- Can store metadata on Mongoid documents exactly like today.
- Can be built to preserve existing API shape (`#url`, `#process`, `#thumb`-like methods) while removing Dragonfly.

**Cons / risks**
- Workarea becomes responsible for storage + variant caching + security/signed URLs.
- Re-implementing 80% of Dragonfly may be more work than adopting ActiveStorage.
- Must handle streaming, Range requests, content-type, cache headers, and CDN behavior.

## 3) Recommendation

**Recommended approach: phased migration to a Workarea-owned “Media” abstraction implemented on top of libvips + S3/filesystem**, with an eventual option to switch the underlying store to ActiveStorage if Workarea later adopts AR.

Rationale:
- Immediate removal of Dragonfly without forcing an AR schema into a Mongoid app.
- Lets Workarea preserve API compatibility (or at least provide a compatibility shim) while swapping the backend.
- Supports incremental rollout model-by-model (start with `Content::Asset`).

## 4) Backward compatibility strategy

### Public URLs

- Keep existing Dragonfly-generated URLs working for a deprecation window:
  - Leave Dragonfly mounted/available while new attachments generate new URLs.
  - Add a compatibility endpoint (or router) that can serve both old `/media/:job/:name` (Dragonfly) and new media URLs.
- Provide an opt-in config switch to generate only new URLs once production confirms parity.

### Processor ecosystem

Downstream users may have:
- custom Dragonfly processors defined in initializers
- code that calls Dragonfly attachment APIs (`process`, `thumb`, `encode`, custom processors)

Plan:
1) Introduce a small compatibility wrapper (e.g. `Workarea::Media::Attachment`) that implements:
   - `#url`, `#process(name, *args)`, `#thumb(geometry, options)`, `#encode(format, options)`, and known processors (`optim`, `small`, `medium`, etc.).
2) Provide a mapping layer:
   - for Workarea-shipped processors, implement equivalents using libvips / image_optim.
   - for unknown processors, allow a hook system (e.g. `Workarea.config.media_processors[name] = ->(io, *args) { ... }`).
3) Deprecate custom Dragonfly processors over time and document replacements.

### Data import/export

- `Workarea::DataFile::Csv` currently assumes `Dragonfly::Model` and `dragonfly_attachments`.
- Migration needs a new abstraction:
  - `Workarea::Media::Model` (or similar) exposing `media_attachments` and `*_uid` / `*_name` attributes.

## 5) Migration phases / timeline (suggested)

### Phase 0 — groundwork (1–2 weeks)
- Add Workarea media abstraction (storage + URL generation + controller endpoint).
- Add signed URL helper (or rely on private S3 + expiring presigned URLs).
- Implement libvips variants for required sizes.

### Phase 1 — migrate `Content::Asset` (1–2 weeks)
- New backend behind feature flag.
- Implement `optim` path for images.
- Ensure admin upload and direct upload service still work.
- Add a data migration task to copy existing Dragonfly originals into new storage (optional early).

### Phase 2 — migrate “simple file” models (1–2 weeks)
- `Help::Asset`, `Reports::Export`, `DataFile::Operation`, `Sitemap`, `Fulfillment::Sku`

### Phase 3 — migrate product image pipeline (2–4 weeks)
- `Catalog::ProductImage` + placeholder, plus endpoints in routes.
- Validate CDN caching behavior and performance.

### Phase 4 — migrate avatar + favicon/sitemaps (1–2 weeks)
- Requires matching custom processors and special `.ico` conversion.

### Phase 5 — remove Dragonfly (after deprecation window)
- Remove freedom patches, processors, and gem dependencies.

## 6) Risk assessment

- **Mongoid + ActiveStorage mismatch** is the main risk if choosing ActiveStorage.
- **URL compatibility**: existing pages/emails may embed Dragonfly URLs; breaking them is costly.
- **Processing parity**: small differences in crop/resize/encode can affect storefront imagery.
- **Operational**: S3 permissions/ACLs, cache headers, CDN invalidation, and presigned URL lifetimes.
- **Performance**: on-the-fly processing must be cached; otherwise CPU load can spike.

---

## Appendix: current code touchpoints

- `ContentAssetsHelper#url_to_content_asset` expects:
  - images: `asset.optim.url`
  - non-images: `asset.url`
- `User::Avatar#avatar_image_url` expects `avatar.process(:avatar).url`
- Storefront/core routes use `Dragonfly.app(:workarea).endpoint` for product images, favicon(s), and sitemaps.
