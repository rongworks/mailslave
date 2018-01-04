FROM ruby:2.4


RUN apt-get update \
  && apt-get install -y nodejs mysql-client sqlite3 vim --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ARG RAILS_ROOT
ARG APP_SRC

ENV APP_SRC $APP_SRC
ENV RAILS_ROOT $RAILS_ROOT

RUN echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

RUN mkdir -p $RAILS_ROOT
RUN mkdir -p $APP_SRC

WORKDIR $RAILS_ROOT

COPY Gemfile $RAILS_ROOT
COPY Gemfile.lock $RAILS_ROOT
RUN gem install bundler && \
  bundle install --without development test

COPY . $APP_SRC
COPY docker/db/database.yml $APP_SRC/config/database.yml
COPY docker/app_entrypoint.sh /entry/app_entrypoint.sh

EXPOSE 3000
#CMD ["rails", "server", "-b", "0.0.0.0"]

ENTRYPOINT ["sh","/entry/app_entrypoint.sh"]

EXPOSE 3000
