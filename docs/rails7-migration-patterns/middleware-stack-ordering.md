# Middleware Stack / Ordering Changes (Rails 7.x)

**Pattern:** `ActionDispatch::HostAuthorization` inserted before session/cookie middleware

## Symptom

After upgrading to Rails 7.0+, requests to your Workarea storefront or admin
return **`403 Blocked host`** errors — even in development — before any
Workarea controller code runs.  Sessions appear blank and cookies are not set
on these blocked requests.

Sample log line:

```
ActionDispatch::HostAuthorization::DefaultResponseApp - Blocked host: mystore.example.com
```

Clients who rely on middleware ordering assumptions (e.g. custom Rack middleware
inserted `before: 'ActionDispatch::Session::CookieStore'`) may also see their
middleware position silently shift, because `HostAuthorization` is now earlier in
the stack.

## Root cause

Rails 7.0 added `ActionDispatch::HostAuthorization` and placed it **near the top
of the default middleware stack** — before `ActionDispatch::Session::CookieStore`
and before most application middleware.

In Rails 6.x the middleware stack order (simplified) was:

```
ActionDispatch::RequestId
ActionDispatch::RemoteIp
ActionDispatch::SSL (if forced)
ActionDispatch::Static
ActionDispatch::Executor
... (session, cookies, flash)
... (app middleware)
```

In Rails 7.0+ `HostAuthorization` is inserted early:

```
ActionDispatch::HostAuthorization   # ← NEW, position ~3
ActionDispatch::RequestId
ActionDispatch::RemoteIp
...
ActionDispatch::Session::CookieStore
```

Because Workarea does **not** configure `config.hosts` by default, any host is
allowed in development, but in production (or when `config.hosts` is non-empty)
this middleware can reject legitimate requests before Workarea's own middleware or
router is consulted.

## Detection

**1. Print the middleware stack:**

```sh
bin/rails middleware | grep -n HostAuthorization
```

If `ActionDispatch::HostAuthorization` appears, check its position relative to
`ActionDispatch::Session::CookieStore`.

**2. Check `config.hosts`:**

```sh
grep -r "config\.hosts" config/
```

An empty array (`config.hosts = []`) disables the check.  A non-empty array
(or the Rails 7 default in production, which includes `IPAddr` ranges and the
`DATABASE_URL` host) can cause unexpected blocks.

**3. Reproduce in development:**

```sh
curl -H "Host: untrusted.example.com" http://localhost:3000/
# Should return 403 if HostAuthorization is active for that host
```

## Fix

### Option A — Allow all hosts (development / legacy compatibility)

In `config/environments/development.rb` (and optionally `test.rb`):

```ruby
# Allow all hosts — equivalent to Rails 6 behaviour
config.hosts.clear
```

Or globally in `config/application.rb` if you manage host trust at the load
balancer/CDN:

```ruby
config.hosts = []   # disables HostAuthorization entirely
```

### Option B — Explicitly allow your hosts (recommended for production)

```ruby
# config/application.rb  (or per-environment file)
config.hosts << "mystore.example.com"
config.hosts << /.*\.mystore\.example\.com/   # wildcard subdomain
```

### Option C — Re-pin custom Workarea middleware relative to the new stack position

If a Workarea plugin or host app inserts middleware with a position relative to
`Session::CookieStore`, audit and update the insertion point:

```ruby
# Before (Rails 6 assumption)
config.middleware.insert_before "ActionDispatch::Session::CookieStore", MyMiddleware

# After (Rails 7 — still valid, but verify HostAuthorization is not blocking first)
config.middleware.insert_before "ActionDispatch::Session::CookieStore", MyMiddleware
```

No positional change is required for `insert_before Session::CookieStore`; the
fix is ensuring `HostAuthorization` does not block the request before it reaches
your middleware.

## Workarea PR / Issue

- Related issue: **WA-DOC-014** (this document)
- Upstream Rails change: [`ActionDispatch::HostAuthorization` — Rails PR #33145](https://github.com/rails/rails/pull/33145)

## Lint rule (pseudocode)

```
# Rule: workarea/rails7/host_authorization_config
#
# Trigger: upgrading to Rails 7.0+ (Gemfile rails version bump)
# Check:   config.hosts is not configured anywhere in config/
# Warn:    "Rails 7 added ActionDispatch::HostAuthorization.
#           In production, unexpected hosts will receive 403.
#           Add `config.hosts = []` to opt out, or explicitly list
#           allowed hosts in config/environments/production.rb."
#
# Pseudo-AST check:
#   for each file in config/**/*.rb:
#     if rails_version >= 7.0 AND
#        not contains_node?(type: :send, method: "hosts=") AND
#        not contains_node?(type: :send, method: "hosts", receiver: "config", args: [op: :<<]):
#       warn(rule_id: "WA-MW-001", severity: :warning, file: file)
```
