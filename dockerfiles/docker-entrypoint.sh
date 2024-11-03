#!/bin/bash

if [ -f /tmp/.X99-lock ]; then 
  rm -f /tmp/.X99-lock
fi

if ! pgrep -x "Xvfb" > /dev/null; then 
  Xvfb :99 -screen 0 1024x768x24 &
  DISPLAY=:99 fluxbox &
fi

echo "Waiting for Xvfb to start..."
sleep 1

exec "$@"
