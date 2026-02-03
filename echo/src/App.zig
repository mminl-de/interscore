const std = @import("std");
const ws = @import("websocket");
const ziglog = @import("root").ziglog;

const App = @This();

clients: std.ArrayList(*const ws.Conn),
boss: ?*const ws.Conn,

pub fn init(gpa: std.mem.Allocator) !App {
	return .{
		.clients = std.ArrayList(*const ws.Conn).initCapacity(gpa, 10) catch |err| {
			ziglog.err("Failed to allocate memory for the client list!", .{});
			return err;
		},
		.bosses = null
	};
}
