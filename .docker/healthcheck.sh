#!/bin/sh

SOCKET_PATH="/var/run/php/www.sock"

if [ ! -S "$SOCKET_PATH" ]; then
    echo "[$(date)] PHP-FPM socket not found at $SOCKET_PATH"
    exit 1
fi

RESPONSE=$(SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET \
    cgi-fcgi -bind -connect "$SOCKET_PATH" | tail -n 1)

echo "$RESPONSE"

if [ "$RESPONSE" = "pong" ]; then
    exit 0
else
    exit 1
fi
