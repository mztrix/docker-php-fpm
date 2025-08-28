# syntax=docker/dockerfile:1.7

ARG ALPINE_VERSION=latest

FROM alpine:${ALPINE_VERSION} AS base

WORKDIR /var/www

RUN --mount=type=cache,target=/var/cache/apk \
    set -eux; \
    PHP_PACKAGES="php84 php84-fpm php84-apcu php84-opcache fcgi"; \
    apk add --no-cache --no-progress ${PHP_PACKAGES}; \
    adduser -u 82 -S -D -G www-data -H -s /sbin/nologin www-data; \
    install -d -o www-data -g www-data /var/run/php; \
    ln -sf /usr/bin/php84 /usr/local/bin/php; \
    install -d /usr/local/sbin; \
    ln -sf /usr/sbin/php-fpm84 /usr/local/sbin/php-fpm; \
    chown -R www-data:www-data /var/www

COPY --link .docker/php.ini /etc/php84/php.ini
COPY --link .docker/conf.d/00_opcache.ini /etc/php84/conf.d/
COPY --link .docker/php-fpm.d/www.conf /etc/php84/php-fpm.d/www.conf

COPY --link .docker/healthcheck.sh /usr/local/bin/healthcheck
COPY --link .docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -eux; chmod +x /usr/local/bin/healthcheck /usr/local/bin/docker-entrypoint

VOLUME /var/run/php

HEALTHCHECK \
  --interval=10s \
  --timeout=5s \
  --start-period=10s \
  --retries=3 \
  CMD ["healthcheck"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

CMD ["/usr/sbin/php-fpm84", "-F"]