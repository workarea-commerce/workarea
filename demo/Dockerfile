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
    libvips-tools \
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
 && echo "gem 'workarea-api'" >> Gemfile \
 && echo "gem 'workarea-blog'" >> Gemfile \
 && echo "gem 'workarea-content_search'" >> Gemfile \
 && echo "gem 'workarea-gift_cards'" >> Gemfile \
 && echo "gem 'workarea-gift_wrapping'" >> Gemfile \
 && echo "gem 'workarea-nvy_theme'" >> Gemfile \
 && echo "gem 'workarea-package_products'" >> Gemfile \
 && echo "gem 'workarea-product_quickview'" >> Gemfile \
 && echo "gem 'workarea-reviews'" >> Gemfile \
 && echo "gem 'workarea-save_for_later'" >> Gemfile \
 && echo "gem 'workarea-share'" >> Gemfile \
 && echo "gem 'workarea-swatches'" >> Gemfile \
 && echo "gem 'workarea-styled_selects'" >> Gemfile \
 && echo "gem 'workarea-slick_slider'" >> Gemfile \
 && echo "gem 'workarea-wish_lists'" >> Gemfile \
 && bundle install

RUN cd /demo && bin/rails g workarea:install

WORKDIR /demo

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
