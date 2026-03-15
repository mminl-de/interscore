const builtin = @import("builtin");
const std = @import("std");
const DebugAllocator = std.heap.DebugAllocator(.{});
/// Comptime wrapper that resolves to the slow but helpful `DebugAllocator` in
/// Debug mode and the performant but dangerous `smp_allocator` in all the other modes.
const Self = @This();

dbg_state: if (is_debug) DebugAllocator else void,

const is_debug = builtin.mode == .Debug;

/// Initialize Zig's `DebugAllocator`.
pub fn init() Self {
	return if (is_debug) .{ .dbg_state = DebugAllocator.init } else .{ .dbg_state = {} };
}

/// Return the `DebugAllocator`'s allocator.
pub fn allocator(self: *Self) std.mem.Allocator {
	return if (is_debug) self.dbg_state.allocator() else std.heap.smp_allocator;
}

/// Deinit Zig's `DebugAllocator` and log an error message if
/// the program contains Zig-side memory leaks.
pub fn deinit(self: *Self) void {
	if (is_debug) _ = self.dbg_state.deinit();
}
