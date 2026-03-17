const std = @import("std");
const log = std.log;

const Address = std.net.Address;
const Server = std.net.Server;
const AllocatorWrapper = @import("AllocatorWrapper.zig");
const App = @import("App.zig");
const Handler = @import("Handler.zig");
const MessageType = @import("MessageType.zig").MessageType;

const default_addr_str = "127.0.0.1";
const default_port = 8080;
const default_addr: Address =
	Address.parseIp(default_addr_str, default_port) catch unreachable;
const help_text = std.fmt.comptimePrint(
	\\interscore-echo - Interscore's internal echo server
	\\v0.0.1
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
	_ = gpa;

	const addr: Address, const addr_str: []const u8, const port: u16 = addr: {
		var args = std.process.args();
		_ = args.skip(); // Skip executable name

		const addr_str: []const u8 = args.next() orelse
			break :addr .{default_addr, default_addr_str, default_port};
		if (std.mem.eql(u8, addr_str, "--help")) return help();

		const port_str: []const u8 = args.next() orelse {
			const addr = Address.parseIp(addr_str, default_port) catch |e| {
				log.err("Error parsing IP address: {s}", .{@errorName(e)});
				return 1;
			};
			break :addr .{addr, addr_str, default_port};
		};

		const port = std.fmt.parseInt(u16, port_str, 10) catch {
			log.err("'{s}' is not a valid port number!", .{port_str});
			return 1;
		};
		const addr = Address.parseIp(addr_str, port) catch |e| {
			log.err("Error parsing IP address: {s}", .{@errorName(e)});
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

	log.info("Listening at {s}:{d}...", .{addr_str, port});

	// TODO Ctrl-C handling
	// TODO CONSIDER other keybindings, like q
	while (true) {
		const conn: Server.Connection = server.accept() catch |e| {
			log.err("Failed to accept connection: {s}", .{@errorName(e)});
			continue;
		};
		const thread = std.Thread.spawn(.{}, accept, .{conn}) catch |e| {
			log.err("Failed to spawn connection thread: {s}", .{@errorName(e)});
			conn.stream.close();
			continue;
		};
		thread.detach();
	}

	// TODO init App
	return 0;
}

/// Prints help message and returns exit code to use.
fn help() u8 {
	var stdout_wrapper = std.fs.File.stdout().writer(&.{});
	_ = stdout_wrapper.interface.writeAll(help_text) catch return 71;
	return 0;
}

/// Handler for accepting new client!
fn accept(conn: Server.Connection) !void {
	defer conn.stream.close();

	log.info("Connected new client at {f}!", .{conn.address});

	// TODO NOW
}
