run:
	zig build
	zig-out/bin/echo

deps:
	git clone https://github.com/karlseguin/websocket.zig
	git clone https://github.com/karlseguin/http.zig
	tar czf websocket.zig.tar.gz websocket.zig
	tar czf http.zig.tar.gz http.zig
	zig fetch --save ./websocket.tar.gz
	zig fetch --save ./http.tar.gz

clean:
	rm -rfv websocket.zig websocket.zig.tar.gz http.zig http.zig.tar.gz
