# syntax=docker/dockerfile:1.19.0

ARG ALPINE_VERSION=edge

FROM alpine:${ALPINE_VERSION} AS base

WORKDIR /var/www

RUN apk upgrade --no-cache

RUN --mount=type=cache,target=/var/cache/apk \
    set -eux; \
    PHP_PACKAGES="php85 php85-fpm php85-apcu fcgi"; \
    apk add --no-cache --no-progress ${PHP_PACKAGES}; \
    adduser -u 82 -S -D -G www-data -H -s /sbin/nologin www-data; \
    install -d -o www-data -g www-data /var/run/php; \
    ln -sf /usr/bin/php85 /usr/local/bin/php; \
    install -d /usr/local/sbin; \
    ln -sf /usr/sbin/php-fpm85 /usr/local/sbin/php-fpm; \
    chown -R www-data:www-data /var/www

COPY --link .docker/php.ini /etc/php85/php.ini
COPY --link .docker/conf.d/opcache.ini /etc/php85/conf.d/opcache.ini
COPY --link .docker/php-fpm.d/www.conf /etc/php85/php-fpm.d/www.conf

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

CMD ["php-fpm", "-F"]

# ------------------------------------------------------------------------------

FROM base AS xdebug

RUN --mount=type=cache,target=/var/cache/apk \
    set -eux; \
    apk add --no-cache --no-progress php85-pecl-xdebug

COPY --link .docker/conf.d/50_xdebug.ini /etc/php85/conf.d/50_xdebug.ini

RUN install -o www-data -g www-data -m 644 /dev/null /tmp/xdebug.log