# Docker FPM

This repository provides an optimized Docker image for PHP-FPM, based on **Alpine Linux**. It is designed to offer a lightweight and flexible solution for developers and system administrators deploying PHP applications in containers.

## Features

- **🌍 Small Footprint**: A base image of less than 38MB, promoting resource preservation and efficiency.

- **🐘 PHP-FPM**: Integrated for efficient PHP process management, featuring essential PHP 8.4 packages like `php84`, `php84-fpm`, `fcgi`, and `php84-apcu`. Utilizes Unix socket mode for enhanced performance and inter-process communication.

- **🛠️ Modular Configurations**: The `php.ini` file and `php-fpm.d` directory allowed for easy parameter customization.

- **❤️ Healthcheck**: Includes a built-in healthcheck endpoint (`/ping`) that responds with `pong`, ensuring the container's readiness and uptime.

- **🛡️ Secure Defaults**: Includes minimal packages, reducing the attack surface.

## Project Structure

Here is the project structure:

```plaintext
.
├── .docker/                    # Directory for custom Docker configurations
│   ├── php-fpm.d/              # Directory containing PHP-FPM-specific configuration files
│   │   └── www.conf            # PHP-FPM pool configuration file for process and resource management
│   ├── healthcheck.sh          # Script for defining health checks for containers
│   └── php.ini                 # PHP configuration file (INI format) for customizing runtime settings
├── compose.override.yaml.dist  # Example override file for extending or customizing Docker Compose settings
├── compose.yaml                # Primary Docker Compose file for defining multi-container configurations
├── Dockerfile                  # Dockerfile defining the base image and build instructions
└── compose.yaml                # Duplicate entry — ensure only one compose.yaml exists in your structure
```

## Configuration Files Content

### `php.ini`

This file provides optimized PHP settings tailored for Symfony and PHP-FPM environments. Example content:

```ini
; -------------------------
; PHP General Configuration
; -------------------------
memory_limit = 256M          ; Memory limit adapted for Symfony
max_execution_time = 30      ; Maximum execution time for a script
error_reporting = E_ALL      ; Display all error levels
display_errors = Off         ; Disable error display in production
log_errors = On              ; Enable error logging
error_log = /var/log/php/php_errors.log ; Location of the error log file
default_charset = UTF-8      ; Default character set
file_uploads = On            ; Enable file uploads
upload_max_filesize = 64M    ; Maximum size of uploaded files
post_max_size = 64M          ; Maximum size for POST requests
date.timezone = UTC          ; Timezone

; ---------------------
; Symfony-Specific Tuning
; ---------------------
realpath_cache_size = 4096k  ; Increase realpath cache size
realpath_cache_ttl = 600     ; Realpath cache time-to-live
opcache.enable = 1           ; Enable OPcache
opcache.memory_consumption = 128 ; OPcache memory size
opcache.max_accelerated_files = 20000 ; Number of files in OPcache
opcache.revalidate_freq = 0  ; Disable cache revalidation in production

; ----------------
; Security Settings
; ----------------
disable_functions = exec, system, shell_exec, passthru, phpinfo, show_source, popen, pclose, proc_open, proc_close
expose_php = Off             ; Disable PHP version exposure in HTTP headers

; -----------------
; Session Management
; -----------------
session.cookie_secure = On   ; Force session cookies to use HTTPS
session.cookie_httponly = On ; Prevent cookie access via JavaScript
session.use_strict_mode = 1  ; Prevent usage of invalid sessions
session.save_path = /var/lib/php/sessions ; Location of session files

; --------------------
; Error Handling
; --------------------
display_startup_errors = Off ; Disable startup error display
track_errors = Off           ; Disable error tracking
```

### `php-fpm.d/www.conf`

This file configures specific settings for PHP-FPM. Example content:

```ini
[global]
; Global settings for PHP-FPM
error_log = /proc/self/fd/2       ; Log errors to Docker logs
log_level = notice                ; Log level: debug, notice, warning, error

[www]
; Pool name ('www' replaces the default 'www')
user = www-data                   ; Run PHP-FPM processes as this user
group = www-data                  ; Run PHP-FPM processes as this group

; Listen on a Unix socket for improved performance
listen = /var/run/php/www.sock
listen.owner = www-data           ; Socket file owner
listen.group = www-data           ; Socket file group
listen.mode = 0660                ; Permissions for the socket

; Process Manager Settings
pm = dynamic                      ; Dynamic process management
pm.max_children = 10              ; Max number of child processes
pm.start_servers = 3              ; Number of child processes at startup
pm.min_spare_servers = 2          ; Minimum number of idle child processes
pm.max_spare_servers = 5          ; Maximum number of idle child processes

; Logging Access
access.log = /proc/self/fd/1      ; Log access to Docker logs
access.format = "%R - %m %r - %s - %C"

; Pass environment variables to PHP
clear_env = no                    ; Pass all environment variables to PHP

; Status and Ping for Healthchecks
ping.path = /ping                 ; URL to respond to for healthchecks
ping.response = pong              ; Response string for the ping path

; Security Settings
security.limit_extensions = .php  ; Only allow PHP files to be executed
```

## Prerequisites

The required tools depend on your use case:

- **To build and run Docker images**:
    - **[Docker](https://docs.docker.com/get-docker/)**: Required for building and running containers.

- **To use multi-container setups**:
    - **[Docker Compose](https://docs.docker.com/compose/install/)**: Required for managing multiple containers via `compose.yaml`.

Ensure you have the appropriate tool installed based on your specific objectives.

---

## Getting Started

### Installation Instructions

#### Clone the Repository

Start by cloning this repository:

```bash
git clone https://github.com/mztrix/docker-php-fpm
cd docker-php-fpm
```

## Way to use images

You can find the pre-built Docker images for this repository on Docker Hub:

[Docker Hub: mztrix/php-fpm](https://hub.docker.com/r/mztrix/php-fpm/tags)

### Available Docker Images

- `latest`: The most up-to-date version of the image.

Use the appropriate tag based on your requirements, e.g.:

```bash
docker pull mztrix/php-fpm:latest
```
---

### Build an image

To build the Docker image locally, you can run:

```bash
docker build -t mztrix/php-fpm .
```

This command uses the `Dockerfile` in the repository to create an image named `mztrix/php-fpm`.

---

### Run a container

You can start the container interactively using:

```bash
docker run -it mztrix/php-fpm /bin/sh
```

This will give you access to a shell session inside the container.

---

### Using Docker Compose

For multi-container setups or simplified configurations, use Docker Compose:

#### Start Services

```bash
docker compose up -d
```

#### Stop Services

```bash
docker compose down
```

#### Customization

You can modify `compose.override.yaml.dist` to configure environment-specific settings, such as port mappings or volume mounts.

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.

---

## Contribution

Contributions are welcome! To contribute:

1. Fork this repository.
2. Create a new branch:

   ```bash
   git checkout -b feature/my-feature
   ```

3. Commit your changes:

   ```bash
   git commit -m "Add my feature"
   ```

4. Push your branch:

   ```bash
   git push origin feature/my-feature
   ```

5. Open a Pull Request.

---

## Author

Created and maintained by [mztrix](https://github.com/mztrix). Contributions are welcome!

