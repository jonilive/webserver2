#!/bin/sh
umask 002

if [ ! -f "/var/config/nginx.conf" ]; then
    echo "Creating example nginx.conf..."
    cat <<'EOL' > /var/config/nginx.conf
user webserver2 users;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /run/nginx/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /var/log/nginx/access.log;
    sendfile on;
    keepalive_timeout 65;

    server {
        listen 80 default_server;
        server_name _;
        root /www;
        index index.php index.html index.htm;

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
            try_files $uri =404;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_pass 127.0.0.1:9000;
        }

        location ~ /\.(?!well-known).* {
            deny all;
        }
    }
}
EOL
    chmod 666 /var/config/nginx.conf
fi

# Create crontab if it doesn't exist, so user can edit it later
if [ ! -f "/var/config/crontab" ]; then
    echo "Creating example crontab..."
    cat <<EOL > /var/config/crontab
# System crontab file
# Edit this file to add your cron jobs
# Format: minute hour day month weekday user command
# Example: run Laravel scheduler every day at 2 AM as webserver2
# 0 2 * * * php /www/artisan schedule:run

# Uncomment the line below to run a test command every minute as webserver2
# * * * * * echo "Cron is working" >> /var/log/cron.log
EOL
    chmod 777 /var/config/crontab
fi

# If php.ini doesn't exist, copy the default php one so user can edit it later
if [ ! -f "/var/config/php.ini" ]; then
    echo "Copy the default php.ini..."
    cp /etc/php85/php.ini /var/config/php.ini
    chmod 777 /var/config/php.ini
fi

# Look for config files in /var/config and copy them to the appropriate locations
if [ -d "/var/config" ]; then
    cp /var/config/nginx.conf /etc/nginx/nginx.conf
    cp /var/config/php.ini /etc/php85/php.ini
    cp /var/config/crontab /etc/crontabs/webserver2
    chmod 600 /etc/crontabs/webserver2
fi

mkdir -p /var/log/nginx /var/log/php85
chmod 777 /var/log/nginx /var/log/php85

# Run PHP-FPM workers as the same user as nginx and cron
sed -i -e 's/^user = .*/user = webserver2/' -e 's/^group = .*/group = users/' /etc/php85/php-fpm.d/www.conf

for file in \
    /var/log/nginx/error.log \
    /var/log/nginx/access.log \
    /var/log/cron.log
do
    [ -f "$file" ] || touch "$file"
done

chown webserver2:users /var/log/nginx
chown webserver2:users /www

chmod 777 /www
chmod 777 /var/log/nginx/error.log
chmod 777 /var/log/nginx/access.log
chmod 777 /var/log/cron.log

# Look for startup.sh in /var/config and execute it if it exists
if [ -f "/var/config/startup.sh" ]; then
    echo "Executing startup.sh..."
    chmod 777 /var/config/startup.sh
    chmod +x /var/config/startup.sh
    /var/config/startup.sh
fi

echo "Starting cron..."
crond -f -L /var/log/cron.log &

echo "Starting PHP-FPM..."
php-fpm85 -F &

echo "Starting nginx..."
exec nginx -g 'daemon off;'
