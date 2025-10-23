#!/bin/sh

cat <<EOF >/etc/mediamtx.yml
rtmp: true
rtmpAddress: :$((1935+${STREAM_NUMBER}))

paths:
  all:
    source: publisher

rtsp: false
hls: false
webrtc: false
srt: false
EOF

/usr/bin/mediamtx /etc/mediamtx.yml
