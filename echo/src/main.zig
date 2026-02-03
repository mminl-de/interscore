const std = @import("std");
const ws = @import("websocket");
const AllocatorWrapper = @import("allocator.zig").AllocatorWrapper;

const log = std.log.scoped(.interscore);
const ziglog = std.log.scoped(.zig);

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

	var app = App{};

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

const Handler = struct {
	app: *App,
	conn: *ws.Conn,

	// Callback running after connection establishment has been requested
	pub fn init(_: *ws.Handshake, conn: *ws.Conn, app: *App) !Handler {
		log.info("Connecting new client!");
		return .{ .app = app, .conn = conn };
	}

	// Callback running after connection has been established
	pub fn afterInit(_: *Handler) !void {
		log.info("New client connected!");
	}

	// Callback running when client sends message
	pub fn clientMessage(self: *Handler, data: []const u8) !void {
		try self.conn.write(data);
	}

	// Callback running when connection is about to be terminated
	pub fn close(self: *Handler) !void {
		// TODO NOW separate boss and client list
		if (self.app.bos == self.conn) self.app.boss = null;
		blk: {
			for (self.app.clients.items) |*client| {
				if (client.* == self.conn) {
					client.* = self.app.clients.items[self.app.clients.items.len - 1];
					self.app.clients.shrinkRetainingCapacity(self.app.clients.items.len - 1);
					break :blk;
				}
			}
			unreachable;
		}
		log.info("Client disconnected!", .{}); // TODO CONSIDER printing conn id
	}
};

const App = struct {
	clients: std.ArrayList(?*const ws.Conn),
	boss: ?*const ws.Conn
};
