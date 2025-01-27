# syntax=docker/dockerfile:1.4

FROM mztrix/alpine  AS base

# Set the working directory
WORKDIR /var/www

# Create the www-data user for PHP-FPM
RUN echo -e "\e[1;33m===> Creating www-data user to execute PHP-FPM\e[0m"; \
    apk --no-cache add shadow; \
    echo -e "\e[1;33m===> add shadow to use addgroup and adduser \e[0m"; \
    addgroup -g 82 www-data; \
    adduser -D -u 82 -G www-data -s /sbin/nologin www-data; \
    echo -e "\e[1;33m===> www-data user created with UID 82 and GID 82\e[0m"; \
    chown -R www-data:www-data .; \
    echo -e "\e[1;33m===> Ownership of /var/www set to www-data:www-data\e[0m"; \
    apk --no-cache del shadow; \
    echo -e "\e[1;33m===> Ownership of /var/www set to www-data:www-data\e[0m";


# Install PHP and required dependencies
RUN RUN echo -e "\e[1;33m===> Installing PHP and required packages\e[0m"; \
    apk --no-cache add php84 php84-fpm fcgi php84-apcu;

# Create symlinks for PHP and PHP-FPM binaries
RUN echo -e "\e[1;33m===> Creating symlinks for PHP and PHP-FPM binaries\e[0m"; \
    ln -sf /usr/bin/php84 /usr/local/bin/php; \
    mkdir -p /usr/local/sbin/; \
    ln -sf /usr/sbin/php-fpm84 /usr/local/sbin/php-fpm;

RUN echo -e "\e[1;33m===> Copy php.ini to /etc/php84/php.ini \e[0m";
COPY --link .docker/php.ini /etc/php84/php.ini

RUN echo -e "\e[1;33m===> Copy php.ini to /etc/php84/php.ini \e[0m";
COPY --link .docker/php-fpm.d/www.conf /etc/php84/php-fpm.d/www.conf

RUN echo -e "\e[1;33m===> Add volume on /var/run/php for php-fpm sock \e[0m";
VOLUME /var/run/php

# Add custom healthcheck script
COPY --link .docker/healthcheck.sh /usr/local/bin/healthcheck
RUN chmod +x /usr/local/bin/healthcheck

# unused files to reduce image size
RUN echo -e "\e[1;33m===> Cleaning up unused files\e[0m"; \
    rm -rf /var/cache/apk/*;


# Add entrypoiny script
COPY --link .docker/php-entrypoint.sh /usr/local/bin/php-entrypoint
RUN chmod +x /usr/local/bin/php-entrypoint

# Add a healthcheck directive for container monitoring
HEALTHCHECK  \
  --interval=10s  \
  --timeout=5s  \
  --start-period=10s  \
  --retries=3 \
  CMD ["healthcheck"]

ENTRYPOINT ["php-entrypoint"]

# Set the default command to run PHP-FPM in the foreground
CMD ["php-fpm", "-F"]