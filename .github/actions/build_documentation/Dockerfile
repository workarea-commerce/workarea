FROM ruby:2.6

COPY documentation /documentation

RUN apt-get update \
 && apt-get install -yqq curl \
 && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
 && apt-get update \
 && apt-get install -yqq --no-install-recommends \
    build-essential \
    nodejs \
 && gem install bundler \
 && cd documentation \
 && bundle install

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
