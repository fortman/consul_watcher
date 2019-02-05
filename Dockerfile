FROM consul:1.4.0

ARG gem_file

RUN apk add --no-cache jq build-base libc-dev linux-headers postgresql-dev libxml2-dev libxslt-dev ruby ruby-dev ruby-rdoc ruby-irb

COPY ./docker-entrypoint.sh /
COPY pkg/$gem_file /consul_watcher/

RUN cd /consul_watcher ; \
    gem install $gem_file

ENTRYPOINT ["/docker-entrypoint.sh"]
