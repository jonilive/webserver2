
<div align="center"><img width="256" height="256" alt="logo" src="https://github.com/user-attachments/assets/ec8f3530-0c42-4037-83f8-c43d3c63241e" /></div>

# Webserver2 Docker Setup

A lightweight, configurable web server container based on Alpine Linux, featuring nginx, PHP 8.5-FPM, and cron support for scheduled tasks.

## Features

- **nginx** web server with PHP 8.5-FPM integration
- **PHP 8.5** with extensive extensions (GD, MySQLi, Redis, SOAP, XML, ZIP, etc.)
- **Cron daemon** for scheduled tasks
- **Configurable** via mounted volumes - edit configs without rebuilding
- **Development tools** included: Git, Python 3, Node.js, npm, htop
- **Lightweight** Alpine Linux base

## Prerequisites

- Docker and Docker Compose installed on your system

## Quick Start

1. Clone or download this repository
2. Place your web application files in `appdata/www/`
3. Run the container:

```bash
docker-compose up -d
```

4. Access your site at `http://localhost`

## Configuration

The container is designed to be highly configurable through mounted volumes. All configuration files are created automatically on first run with sensible defaults.

### Web Server Configuration

On first startup, `init.sh` creates `appdata/config/nginx.conf` with a starting-point configuration if it does not already exist. Edit that file to customize nginx settings; it is loaded as `/etc/nginx/nginx.conf` on startup. Existing Apache `httpd.conf` files are no longer used.

### PHP Configuration

Edit `appdata/config/php.ini` to customize PHP settings. The file is copied to `/etc/php85/php.ini` on container startup.

### Cron Jobs

Edit `appdata/config/crontab` to add scheduled tasks. Uses system crontab format with user field. Jobs run as the `webserver2` user for consistency with web application permissions.

Example crontab entries:
```
# Run Laravel scheduler daily at 2 AM
0 2 * * * php /www/artisan schedule:run

# Run queue worker every minute
* * * * * php /www/artisan queue:work --sleep=3 --tries=3

# Custom PHP script every 5 minutes
*/5 * * * * php /www/custom-script.php
```

## Directory Structure

```
webserver2/
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile           # Container build instructions
├── init.sh             # Container initialization script
├── LICENSE             # MIT License
├── appdata/
│   ├── config/         # Configuration files (nginx.conf, php.ini, crontab, startup.sh)
│   ├── log/            # nginx and cron logs
│   └── www/            # Web application files
```

## Usage

### Starting the Container

```bash
docker-compose up -d
```

### Stopping the Container

```bash
docker-compose down
```

### Viewing Logs

```bash
docker-compose logs -f webserver2
```

### Rebuilding After Configuration Changes

```bash
docker-compose up -d --build
```

### Accessing the Container

```bash
docker exec -it webserver2 /bin/sh
```

## PHP Extensions Included

- php85, php85-fpm, php85-calendar, php85-cli, php85-common, php85-ctype, php85-curl
- php85-dev, php85-dom, php85-exif, php85-ffi, php85-fileinfo, php85-ftp, php85-gd
- php85-gettext, php85-iconv, php85-imap, php85-intl, php85-mbstring, php85-mysqli
- php85-odbc, php85-pcntl, php85-pdo, php85-pdo_mysql, php85-pdo_sqlite, php85-pear
- php85-pecl-igbinary, php85-pecl-imagick, php85-phar, php85-posix, php85-redis
- php85-shmop, php85-simplexml, php85-soap, php85-sodium, php85-sqlite3
- php85-sysvmsg, php85-sysvsem, php85-sysvshm, php85-tokenizer, php85-xml
- php85-xmlreader, php85-xmlwriter, php85-xsl, php85-zip

## Security Notes

- Cron jobs run as the `webserver2` user, not root
- nginx runs as `webserver2:users`; PHP-FPM serves PHP scripts
- Container follows principle of least privilege

## Troubleshooting

- **Permission issues**: Ensure files in `appdata/www/` are readable by the `webserver2` user
- **Cron not working**: Check `/var/log/cron.log` inside the container
- **nginx errors**: Check `appdata/log/nginx/error.log`
- **PHP errors**: Check the container logs for PHP-FPM errors

## License

MIT License - see LICENSE file for details.

Copyright (c) 2026 João "Jonilive" Rodrigues
