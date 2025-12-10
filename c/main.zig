const std = @import("std");
const expect = std.testing.expect;

fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn main() !void {
    const add_result = add(3, 4);
    std.debug.print("3 + 4 = {}\n", .{add_result});
    std.debug.print("Hello from Zig!\n", .{});

    // create array
    const a = [5]i32{ 1, 2, 3, 4, 5 };
    std.debug.print("a length: {}\n", .{a.len});
    std.debug.print("", .{});
}

test "if statement" {
    const a = true;
    var x: u16 = 0;
    if (a) {
        x += 1;
    } else {
        x += 2;
    }
    try expect(x == 1);
}

test "if statement expression" {
    const a = true;
    var x: u16 = 0;
    x += if (a) 1 else 2;
    try expect(x == 1);
}

test "while" {
    var i: u8 = 2;
    while (i < 100) {
        i *= 2;
    }
    try expect(i == 128);
}

test "while with continue expression" {
    var sum: u8 = 0;
    var i: u8 = 1;
    while (i <= 10) : (i += 1) {
        sum += i;
    }
    try expect(sum == 55);
}

test "for" {
    const string = [_]u8{ 'H', 'e', 'l', 'l', 'o' };

    for (string, 0..) |character, index| {
        _ = character;
        _ = index;
    }

    for (string) |character| {
        _ = character;
    }

    for (string, 0..) |_, index| {
        _ = index;
    }

    for (string) |_| {}
}
fn add_five(x: u32) u32 {
    return x + 5;
}
test "function" {
    const y = add_five(0);
    try expect(@TypeOf(y) == u32);
    try expect(y == 5);
}
fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

test "function recursion" {
    const x = fibonacci(10);
    try expect(x == 55);
}

test "defer" {
    var x: i16 = 5;
    {
        defer x += 2;
        try expect(x == 5);
    }
    try expect(x == 7);
}

test "multi defer" {
    var x: f32 = 5;
    {
        defer x += 2;
        defer x /= 2;
    }
    try expect(x == 4.5);
}

const file_open_error = error{
    access_denied,
    out_of_memory,
    file_not_found,
};

const allcation_error = error{out_of_memory};

test "coerce error from a subset to a superset" {
    const err: file_open_error = allcation_error.out_of_memory;
    try expect(err == file_open_error.out_of_memory);
}

test "error union" {
    const maybe_error: allcation_error!u16 = 10;
    const no_error = maybe_error catch 0;
    try expect(@TypeOf((no_error) == u16));
    try expect(no_error == 10);
}

fn failing_function() error{Oops}!void {
    return error.Oops;
}

test "returning an error" {
    failing_function() catch |err| {
        try expect(err == error.Oops);
        return;
    };
}

fn fail_fn() error{Oops}!i32 {
    try failing_function();
    return 12;
}

test "try" {
    const v = fail_fn() catch |err| {
        try expect(err == error.Oops);
        return;
    };
    try expect(v == 12);
}

var problems: u32 = 98;

fn fail_fn_counter() error{Oops}!void {
    errdefer problems += 1;
    try failing_function();
}

test "errdefer" {
    fail_fn_counter() catch |err| {
        try expect(err == error.Oops);
        try expect(problems == 99);
        return;
    };
}

fn create_file() !void {
    return error.access_denied;
}

test "inferred error set" {
    const x: error{access_denied}!void = create_file();
    _ = x catch {};
}

const A = error{ Not_Dir, Path_Not_Found };
const B = error{ out_of_memory, path_not_found };
const C = A || B;

test "basic test" {
    // Tests for your main application or utility functions
    std.debug.assert(1 + 1 == 2);
}
