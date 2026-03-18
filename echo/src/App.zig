// TODO ALL
const std = @import("std");
const log = std.log;

const Allocator = std.mem.Allocator;
const Value = std.atomic.Value;
const WebSocket = std.http.Server.WebSocket;
const Client = @import("Client.zig");
const App = @This();

gpa: Allocator,
clients: std.ArrayList(Client),
boss: ?Client,

var id_counter: Value(u8) = Value(u8).init(0);

/// Logs on error.
pub fn init(gpa: Allocator) !App {
	return .{
		.gpa = gpa,
		.clients = std.ArrayList(Client).initCapacity(gpa, 10) catch |e| {
			log.err("Failed to allocate memory for the client list!", .{});
			return e;
		},
		.boss = null
	};
}

pub fn deinit(self: *App, gpa: Allocator) void {
	self.clients.deinit(gpa);
}

/// Adds new client connection to list of clients.
/// Utilizes internal `.gpa` field as allocator, thus shamelessly violating the Zig zen.
/// Just logs on error.
pub fn addConnection(self: *App, ws: *WebSocket) Allocator.Error!Client {
	self.clients.append(self.gpa, Client{ .ws = ws, .id = newId() }) catch |e| {
		log.err("Failed to allocate memory for client list!", .{});
		return e;
	};
}

/// Removes client connection from list of clients.
/// Asserts that `ws` is contained in `self.clients.items`.
/// Doesn't log.
pub fn removeConnection(self: *App, ws: *WebSocket) void {
	const items = &self.clients.items;
	if (ws == self.boss) self.boss = null;

	for (items.*, 0..) |*client, i| {
		if (client.ws != ws) continue;
		items[i] = items[items.len - 1];
		self.clients.shrinkRetainingCapacity(items.len - 1);
		return;
	}
	unreachable;
}

/// Increments atomic, wrapping 8-bit integer.
fn newId() u8 {
	defer _ = id_counter.fetchAdd(1, .monotonic);
	return id_counter.raw;
}
