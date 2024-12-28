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
Entry :: struct {
    date: date,
    time: time,
    guard: int,
    state: State,
}

d04run :: proc (p1, p2: ^strings.Builder) {
    input := strings.trim(#load(input_file, string) or_else "", "\r\n");
    lines := strings.split_lines(input);
    entries := make([]Entry, len(lines));
    for line, i in lines {
        data := strings.split_n(line, "] ", 2);
        datetime := strings.split_n(data[0][1:], " ", 2);
        date_es := strings.split(datetime[0], "-");
        time_es := strings.split(datetime[1], ":");

        sharp_idx := strings.index_byte(data[1], '#');
        gid := -1;
        s: State;
        if sharp_idx == -1 {
            s = State.WAKEUP if strings.contains(data[1], "wake") else State.ASLEEP;
        }
        else {
            gid = strconv.atoi(data[1][sharp_idx+1:]);
            s = State.START;
        }

        entries[i] = Entry{
            { strconv.atoi(date_es[0]), strconv.atoi(date_es[1]), strconv.atoi(date_es[2]) },
            { strconv.atoi(time_es[0]), strconv.atoi(time_es[1]) },
            gid, s };
    }
    slice.sort_by(entries, sort);
    fmt.println("ENTRIES:");
    for e in entries {
        fmt.printfln("    %2.0v", e);
    }

    strings.write_int(p1, 00);
    strings.write_int(p2, 00);

    sb: strings.Builder;
    strings.builder_init(&sb, 0, 255);
    height: c.float : 23 when EXAMPLE else 5;
    fsize: c.float : 23 when EXAMPLE else 5;
    curr_y: c.float = 0;
    xoff: c.float : 25;
    yoff: c.float : 100;
    rl.InitWindow(800, 600, strings.to_cstring(&title));
    rl.SetTargetFPS(60);

    font := rl.LoadFont("./data/JBM-Medium.ttf");
    fmt.printfln("%v", font);
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);

        for m in entries[0].date.m..=entries[len(entries)-1].date.m {
            for d in entries[0].date.d..=entries[len(entries)-1].date.d {
                strings.write_int(&sb, m);
                strings.write_string(&sb, "-");
                strings.write_int(&sb, d);
                strings.write_string(&sb, " ");
                for minute in 0..<60 {
                    strings.write_string(&sb, ".");
                }

                rl.DrawTextEx(font, strings.to_cstring(&sb), { xoff, curr_y + yoff }, fsize, 1, rl.WHITE);
                curr_y += height;
                strings.builder_reset(&sb);
            }
        }

        curr_y = 0;
        rl.EndDrawing();
    }
    rl.CloseWindow();
}

@(private="file")
sort :: proc (l, r: Entry) -> bool {
    if l.date.y != r.date.y do return l.date.y < r.date.y;
    if l.date.m != r.date.m do return l.date.m < r.date.m;
    if l.date.d != r.date.d do return l.date.d < r.date.d;
    if l.time.h != r.time.h do return l.time.h < r.time.h;
    if l.time.m != r.time.m do return l.time.m < r.time.m;
    return false;
}
