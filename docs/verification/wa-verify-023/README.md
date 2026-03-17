# WA-VERIFY-023 — `rails app:update` config diff snapshots (Rails 7.1 / 7.2)

Issue: https://github.com/workarea-commerce/workarea/issues/837

## Why this exists

Rails upgrades often require subtle config changes (initializers, defaults, middleware, etc.).
This directory captures reproducible `rails app:update`-driven diffs for upgrading a *minimal* Rails app from **Rails 7.0.10** to:

- **Rails 7.1.5.1** (pinned in Workarea’s `gemfiles/rails_7_1.gemfile`)
- **Rails 7.2.3** (latest 7.2.x at time of capture)

These snapshots are meant to be reviewed and selectively applied (or turned into follow-up issues) for Workarea and downstream apps.

## Files

- `rails-7.1.5.1_app-update-from-7.0.10.diff`
- `rails-7.2.3_app-update-from-7.0.10.diff`

Each diff is the output of `git diff` after:
1) generating a fresh Rails 7.0.10 app
2) upgrading the Rails gem version (and Puma to avoid Rack 3 incompatibilities)
3) running `rails app:update` and answering **“yes”** to overwrite prompts

## Repro procedure (macOS + rbenv)

> Note: the Workarea repo itself is not a Rails application at the root, and as of capture time the Rails 7.1/7.2 compatibility gemfiles may not resolve due to dependency constraints. These diffs are still useful because `rails app:update` changes are driven by Rails’ own templates.

```sh
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"
rbenv shell 3.2.7

cd /Users/Shared/openclaw/projects/workarea-modernization/repos/workarea
mkdir -p tmp/wa-verify-023
cd tmp/wa-verify-023
```

### Rails 7.0.10 → 7.1.5.1

```sh
rm -rf sandbox-7.1
mkdir sandbox-7.1
cd sandbox-7.1

cat > Gemfile <<'G'
source 'https://rubygems.org'

gem 'rails', '7.0.10'
G

bundle install

# Rails 7.0.x can fail to boot in some environments unless logger is required early
RUBYOPT='-rlogger' bundle exec rails _7.0.10_ new app \
  --skip-javascript --skip-hotwire --skip-action-mailer --skip-action-cable \
  --skip-sprockets --skip-test --skip-system-test --skip-bootsnap --skip-bundle \
  --skip-git --skip-keeps --skip-docker --skip-kamal --skip-ci --skip-solid \
  --skip-brakeman --skip-rubocop --skip-dev-gems --minimal

cd app
bundle install

git init
git add .
git commit -m "baseline rails 7.0.10"

# Upgrade Rails (and Puma for Rack 3)
sed -i '' -e 's/gem "rails".*/gem "rails", "7.1.5.1"/' Gemfile
sed -i '' -e 's/gem "puma".*/gem "puma", "~> 6.0"/' Gemfile
bundle update rails puma

# Apply Rails template updates (auto-answer "yes" to overwrite prompts)
yes | bundle exec rails app:update

git diff --no-color > ../../../../docs/verification/wa-verify-023/rails-7.1.5.1_app-update-from-7.0.10.diff
```

### Rails 7.0.10 → 7.2.3

```sh
cd /Users/Shared/openclaw/projects/workarea-modernization/repos/workarea/tmp/wa-verify-023

rm -rf sandbox-7.2
mkdir sandbox-7.2
cd sandbox-7.2

cat > Gemfile <<'G'
source 'https://rubygems.org'

gem 'rails', '7.0.10'
G

bundle install
RUBYOPT='-rlogger' bundle exec rails _7.0.10_ new app \
  --skip-javascript --skip-hotwire --skip-action-mailer --skip-action-cable \
  --skip-sprockets --skip-test --skip-system-test --skip-bootsnap --skip-bundle \
  --skip-git --skip-keeps --skip-docker --skip-kamal --skip-ci --skip-solid \
  --skip-brakeman --skip-rubocop --skip-dev-gems --minimal

cd app
bundle install

git init
git add .
git commit -m "baseline rails 7.0.10"

sed -i '' -e 's/gem "rails".*/gem "rails", "7.2.3"/' Gemfile
sed -i '' -e 's/gem "puma".*/gem "puma", "~> 6.0"/' Gemfile
bundle update rails puma

yes | bundle exec rails app:update

git diff --no-color > ../../../../docs/verification/wa-verify-023/rails-7.2.3_app-update-from-7.0.10.diff
```
