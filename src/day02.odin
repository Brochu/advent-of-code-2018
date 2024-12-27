package main
import "core:c"
import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

@(private="file")
input_file :: "../data/day02.ex" when EXAMPLE else "../data/day02.in"

d02run :: proc (p1, p2: ^strings.Builder) {
    input := strings.trim(#load(input_file, string) or_else "", "\r\n");
    fmt.println(input);

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
