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
entries: map[DateTime]int;

@(private="file")
Log :: struct {
    guard: int,
    swaps: []u8,
};

@(private="file")
logs: map[Date]Log;

d04run :: proc (p1, p2: ^strings.Builder) {
    input := strings.trim(#load(input_file, string) or_else "", "\r\n");
    lines := strings.split_lines(input);
    entries = make(map[DateTime]int);
    for line, i in lines {
        data := strings.split_n(line, "] ", 2);
        datetime := strings.split_n(data[0][1:], " ", 2);
        date_es := strings.split(datetime[0], "-");
        time_es := strings.split(datetime[1], ":");
        dt := DateTime{
            Date{ strconv.atoi(date_es[0]), strconv.atoi(date_es[1]), strconv.atoi(date_es[2]) },
            Time{ strconv.atoi(time_es[0]), strconv.atoi(time_es[1]) },
        };

        if _, ok := &entries[dt]; !ok do entries[dt] = -1;

        if sharp_idx := strings.index_byte(data[1], '#'); sharp_idx >= 0 {
            entry := &entries[dt];
            entry^ = strconv.atoi(data[1][sharp_idx+1:]);
        }
    }
    ds, _ := slice.map_keys(entries);
    slice.sort_by(ds, datetime_sort);

    logs = make(map[Date]Log);
    curr_guard := -1;
    for dt in ds {
        if entries[dt] > -1 {
            curr_guard = entries[dt];
            continue;
        }
        else {
            if _, ok := &logs[dt.date]; !ok do logs[dt.date] = Log{ -1, make([]u8, 60) };
            log := &logs[dt.date];
            log.guard = curr_guard;
            log.swaps[dt.time.m] = 1;
        }
    }
    log_keys, _ := slice.map_keys(logs);
    slice.sort_by(log_keys, date_sort);

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
        for date, i in log_keys {
            l := logs[date];
            strings.write_int(&sb, date.m);
            strings.write_string(&sb, " - ");
            strings.write_int(&sb, date.d);
            strings.write_string(&sb, " [");
            strings.write_int(&sb, l.guard);
            strings.write_string(&sb, "] : ");

            state := true;
            for i in 0..<60 {
                if l.swaps[i] == 1 do state = !state;
                char := "." if state else "#";
                strings.write_string(&sb, char);
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
date_sort :: proc (l, r: Date) -> bool {
    if l.y != r.y do return l.y < r.y;
    if l.m != r.m do return l.m < r.m;
    if l.d != r.d do return l.d < r.d;
    return false;
}

@(private="file")
datetime_sort :: proc (l, r: DateTime) -> bool {
    if l.date.y != r.date.y do return l.date.y < r.date.y;
    if l.date.m != r.date.m do return l.date.m < r.date.m;
    if l.date.d != r.date.d do return l.date.d < r.date.d;
    if l.time.h != r.time.h do return l.time.h < r.time.h;
    if l.time.m != r.time.m do return l.time.m < r.time.m;
    return false;
}
