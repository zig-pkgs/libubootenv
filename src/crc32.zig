const std = @import("std");

/// C-ABI compatible implementation of zlib's `crc32` backed by `std.hash.Crc32`.
export fn crc32(crc: c_ulong, buf: ?[*]const u8, len: c_uint) callconv(.c) c_ulong {
    const data = if (buf) |ptr| ptr[0..len] else return 0;
    var hasher: std.hash.Crc32 = .{ .crc = @as(u32, @truncate(crc)) ^ 0xffffffff };
    hasher.update(data);
    return hasher.final();
}

test "crc32 matches standard ISO-HDLC / zlib vectors" {
    try std.testing.expectEqual(@as(c_ulong, 0), crc32(0, null, 0));
    try std.testing.expectEqual(@as(c_ulong, 0), crc32(0x12345678, null, 4));
    try std.testing.expectEqual(@as(c_ulong, 0), crc32(0, "abc", 0));
    try std.testing.expectEqual(@as(c_ulong, 0x12345678), crc32(0x12345678, "abc", 0));

    const check = "123456789";
    try std.testing.expectEqual(@as(c_ulong, 0xcbf43926), crc32(0, check.ptr, check.len));

    const part1 = crc32(0, check[0..4].ptr, 4);
    const part2 = crc32(part1, check[4..].ptr, check.len - 4);
    try std.testing.expectEqual(@as(c_ulong, 0xcbf43926), part2);
}
