package main
import "core:c"
import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

@(private="file")
input_file :: "../data/day04.ex" when EXAMPLE else "../data/day04.in"

@(private="file")
State :: enum u8 {
    START,
    WAKEUP,
    ASLEEP,
}

@(private="file")
Log :: struct {
    guard: int,
    swaps: []u8,
}

@(private="file")
logs: map[date]Log;

d04run :: proc (p1, p2: ^strings.Builder) {
    input := strings.trim(#load(input_file, string) or_else "", "\r\n");
    lines := strings.split_lines(input);
    logs = make(map[date]Log);
    for line, i in lines {
        data := strings.split_n(line, "] ", 2);
        datetime := strings.split_n(data[0][1:], " ", 2);
        date_es := strings.split(datetime[0], "-");
        d := date{ strconv.atoi(date_es[0]), strconv.atoi(date_es[1]), strconv.atoi(date_es[2]) }
        time_es := strings.split(datetime[1], ":");
        t := time{ strconv.atoi(time_es[0]), strconv.atoi(time_es[1]) }

        if _, ok := &logs[d]; !ok do logs[d] = Log{ -1, make([]u8, 60) };

        if sharp_idx := strings.index_byte(data[1], '#'); sharp_idx >= 0 {
            entry := &logs[d];
            entry.guard = strconv.atoi(data[1][sharp_idx+1:]);
        }
        else {
            entry := &logs[d];
            entry.swaps[t.m] = 1;
        }
    }
    ds, _ := slice.map_keys(logs);
    slice.sort_by(ds, date_sort);
    fmt.printfln("[%v] dates: %v", len(ds), ds);

    strings.write_int(p1, 00);
    strings.write_int(p2, 00);

    cam: rl.Camera2D = {
        { 0, 0 },
        { 0, 0 },
        0,
        1,
    };
    fsize: c.float : 20;
    xoff, yoff: c.float : 25, 75;
    scroll_speed: c.float : 60;
    sb: strings.Builder;
    strings.builder_init(&sb, 0, 255);
    rl.InitWindow(800, 800, strings.to_cstring(&title));
    rl.SetTargetFPS(60);
    font := rl.LoadFont("./data/JBM-Medium.ttf");
    for !rl.WindowShouldClose() {
        wheel_move := rl.GetMouseWheelMove();
        if (wheel_move != 0) do cam.offset.y += wheel_move * scroll_speed;

        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);

        rl.BeginMode2D(cam);
        for date, i in ds {
            l := logs[date];
            strings.write_int(&sb, date.m);
            strings.write_string(&sb, " - ");
            strings.write_int(&sb, date.d);
            strings.write_string(&sb, " [");
            strings.write_int(&sb, l.guard);
            strings.write_string(&sb, "]");

            state := true;
            for s in l.swaps {
                if s == 1 do state = !state;
                strings.write_string(&sb, "." if state else "#");
            }

            ypos := (fsize * c.float(i)) + yoff;
            rl.DrawTextEx(font, strings.to_cstring(&sb), { xoff, ypos }, fsize, 1, rl.WHITE);
            strings.builder_reset(&sb);
        }
        rl.EndMode2D();

        rl.EndDrawing();
    }
    rl.CloseWindow();
}

@(private="file")
date_sort :: proc (l, r: date) -> bool {
    if l.y != r.y do return l.y < r.y;
    if l.m != r.m do return l.m < r.m;
    if l.d != r.d do return l.d < r.d;
    return false;
}
