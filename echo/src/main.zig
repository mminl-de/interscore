// TODO FINAL ALL ASK can we always safely assume app.boss != null?
const std = @import("std");
const http = std.http;
const log = std.log;

const Address = std.net.Address;
const Server = std.net.Server;
const WebSocket = http.Server.WebSocket;
const AllocatorWrapper = @import("AllocatorWrapper.zig");
const App = @import("App.zig");
const Client = @import("Client.zig");
const MessageType = @import("MessageType.zig").MessageType;

const default_addr_str = "127.0.0.1";
const default_port = 8080;
const default_addr: Address =
	Address.parseIp(default_addr_str, default_port) catch unreachable;
const help_text = std.fmt.comptimePrint(
	\\interscore-echo (v0.0.1) - Interscore's internal echo server
	\\
	\\Usage: interscore-echo [ADDRESS [PORT]]
	\\
	\\Options:
	\\    ADDRESS  IP address          (default: {s})
	\\    PORT     16-bit port number  (default: {d})
	\\
	, .{default_addr_str, default_port}
);

pub fn main() u8 {
	var aw = AllocatorWrapper.init();
	defer aw.deinit();
	const gpa = aw.allocator();

	const addr: Address, const addr_str: []const u8, const port: u16 = addr: {
		var args = std.process.args();
		_ = args.skip(); // Skip executable name

		const addr_str: []const u8 = args.next() orelse
			break :addr .{default_addr, default_addr_str, default_port};
		if (std.mem.eql(u8, addr_str, "--help")) return help();

		const port_str: []const u8 = args.next() orelse {
			const addr = Address.parseIp(addr_str, default_port) catch |e| {
				log.err("Couldn't parse IP address: {s}", .{@errorName(e)});
				return 1;
			};
			break :addr .{addr, addr_str, default_port};
		};

		const port = std.fmt.parseInt(u16, port_str, 10) catch {
			log.err("'{s}' is not a valid port number!", .{port_str});
			return 1;
		};
		const addr = Address.parseIp(addr_str, port) catch |e| {
			log.err("Couldn't parse IP address: {s}", .{@errorName(e)});
			return 1;
		};
		break :addr .{addr, addr_str, port};
	};

	// TODO OPTIMIZE: timeout, max_size, max_headers (as in websocket.zig)
	var server = Address.listen(addr, .{ .reuse_address = true }) catch {
		log.err("Failed to get server to listen!", .{});
		return 71;
	};
	defer server.deinit();

	var app = App.init(gpa) catch return 1;
	defer app.deinit();

	log.info("Listening at {s}:{d}...", .{addr_str, port});

	// TODO Ctrl-C handling
	// TODO CONSIDER other keybindings, like q
	while (true) {
		const conn: Server.Connection = server.accept() catch |e| {
			log.err("Failed to accept connection: {s}", .{@errorName(e)});
			continue;
		};
		const thread = std.Thread.spawn(.{}, accept, .{conn, &app}) catch |e| {
			log.err("Failed to spawn connection thread: {s}", .{@errorName(e)});
			conn.stream.close();
			continue;
		};
		thread.detach();
	}

	return 0;
}

/// Prints help message and returns exit code to use.
fn help() u8 {
	var stdout_wrapper = std.fs.File.stdout().writer(&.{});
	_ = stdout_wrapper.interface.writeAll(help_text) catch return 71;
	return 0;
}

/// Handler for accepting new client.
fn accept(conn: Server.Connection, app: *App) void {
	defer conn.stream.close();

	// TODO HANDLE
	log.info("Connected new client at {f}!", .{conn.address});

	var reader_buf: [8192]u8 = undefined;
	var writer_buf: [128]u8 = undefined;
	var reader_wrapper = conn.stream.reader(&reader_buf);
	var writer_wrapper = conn.stream.writer(&writer_buf);
	var server = http.Server.init(reader_wrapper.interface(), &writer_wrapper.interface);

	while (server.reader.state == .ready) {
		var request = server.receiveHead() catch |e| switch (e) {
			error.HttpConnectionClosing => return,
			else => {
				log.err("Failed receiving head: {s}", .{@errorName(e)});
				return;
			}
		};
		switch (request.upgradeRequested()) {
			.other => |protocol| {
				log.err("Unsupported protocol: {s}", .{protocol});
				return;
			},
			.websocket => |key| {
				const ws = request.respondWebSocket(.{ .key = key orelse "" }) catch |e| {
					log.err("Failed upgrading to WebSocket: {s}", .{@errorName(e)});
					return;
				};
				const new_client: *const Client = app.addConnection(ws);
				serveWebSocket(new_client, &app);
			},
			.none => {}
		}
	}
}

/// Handle for incoming WebSocket messages
fn serveWebSocket(client: *const Client, app: *App) void {
	client.ws.writeMessage("Hello from echo WebSocket server!", .text) catch {};

	while (true) {
		const msg: WebSocket.SmallMessage = client.ws.readSmallMessage() catch |e| {
			log.err("Failed to read message from client: {s}", .{@errorName(e)});
			return;
		};
		if (msg.opcode == .connection_close) {
			// TODO NOW
			app.removeConnection(client.ws);
			log.info("Client closed WebSocket!", .{});
			return;
		}
		switch (@as(MessageType, @enumFromInt(msg.data[0]))) {
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
				// Forwaring to frontend
				app.boss.?.writeMsgBin(msg.data);
			},
			.PLS_SEND_IM_BOSS => {
				client.writeMsgBin(&.{
					@intFromEnum(MessageType.DATA_IM_BOSS),
					@intFromBool(client.ws == app.boss.?)
				});
			},
			.IM_THE_BOSS => {
				// TODO ASK why?
				if (msg.data.len < 2 or msg.data[1] == 0) {
					log.err("Boss sent illegal message!", .{});
					return;
				}

				if (app.boss) |boss| {
					log.info("Connection is trying to be boss, but is already!", .{});
					if (client.ws == boss) {
						// TODO FINAL ADD ids
						log.info("Sending DATA_IM_BOSS ...", .{});
						app.boss.?.writeMsgBin(&.{
							@intFromEnum(MessageType.DATA_IM_BOSS),
							@intFromBool(true)
						});
					}
					return;
				}

				// TODO ADD ids
				log.info("Setting new boss ...", .{});
				app.boss = client.ws;

				app.boss.?.writeMsgBin(&.{
					@intFromEnum(MessageType.DATA_IM_BOSS),
					@intFromBool(true)
				});

				return;
			},
			.DATA_GAME => {
				const boss = app.boss orelse return;
				boss.writeMsgBin(msg.data);
				for (app.clients.items) |cl| cl.writeMsgBin(msg.data);
			},
			else => for (app.clients.items) |cl| cl.writeMsgBin(msg.data)
		}

		client.ws.writeMessage(msg.data, msg.opcode) catch |e| {
			log.err("Failed to echo message: {s}", .{@errorName(e)});
			return;
		};
	}
}
