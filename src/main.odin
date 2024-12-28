package main

import "core:fmt"
import "core:mem"
import "core:mem/virtual"
import os "core:os/os2"
import "core:strconv"
import "core:strings"

EXAMPLE :: #config(EXAMPLE, false)

day_proc :: proc(p1, p2: ^strings.Builder)
solutions: []day_proc = {
    d00run,
    d01run,
    d02run,
    d03run,
    d04run,
};
title : strings.Builder;

ivec2 :: struct { x, y: int };
vec2 :: struct { x, y: f32 };
date :: struct { y, m, d: int };
time :: struct { h, m: int };

main :: proc() {
    day, valid := which_day();
    if (!valid) {
        fmt.printfln("[AoC18] Solution for day %v is not implemented yet", day);
        os.exit(-1);
    }

    arena : virtual.Arena;
    palloc : mem.Allocator;
    assert(virtual.arena_init_growing(&arena) == virtual.Allocator_Error.None);
    palloc, context.allocator = context.allocator, virtual.arena_allocator(&arena);
    defer {
        context.allocator  = palloc;
        virtual.arena_free_all(&arena);
        virtual.arena_destroy(&arena);
    }

    title, _ = strings.builder_make(0, 128);
    defer strings.builder_destroy(&title);
    fmt.sbprintf(&title, "[AoC18] - Day %v", day);

    part1, _ := strings.builder_make(0, 256);
    part2, _ := strings.builder_make(0, 256);
    defer strings.builder_destroy(&part1);
    defer strings.builder_destroy(&part2);

    solutions[day](&part1, &part2);
    fmt.printfln("[AoC18] Solving Day %v", day);
    fmt.printfln(" Part1 -> %v", strings.to_string(part1));
    fmt.printfln(" Part2 -> %v", strings.to_string(part2));
}

which_day :: proc() -> (int, bool) {
    fields : os.Process_Info_Fields;
    fields = { .Command_Line, .Command_Args };

    pinfo, _ := os.current_process_info(fields, context.allocator);
    defer os.free_process_info(pinfo, context.allocator);
    /*
    fmt.println("[AoC18] Process Info :");
    fmt.printfln(" - pid = %v", pinfo.pid);
    fmt.printfln(" - cmdargs = %v", pinfo.command_args);
    fmt.println("--------------------\n");
    */

    if (len(pinfo.command_args) < 2) {
        fmt.println("[AoC18] usage: aoc18.exe <daynum>");
        os.exit(-1);
    }
    day := strconv.atoi(pinfo.command_args[1]);
    return day, ((day < len(solutions)) ? true : false);
}
