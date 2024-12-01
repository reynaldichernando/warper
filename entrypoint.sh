#!/bin/bash

# Start DBUS daemon
dbus-daemon --system --nofork --nopidfile &

# Start WARP service
warp-svc &

# Wait for warp-svc to be ready
max_attempts=30
attempt=0
while ! warp-cli --accept-tos status > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -eq $max_attempts ]; then
        echo "Timeout waiting for warp-svc to start"
        exit 1
    fi
    sleep 1
done

warp-cli --accept-tos registration new
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port 40000
warp-cli --accept-tos connect

tinymapper -l0.0.0.0:1080 -r127.0.0.1:40000 -t --log-level 3

# Keep container running
tail -f /dev/null