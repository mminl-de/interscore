// TODO ALL
const std = @import("std");
const ws = @import("websocket");
const log = std.log;

const Allocator = std.mem.Allocator;
const Value = std.atomic.Value;
const App = @This();

gpa: Allocator,
clients: std.ArrayList(*ws.Conn),
boss: ?*ws.Conn,

var next_id: Value(u16) = Value(u16).init(0);

/// Logs on error.
pub fn init(gpa: Allocator) !App {
	return .{
		.gpa = gpa,
		.clients = std.ArrayList(*ws.Conn).initCapacity(gpa, 10) catch |e| {
			log.err("Failed to allocate memory for the client list!", .{});
			return e;
		},
		.boss = null
	};
}

pub fn deinit(self: *App, gpa: Allocator) void {
	self.clients.deinit(gpa);
}

pub fn nextId() u16 {
	defer _ = next_id.fetchAdd(1, .monotonic);
	return next_id.raw;
}
