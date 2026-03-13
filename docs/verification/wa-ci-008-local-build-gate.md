# WA-CI-008 — Local build gate (quick pre-PR checks)

Keep this short: it’s the same set of checks CI will run, but optimized for running **locally** before opening / updating a PR.

## 1) Ensure required services are running (Docker)

Workarea tests and boot rely on **MongoDB**, **Redis**, and **Elasticsearch**.

### Recommended startup command

From the repo root, run:

```bash
docker compose up -d

docker compose ps
```

If you need to override the default service versions and/or ports, you can set the
env vars used by `docker-compose.yml`:

```bash
MONGODB_VERSION=4.0 \
REDIS_VERSION=6.2 \
ELASTICSEARCH_VERSION=6.8.23 \
docker compose up -d
```

You should see **mongo**, **redis**, and **elasticsearch** in a running/healthy state.

### Troubleshooting

- If services don’t start, first confirm Docker is running. If you’re overriding defaults, double-check the env vars above (or use the one-liner).
- If you need a clean restart:

  ```bash
  docker compose down
  docker compose up -d
  ```

- If MongoDB fails to start due to a data directory/volume incompatibility (common when reusing old Docker volumes from a different Mongo major version), the safe workaround is:

  ```bash
  # removes named volumes used by the compose file
  docker compose down -v
  ```

  Then start again. If you need to preserve old data, run MongoDB **4.2** against the volume long enough to migrate/backup it.

## 2) RuboCop (diff-only vs base `next`)

Run RuboCop only on Ruby files changed compared to `origin/next`.

```bash
# make sure you have an up-to-date next
git fetch origin next

# Ruby files changed on your branch vs origin/next
files=$(git diff --name-only --diff-filter=ACMRT origin/next...HEAD -- '*.rb')

# run rubocop only if any Ruby files changed
if [ -n "$files" ]; then
  bundle exec rubocop $files
else
  echo "No Ruby (.rb) changes vs origin/next"
fi
```

Notes:
- This repo’s Bundler/Ruby version constraints may require a newer Ruby locally. Use whatever Ruby version the project currently targets.

## 3) Run the right engine test suites based on what you touched

Workarea is split into engines. CI will exercise the engines affected by your change. Locally, run the suite(s) that match the paths you changed.

### Common mapping (paths → test task)

- Changes under `core/` → run **core** tests
  ```bash
  bin/rails workarea:test:core
  ```

- Changes under `admin/` → run **admin** tests
  ```bash
  bin/rails workarea:test:admin
  ```

- Changes under `storefront/` → run **storefront** tests
  ```bash
  bin/rails workarea:test:storefront
  ```

- Changes under `testing/` → run **testing** tests
  ```bash
  bin/rails workarea:test:testing
  ```

If you’re not sure (or you touched multiple engines), run the combined suite:

```bash
bin/rails workarea:test
```

### Helpful: auto-detect which suites to run

This is a simple heuristic based on changed paths:

```bash
git fetch origin next
changed=$(git diff --name-only --diff-filter=ACMRT origin/next...HEAD)

run() { echo "\n==> $*"; "$@"; }

if echo "$changed" | rg -q '^core/'; then run bin/rails workarea:test:core; fi
if echo "$changed" | rg -q '^admin/'; then run bin/rails workarea:test:admin; fi
if echo "$changed" | rg -q '^storefront/'; then run bin/rails workarea:test:storefront; fi
if echo "$changed" | rg -q '^testing/'; then run bin/rails workarea:test:testing; fi
```

(Requires `rg`/ripgrep installed. If not, replace with `grep -E`.)

---

Related docs:
- `docker-compose.yml` (service definitions)
- `core/lib/tasks/tests.rake` (available `workarea:test:*` tasks)
