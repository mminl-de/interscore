const std = @import("std");
const ws = @import("websocket");

pub const log = std.log.scoped(.interscore);
pub const ziglog = std.log.scoped(.zig);

const AllocatorWrapper = @import("allocator.zig").AllocatorWrapper;
const App = @import("App.zig");
const Handler = @import("Handler.zig");
const MessageType = @import("MessageType.zig").MessageType;

pub fn main() u8 {
	real_main() catch return 1;
	return 0;
}

pub fn real_main() !void {
	var aw = AllocatorWrapper.init();
	defer aw.deinit();
	const gpa = aw.allocator();

	var args = std.process.args();
	_ = args.skip(); // skip "echo"

	var app = try App.init(gpa);

	var server = ws.Server(Handler).init(gpa, .{
		.port = 8000, // TODO
		.address = "127.0.0.1",
		.handshake = .{
			.timeout = 3,
			.max_size = 1024,
			.max_headers = 0,
		},
	}) catch |err| {
		log.err("Failed to create WebSocket server!", .{});
		return err;
	};

	server.listen(&app) catch |err| {
		log.err("WebSocket server failed to keep listening!", .{});
		return err;
	};
}
