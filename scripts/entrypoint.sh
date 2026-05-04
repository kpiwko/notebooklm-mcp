#!/bin/bash
set -e

Xvfb :99 -screen 0 1280x800x24 -nolisten tcp &

until xdpyinfo -display :99 >/dev/null 2>&1; do sleep 0.1; done

x11vnc -display :99 -nopw -listen 0.0.0.0 -forever -quiet &

websockify --web /usr/share/novnc 6080 localhost:5900 &

exec notebooklm-mcp --transport http --port 17200
