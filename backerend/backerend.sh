#!/bin/sh
pkill Xvfb

echo "start the x server"
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99
sleep 3
echo "start obs"
~/mnl/obs --disable-shutdown-check --startreplaybuffer --collection radball.json --profile radball --scene live --websocket_port 4444
