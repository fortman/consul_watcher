FROM consul:1.4.0

ARG gem_file

RUN apk add --no-cache jq build-base libc-dev linux-headers postgresql-dev libxml2-dev libxslt-dev ruby ruby-dev ruby-rdoc ruby-irb jq

COPY ./docker-entrypoint.sh /
COPY ./watch_handler /ruby_consul_watch/
COPY ./Gemfile /ruby_consul_watch/
COPY ./ruby_consul_watch.gemspec /ruby_consul_watch/
COPY pkg/$gem_file /ruby_consul_watch/

RUN cd /ruby_consul_watch ; \
    gem install $gem_file

ENTRYPOINT ["/docker-entrypoint.sh"]
