FROM adhocore/phpfpm:8.0

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  ADMINER_VERSION=4.7.8

RUN \
  # install
  apk add -U --no-cache \
    memcached \
    mysql mysql-client \
    nano \
    nginx \
    postgresql \
    redis \
    supervisor \
  # rabbitmq
  # && echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    # && apk add -U rabbitmq-server@testing \
    # && apk add -U rabbitmq-server \
  # adminer
  && mkdir -p /var/www/adminer \
    && curl -sSLo /var/www/adminer/index.php \
      "https://github.com/vrana/adminer/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION-en.php" \
  # cleanup
  && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# resource
COPY php/index.php /var/www/html/index.php

# supervisor config
COPY \
  memcached/memcached.ini \
  mysql/mysqld.ini \
  nginx/nginx.ini \
  pgsql/postgres.ini \
  php/php-fpm.ini \
  # rabbitmq/rabbitmq-server.ini \
  redis/redis-server.ini \
    /etc/supervisor.d/

# entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# ports
EXPOSE 11211 9000 6379 5432 3306 80

# commands
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
