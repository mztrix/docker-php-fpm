# mztrix/docker-php-fpm

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-mztrix%2Fphp--fpm-2496ed?logo=docker)](https://hub.docker.com/r/mztrix/php-fpm)
[![Docker Pulls](https://img.shields.io/docker/pulls/mztrix/php-fpm?logo=docker)](https://hub.docker.com/r/mztrix/php-fpm)
[![Image Size](https://img.shields.io/docker/image-size/mztrix/php-fpm/latest?logo=docker)](https://hub.docker.com/r/mztrix/php-fpm/tags)

[![PHP](https://img.shields.io/badge/PHP-8.4-777bb3?logo=php&logoColor=white)](https://www.php.net/releases/8.4/en.php)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

provides an optimized Docker image for PHP-FPM, based on **Alpine Linux**. It is designed to offer a lightweight and flexible solution for developers and system administrators deploying PHP applications in containers.

## Table of Contents
- Prerequisites
- Overview
- Quick Start
- Usage with Docker Compose
- License

## Prerequisites

The required tools depend on your use case:

- **To build and run Docker images**:
    - **[Docker](https://docs.docker.com/get-docker/)**: Required for building and running containers.

- **To use multi-container setups**:
    - **[Docker Compose](https://docs.docker.com/compose/install/)**: Required for managing multiple containers via `compose.yaml`.

## Overview
- Alpine-based image (Dockerfile) with PHP 8.4 FPM and essentials.
- FPM socket at `/var/run/php/www.sock`, suitable for sharing with a reverse proxy.
- Simple entrypoint and default command: php-fpm -F.
- Healthcheck using cgi-fcgi that hits /ping and expects "pong".

## Quick Start
1) Clone and (optionally) prepare a local override
```bash
git clone https://github.com/mztrix/docker-php-fpm
cd docker-php-fpm
cp compose.override.yaml.dist compose.override.yaml   # recommended for local use
```

2) Start PHP-FPM
```bash
docker compose up -d --wait
```
This builds the local image (target: base) and starts the php service.

3) Check status
```bash
docker compose ps
docker compose logs -f php
```

## Usage with Docker Compose
- compose.yaml defines the minimal php service.
- compose.override.yaml(.dist) shows useful local mounts:
  - `.docker/php.ini` -> `/etc/php84/php.ini`
  - `.docker/php-fpm.d/www.conf `-> `/etc/php84/php-fpm.d/www.conf`
  - fpm-sock volume -> `/var/run/php`

Environment/build variable:
- IMAGES_PREFIX (optional): image name prefix used by compose (defaults to mztrix/php-fpm).



## License
MIT — see LICENSE.
