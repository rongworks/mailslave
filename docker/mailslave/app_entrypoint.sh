#!/usr/bin/env bash

cd ${RAILS_ROOT}
pwd

#echo "COPYING ${APP_SRC} TO ${RAILS_ROOT}"
#/bin/cp -Rf ${APP_SRC}/. ${RAILS_ROOT}

echo "REMOVING SERVER PID"
rm tmp/pids/server.pid


echo "SETUP APP AND DB"
bundle install
bundle exec rake assets:precompile
rails db:create
rails db:migrate
rails db:seed
bundle exec crono start

echo "STARTING SERVER"
rails server -b 0.0.0.0