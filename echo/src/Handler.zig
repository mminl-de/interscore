const root = @import("root");
const std = @import("std");
const ws = @import("websocket");
const log = root.log;

const App = @import("App.zig");
const MessageType = @import("MessageType.zig").MessageType;
const Handler = @This();

id: u16,
app: *App,
conn: *ws.Conn,

/// Callback running after connection establishment has been requested
pub fn init(_: *ws.Handshake, conn: *ws.Conn, app: *App) !Handler {
	const id = App.nextId();
	log.info("Connecting client #{d} ...", .{id});
	return .{ .id = id, .app = app, .conn = conn };
}

/// Callback running after connection has been established
pub fn afterInit(hlr: *Handler, app: *App) !void {
	try hlr.app.clients.append(app.gpa, hlr.conn);
	log.info("New client connected!", .{});
}

/// Callback running when client sends message
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
			// TODO NOW ALL CHECK if were using the right conn for the write
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
		.DATA_GAME => {
			const boss = self.app.boss orelse return;
			try boss.write(data);
			for (self.app.clients.items) |client| try client.write(data);
		},
		else => for (self.app.clients.items) |client| try client.write(data)
	}
}

/// Callback running when connection is about to be terminated
pub fn close(self: *Handler) void {
	// TODO NOW separate boss and client list
	if (self.app.boss == self.conn) self.app.boss = null;

	for (self.app.clients.items) |*client| {
		if (client.* == self.conn) {
			client.* = self.app.clients.items[self.app.clients.items.len - 1];
			self.app.clients.shrinkRetainingCapacity(self.app.clients.items.len - 1);

			log.info("Client #{d} disconnected!", .{self.id});
			return;
		}
	}
	unreachable;
}
