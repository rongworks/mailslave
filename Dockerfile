FROM ruby:2.4


RUN apt-get update \
  && apt-get install -y nodejs mysql-client sqlite3 vim --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ARG RAILS_ROOT

RUN echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

COPY Gemfile $RAILS_ROOT
COPY Gemfile.lock $RAILS_ROOT
RUN gem install bundler && \
  bundle config --global frozen 1 && \
  bundle install --without development test

COPY . $RAILS_ROOT
COPY docker/db/database.yml $RAILS_ROOT/config/database.yml
COPY docker/app_entrypint.sh $RAILS_ROOT

RUN bundle exec rake assets:precompile

EXPOSE 3000
#CMD ["rails", "server", "-b", "0.0.0.0"]

ENTRYPOINT ["app_entrypoint.sh"]

EXPOSE 3000