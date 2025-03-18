#!/bin/sh

# Get stream info
stream_info=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate -of csv=p=0 rtmp://localhost:1935/live/test)
width=$(echo "$stream_info" | cut -d ',' -f 1)
height=$(echo "$stream_info" | cut -d ',' -f 2)
fps=$(echo "$stream_info" | cut -d ',' -f 3 | bc -l) #fract to decimal

echo "Input Stream Resolution: ${width}x${height}"
echo "Input Stream FPS: $fps"

gst-launch-1.0 \
  webkit2gtk location=http://localhost:8000 ! \
  videoconvert ! \
  videoscale ! video/x-raw,width=$width,height=$height ! \
  compositor name=comp sink_0::alpha=1 ! \
  videoconvert ! x264enc ! flvmux ! \
  rtmpsink location="$1" \
  \
  rtmpsrc location=rtmp://localhost:1935/live/test ! \
  flvdemux ! h264parse ! avdec_h264 ! \
  videoconvert ! comp.
