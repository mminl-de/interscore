#!/bin/bash

while true; do
	echo "[ffmpeg] Writing to /dev/shm/livebuffer.ts"
	ffmpeg -i rtmp://localhost:1935/live \
		-c copy \
		-f mpegts \
		-y /dev/shm/livebuffer.ts &
	pid=$!

	sleep 600  # run for 5 minutes

	echo "[ffmpeg] Restarting to limit file size..."
	kill $pid
	wait $pid 2>/dev/null

	rm -f /dev/shm/livebuffer.ts
done
