FROM ruby:3.2
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN gem install bundler:2.4.13
WORKDIR srv/app
ENV BUNDLE_DEPLOYMENT=true \
  BUNDLE_WITHOUT=development:test \
  RACK_ENV=production \
  RUBY_YJIT_ENABLE=true
COPY Gemfile* ./
RUN bundle install
COPY . ./
ENTRYPOINT ["bundle", "exec", "puma", "--config", "puma.rb"]
