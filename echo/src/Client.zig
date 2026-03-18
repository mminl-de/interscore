const std = @import("std");
const log = std.log;

const WebSocket = std.http.Server.WebSocket;
const Client = @This();

ws: *WebSocket,
id: u8,

/// Wrapper around `std.http.Server.WebSocket.writeMessage`.
/// Logs on error.
fn writeMsgBin(self: *Client, data: []const u8) void {
	self.ws.writeMessage(data, .binary) catch |e|
		log.err("Client #{d} failed to echo message: {s}", .{self.id, @errorName(e)});
}
