// TODO REMOVE httpz
// TODO CHECK is App client-specific?
const std = @import("std");
const ws = @import("websocket");

pub const log = std.log.scoped(.interscore);
pub const ziglog = std.log.scoped(.zig);

const AllocatorWrapper = @import("AllocatorWrapper.zig");
const App = @import("App.zig");
const Handler = @import("Handler.zig");
const MessageType = @import("MessageType.zig").MessageType;

pub fn main() u8 {
	var aw = AllocatorWrapper.init();
	defer aw.deinit();
	const gpa = aw.allocator();

	var args = std.process.args();
	_ = args.skip(); // Skip executable name

	const addr: []const u8 = args.next() orelse "127.0.0.1";
	if (std.mem.eql(u8, addr, "--help")) return help();

	const port: u16 = port: {
		const buf = args.next() orelse break :port 8000;
		break :port std.fmt.parseInt(u16, buf, 10) catch {
			log.err("'{s}' into a valid port number!", .{buf});
			return 1;
		};
	};

	var server = ws.Server(Handler).init(gpa, .{
		.port = port,
		.address = addr,
		.handshake = .{
			.timeout = 3,
			.max_size = 1024,
			.max_headers = 0,
		},
	}) catch {
		ziglog.err("Failed to create WebSocket server!", .{});
		return 1;
	};
	defer server.deinit();

	var app = App.init(gpa) catch return 1;
	defer app.deinit(gpa);

	server.listen(&app) catch |e| {
		switch (e) {
			error.InvalidIPAddressFormat =>
				log.err("'{s}' is not a valid IP address!", .{addr}),
			else => log.err("WebSocket server failed to keep listening!", .{})
		}
		return 1;
	};

	return 0;
}

/// Prints help message and returns exit code to use.
fn help() u8 {
	var stdout_wrapper = std.fs.File.stdout().writer(&.{});
	_ = stdout_wrapper.interface.writeAll(
		\\interscore-echo - Interscore's internal echo server
		\\v0.0.1
		\\
		\\Usage: interscore-echo [ADDRESS [PORT]]
		\\
		\\Options:
		\\    ADDRESS  IP address          (default: 127.0.0.1)
		\\    PORT     16-bit port number  (default: 8000)
		\\
	) catch return 71;
	return 0;
}
