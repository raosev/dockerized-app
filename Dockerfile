FROM ruby:2.5.3-slim
MAINTAINER Rogelio Sevilla <rogelio.sevilla1@gmail.com>

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && mkdir -p /usr/share/man/man7 \
    && apt-get install -qq -y build-essential \
    nodejs libpq-dev postgresql --fix-missing --no-install-recommends


ENV INSTALL_PATH /dockerized-app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# Docker caches these commands, if you change the code but not the gems,
# Docker will reuse the results from these commands
COPY Gemfile Gemfile.lock ./
RUN bundle install


COPY . .

RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@localhost/dbname SECRET_TOKEN=mysecrettoken assets:precompile


#expose the public folder so that nginx can serve the static assets
VOLUME ["$INSTALL_PATH/public"]


#CMD pkill -F tmp/pids/server.pid || rm -f tmp/pids/server.pid
# make sure to listen from every source, otherwise the host wont reach the guest, even though docker ps
# shows that the ports are mapped correctly
#CMD pkill ruby || rm /dockerized-app/tmp/pids/server.pid || true  || rails s -b '0.0.0.0'
CMD rm -f tmp/pids/server.pid && bundle exec rails s -b '0.0.0.0'