const std = @import("std");

// ==========================================
// 1. Data Model
// ==========================================
const UserProfile = struct {
    id: u32,
    username: []const u8,
    email: []const u8,
    is_admin: bool,
};

// ==========================================
// 2. The Interface (ReportGenerator)
// ==========================================
pub const ReportGenerator = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        generate: *const fn (ctx: *anyopaque, user: UserProfile) anyerror!void,
        deinit: *const fn (ctx: *anyopaque, allocator: std.mem.Allocator) void,
    };

    pub fn generate(self: ReportGenerator, user: UserProfile) !void {
        return self.vtable.generate(self.ptr, user);
    }

    pub fn deinit(self: ReportGenerator, allocator: std.mem.Allocator) void {
        self.vtable.deinit(self.ptr, allocator);
    }
};

// ==========================================
// 3. Concrete Implementation: JSON Report
// ==========================================
const JsonReport = struct {
    pretty_print: bool,

    pub fn generate(ctx: *anyopaque, user: UserProfile) !void {
        const self: *JsonReport = @ptrCast(@alignCast(ctx));

        // --- แก้ไขจุดที่ 1: เปลี่ยนมาใช้ std.debug.print ---
        std.debug.print("📄 [JSON Output]:\n", .{});

        if (self.pretty_print) {
            std.debug.print("{{\n  \"id\": {d},\n  \"user\": \"{s}\"\n}}\n", .{ user.id, user.username });
        } else {
            std.debug.print("{{\"id\":{d},\"user\":\"{s}\"}}\n", .{ user.id, user.username });
        }
    }

    pub fn deinit(ctx: *anyopaque, allocator: std.mem.Allocator) void {
        const self: *JsonReport = @ptrCast(@alignCast(ctx));
        allocator.destroy(self);
    }

    const vtable = ReportGenerator.VTable{
        .generate = generate,
        .deinit = deinit,
    };

    pub fn asInterface(self: *JsonReport) ReportGenerator {
        return .{ .ptr = self, .vtable = &vtable };
    }
};

// ==========================================
// 4. Concrete Implementation: HTML Report
// ==========================================
const HtmlReport = struct {
    template_name: []const u8,

    pub fn generate(ctx: *anyopaque, user: UserProfile) !void {
        const self: *HtmlReport = @ptrCast(@alignCast(ctx));

        // --- แก้ไขจุดที่ 2: เปลี่ยนมาใช้ std.debug.print ---
        std.debug.print("🌐 [HTML Output using template: {s}]:\n", .{self.template_name});
        std.debug.print("<div class='user'>\n  <h1>{s}</h1>\n  <p>Email: {s}</p>\n</div>\n", .{ user.username, user.email });
    }

    pub fn deinit(ctx: *anyopaque, allocator: std.mem.Allocator) void {
        const self: *HtmlReport = @ptrCast(@alignCast(ctx));
        allocator.destroy(self);
    }

    const vtable = ReportGenerator.VTable{
        .generate = generate,
        .deinit = deinit,
    };

    pub fn asInterface(self: *HtmlReport) ReportGenerator {
        return .{ .ptr = self, .vtable = &vtable };
    }
};

// ==========================================
// 5. The Factory & Main (เหมือนเดิม)
// ==========================================
const ReportFormat = enum {
    Json,
    Html,
};

const ReportFactory = struct {
    pub fn createGenerator(allocator: std.mem.Allocator, format: ReportFormat) !ReportGenerator {
        switch (format) {
            .Json => {
                const instance = try allocator.create(JsonReport);
                instance.* = JsonReport{ .pretty_print = true };
                return instance.asInterface();
            },
            .Html => {
                const instance = try allocator.create(HtmlReport);
                instance.* = HtmlReport{ .template_name = "standard_view" };
                return instance.asInterface();
            },
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const my_user = UserProfile{
        .id = 101,
        .username = "gemini_user",
        .email = "user@example.com",
        .is_admin = true,
    };

    // ลองเปลี่ยนเป็น .Json หรือ .Html ตรงนี้
    const desired_format = ReportFormat.Html;

    std.debug.print("--- Start Job ---\n", .{});

    const generator = try ReportFactory.createGenerator(allocator, desired_format);
    defer generator.deinit(allocator);

    try generator.generate(my_user);

    std.debug.print("--- End Job ---\n", .{});
}
