# syntax=docker/dockerfile:1.23.0
ARG ALPINE_VERSION=edge

FROM alpine:${ALPINE_VERSION} AS base
ARG PHP_VERSION=85

RUN --mount=type=cache,target=/var/cache/apk \
    set -eux; \
    install -d -o root -g root /usr/local/sbin; \
    adduser -u 82 -S -D -G www-data -H -s /sbin/nologin www-data; \
    install -d -o www-data -g www-data /var/run/php /var/www; \
    PHP_PACKAGES="php${PHP_VERSION} php${PHP_VERSION}-fpm php${PHP_VERSION}-apcu fcgi"; \
    apk add --no-cache --no-progress ${PHP_PACKAGES}; \
    apk upgrade --no-cache; \
    ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/local/sbin/php-fpm; \
    ln -sf /usr/bin/php${PHP_VERSION} /usr/local/bin/php

COPY --link .docker/php-fpm.d/www.conf /etc/php85/php-fpm.d/www.conf
COPY --link .docker/php.ini /etc/php85/php.ini
COPY --link .docker/conf.d/opcache.ini /etc/php85/conf.d/opcache.ini

COPY --link --chmod=555 .docker/healthcheck.sh /usr/local/bin/healthcheck
COPY --link --chmod=555 .docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

USER www-data

HEALTHCHECK \
  --interval=10s \
  --timeout=3s \
  --start-period=10s \
  --retries=3 \
  CMD ["healthcheck"]

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm", "-F"]

FROM base AS xdebug

USER root

RUN --mount=type=cache,target=/var/cache/apk \
    set -eux; \
    apk add --no-cache --no-progress php85-pecl-xdebug

COPY --link .docker/conf.d/50_xdebug.ini /etc/php85/conf.d/50_xdebug.ini

USER www-data