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

    fmt.println("ENTRIES:");
    for e in entries {
        fmt.printfln("    %v", e);
    }

    strings.write_int(p1, 00);
    strings.write_int(p2, 00);

    /*
    rl.InitWindow(800, 600, strings.to_cstring(&title));
    rl.SetTargetFPS(60);
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);

        rl.EndDrawing();
    }
    rl.CloseWindow();
    */
}
