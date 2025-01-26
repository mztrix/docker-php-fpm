#!/bin/sh

SOCKET_PATH="/var/run/php/www.sock"

# Check if the socket file exists
if [ ! -S "$SOCKET_PATH" ]; then
    echo "[$(date)] PHP-FPM socket not found at $SOCKET_PATH"
    exit 1
fi

# Test the /ping route via the socket and capture only the response content
RESPONSE=$(SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET \
    cgi-fcgi -bind -connect "$SOCKET_PATH" | tail -n 1)

# Echo the response content
echo "$RESPONSE"

# Determine healthcheck status
if [ "$RESPONSE" = "pong" ]; then
    exit 0
else
    exit 1
fi
