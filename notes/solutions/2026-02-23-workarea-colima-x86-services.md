# workarea-colima-x86-services
**Date:** 2026-02-23

## Problem
Workarea dev/test depends on Elasticsearch 5 + Redis 5 + MongoDB 4 containers, which are amd64 images. On Apple Silicon using Colima's default aarch64 VM, these images can fail (Elasticsearch crashes; Redis can choke on stale RDB format). Colima context/volume drift created recurring setup failures.

## What changed
- Standardized Workarea services to run under docker context **`colima-x86`**.
- Added `bin/workarea-services-up` to start `colima x86`, switch docker context, start services, and health-check ES/Redis.
- Added `bin/workarea-services-reset` to safely delete only Workarea service containers/volumes with guardrails.

## Why this approach
- Keeps amd64 images running in an x86_64 VM (more reliable than emulation-on-arm VM).
- Encodes the "right incantations" in scripts so setup is repeatable.
- Reset script is designed to be hard to misuse (context + socket + env guards; no prune).

## Verification
- `bin/workarea-services-up`
- `curl -s localhost:9200 | head`
- `docker exec -it workarea-redis-1 redis-cli ping`

## Gotchas / lessons
- Do **not** run Workarea services in the default colima (aarch64) profile on Apple Silicon.
- Keep destructive cleanup limited to explicit `workarea_*` resources and only in `colima-x86`.
