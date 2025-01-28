# syntax=docker/dockerfile:1.4

FROM alpine as base

# Update the package index and add the required Alpine keys
RUN set -eux; \
    echo -e "\e[1;33m===> Updating the package index and adding Alpine keys\e[0m"; \
    apk update --no-progress && apk add --no-cache alpine-keys;

# Set the working directory for the application
WORKDIR /var/www

# Create the www-data user for PHP-FPM with appropriate permissions
RUN set -eux; \
    echo -e "\e[1;33m===> Creating www-data user for PHP-FPM\e[0m"; \
    adduser -D -u 82 -S -G www-data -s /sbin/nologin www-data; \
    echo -e "\e[1;33m===> www-data user created with UID 82 and GID 82\e[0m"; \
    chown -R www-data:www-data .; \
    echo -e "\e[1;33m===> Set ownership of /var/www to www-data:www-data\e[0m";

# Install PHP and essential dependencies
RUN set -eux; \
    echo -e "\e[1;33m===> Installing PHP and required dependencies\e[0m"; \
    apk --no-cache add php84 php84-fpm fcgi php84-apcu;

# Create symlinks for PHP and PHP-FPM binaries in standard locations
RUN set -eux; \
    echo -e "\e[1;33m===> Creating symlinks for PHP and PHP-FPM binaries\e[0m"; \
    ln -sf /usr/bin/php84 /usr/local/bin/php; \
    mkdir -p /usr/local/sbin && ln -sf /usr/sbin/php-fpm84 /usr/local/sbin/php-fpm;

# Copy php.ini to the appropriate directory
RUN echo -e "\e[1;33m===> Copying php.ini to /etc/php84/php.ini \e[0m";
COPY --link .docker/php.ini /etc/php84/php.ini

# Copy the PHP-FPM configuration file
RUN echo -e "\e[1;33m===> Copying PHP-FPM configuration to /etc/php84/php-fpm.d/www.conf \e[0m";
COPY --link .docker/php-fpm.d/www.conf /etc/php84/php-fpm.d/www.conf

# Define a volume for the PHP-FPM socket
RUN echo -e "\e[1;33m===> Adding volume for PHP-FPM socket at /var/run/php \e[0m";
VOLUME /var/run/php

# Add a custom healthcheck script for monitoring container health
COPY --link .docker/healthcheck.sh /usr/local/bin/healthcheck
RUN chmod +x /usr/local/bin/healthcheck

# Clean up unused files to reduce image size
RUN echo -e "\e[1;33m===> Cleaning up unused files to reduce image size\e[0m"; \
    rm -rf /var/cache/apk/*;

# Add the Docker entrypoint script
COPY --link .docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN set -eux; chmod +x /usr/local/bin/docker-entrypoint

# Define a healthcheck command for the container
HEALTHCHECK  \
  --interval=10s  \
  --timeout=5s  \
  --start-period=10s  \
  --retries=3 \
  CMD ["healthcheck"]

# Set the default entrypoint script
ENTRYPOINT ["docker-entrypoint"]

# Set the default command to run PHP-FPM in the foreground
CMD ["php-fpm"]