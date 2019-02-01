FROM consul:1.4.0

ARG gem_file

RUN apk add --no-cache jq build-base libc-dev linux-headers postgresql-dev libxml2-dev libxslt-dev ruby ruby-dev ruby-rdoc ruby-irb jq

COPY ./docker-entrypoint.sh /
COPY ./watch_handler /consul_watch_to_amqp/
COPY ./Gemfile /consul_watch_to_amqp/
COPY ./consul_watch_to_amqp.gemspec /consul_watch_to_amqp/
COPY pkg/$gem_file /consul_watch_to_amqp/

RUN cd /consul_watch_to_amqp ; \
    gem install $gem_file

ENTRYPOINT ["/docker-entrypoint.sh"]
