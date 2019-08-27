FROM ruby:2.6.3-slim

RUN apt-get update \
 && apt-get install -yqq curl gnupg \
 && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
 && apt-get update \
 && apt-get install -yqq --no-install-recommends \
    git \
    ssh \
    tzdata \
    build-essential \
    nodejs \
    libssl-dev \
    libyaml-dev \
    libreadline6-dev \
    zlib1g-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm-dev \
    autoconf \
    bison \
    xvfb \
    imagemagick \
    jpegoptim \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /demo \
 && cd /demo \
 && bundle init \
 && echo "gem 'workarea'" >> Gemfile \
 && bundle install \
 && bundle exec rails new ./ --force \
      --skip-spring \
      --skip-active-record \
      --skip-action-cable \
      --skip-puma \
      --skip-coffee \
      --skip-turbolinks \
      --skip-bootsnap \
      --skip-yarn \
      --skip-bundle \
 && echo "gem 'workarea'" >> Gemfile \
 && echo "gem 'workarea-nvy_theme'" >> Gemfile \
 && bundle install

RUN cd /demo && bin/rails g workarea:install

WORKDIR /demo

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
