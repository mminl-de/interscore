const std = @import("std");
const ws = @import("websocket");
const root = @import("root");
const log = root.log;
const ziglog = root.ziglog;

const App = @import("App.zig");
const Handler = @This();
const MessageType = @import("MessageType.zig").MessageType;

app: *App,
conn: *ws.Conn,

// Callback running after connection establishment has been requested
pub fn init(_: *ws.Handshake, conn: *ws.Conn, app: *App) !Handler {
	log.info("Connecting new client!", .{});
	return .{ .app = app, .conn = conn };
}

// Callback running after connection has been established
pub fn afterInit(_: *Handler) !void {
	log.info("New client connected!", .{});
}

// Callback running when client sends message
pub fn clientMessage(self: *Handler, data: []const u8) !void {
	const msg: MessageType = @enumFromInt(data[0]);
	switch (msg) {
		.PLS_SEND_META,
		.PLS_SEND_META_GAME,
		.PLS_SEND_META_OBS,
		.PLS_SEND_META_WIDGETS,
		.PLS_SEND_META_TIME,
		.PLS_SEND_GAMES,
		.PLS_SEND_GAME,
		.PLS_SEND_GAMEACTIONS,
		.PLS_SEND_GAMEACTION,
		.PLS_SEND_FORMATS,
		.PLS_SEND_FORMAT,
		.PLS_SEND_TEAMS,
		.PLS_SEND_TEAM,
		.PLS_SEND_GROUPS,
		.PLS_SEND_GROUP,
		.PLS_SEND_TIMESTAMP,
		.PLS_SEND_JSON => {
			// Forwarding to frontend
			try self.conn.write(data);
		},
		.PLS_SEND_IM_BOSS => {
			const msg_byte: u8 = @intFromEnum(MessageType.DATA_IM_BOSS);
			const is_boss: u8 = @intFromBool(self.conn == self.app.boss);
			try self.conn.write(&.{msg_byte, is_boss});
		},
		.IM_THE_BOSS => {
			// TODO
		},
		else => for (self.app.clients.items) |client| {
			if (client == self.app.boss and msg != .DATA_GAME) continue;
			// TODO message: sending to conn <id>
			try self.conn.write(data);
		}
	}
}

// Callback running when connection is about to be terminated
pub fn close(self: *Handler) void {
	// TODO NOW separate boss and client list
	if (self.app.boss == self.conn) self.app.boss = null;
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
