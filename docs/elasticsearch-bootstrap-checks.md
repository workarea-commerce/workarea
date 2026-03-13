# Elasticsearch — bootstrap-check failure ("looks up but unusable")

**Issue:** WA-DOC-023

Elasticsearch's container may appear to start (Docker shows it as `Up`)
but be completely unusable — returning an empty reply or refusing connections.
This is a distinct failure mode from a port conflict or a missing container.

---

## Symptom

```bash
curl http://127.0.0.1:9200/
# curl: (52) Empty reply from server
# — or —
# curl: (7) Failed to connect to 127.0.0.1 port 9200: Connection refused
```

The container is **running** (`docker compose ps` shows `Up`) but `curl`
gets nothing back, or the Rails app raises
`Elasticsearch::Transport::Transport::Errors::ServiceUnavailable`.

---

## Confirm the cause

Check the container logs immediately after startup:

```bash
docker compose logs elasticsearch
# or, to follow live:
docker logs --follow workarea_elasticsearch_1
```

Look for lines like:

```
[1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
[2]: system call filters failed to install; check the logs and fix your configuration or disable system call filters at your own risk
...
ERROR: bootstrap checks failed
```

If you see `bootstrap checks failed`, the fix below applies.

---

## Recommended fix

### Option A — set `vm.max_map_count` on the host (Linux)

This is the correct, permanent fix on Linux hosts (including WSL 2):

```bash
# apply immediately (resets on reboot)
sudo sysctl -w vm.max_map_count=262144

# make it permanent
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

Then restart the Elasticsearch container:

```bash
docker compose restart elasticsearch
curl http://127.0.0.1:9200/
```

### Option B — disable bootstrap checks via `ES_JAVA_OPTS` (dev only)

For local development only, you can tell Elasticsearch to skip bootstrap
checks by setting the single-node discovery type.  
Set `ELASTICSEARCH_SINGLE_NODE=true` in your `.env` (or export it), then
add the following override to a `docker-compose.override.yml` in the repo
root:

```yaml
# docker-compose.override.yml  (not committed; add to .gitignore if needed)
services:
  elasticsearch:
    environment:
      - discovery.type=single-node
```

Restart the service:

```bash
docker compose up -d elasticsearch
curl http://127.0.0.1:9200/
```

> **Do not use `discovery.type=single-node` in production.** It disables
> important cluster checks.

---

## Docker compose reference

The repo's `docker-compose.yml` defines the `elasticsearch` service.
Environment variable overrides (version, port) are documented in the
[README — Docker Compose Services](../README.md#docker-compose-services).

For port-conflict or stale-container issues (a separate symptom), see the
[Troubleshooting: port conflicts / stale containers](../README.md#troubleshooting-port-conflicts--stale-containers)
section of the README.

For general pre-PR service checks, see
[`docs/verification/wa-ci-008-local-build-gate.md`](verification/wa-ci-008-local-build-gate.md).
