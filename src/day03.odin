package main
import "core:c"
import "core:fmt"
import "core:math"
import "core:slice"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

@(private="file")
input_file :: "../data/day03.ex" when EXAMPLE else "../data/day03.in"

@(private="file")
Claim :: struct { pos, size: ivec2 };

@(private="file")
overlaps: map[ivec2]int;

@(private="file")
OColors: []rl.Color = {
    rl.BLACK,
    rl.SKYBLUE,
    rl.BLUE,
    rl.RED,
    rl.GREEN,
    rl.YELLOW,
    rl.PINK,
    rl.MAROON,
};

d03run :: proc (p1, p2: ^strings.Builder) {
    input := strings.trim(#load(input_file, string) or_else "", "\r\n");
    lines := strings.split_lines(input);
    claims := make([]Claim, len(lines));

    for l, i in lines {
        elems := strings.split_n(strings.split_n(l, " @ ", 2)[1], ": ", 2);
        pos := strings.split_n(elems[0], ",", 2);
        size := strings.split_n(elems[1], "x", 2);

        claims[i] = Claim {
            {strconv.atoi(pos[0]), strconv.atoi(pos[1])},
            {strconv.atoi(size[0]), strconv.atoi(size[1])},
        };
    }

    min: ivec2;
    max: ivec2;
    //fmt.println("CLAIMS:");
    for c in claims {
        min.x, min.y = math.min(min.x, c.pos.x), math.min(min.y, c.pos.y);
        max.x, max.y = math.max(max.x, c.pos.x + c.size.x), math.max(max.y, c.pos.y + c.size.y);

        //fmt.printfln("    %v", c);
        for y in c.pos.y..<(c.pos.y + c.size.y) do for x in c.pos.x..<(c.pos.x + c.size.x) {
            overlaps[{ x, y }] += 1;
        }
    }
    //fmt.printfln("MIN: %v", min);
    //fmt.printfln("MAX: %v", max);

    res_p1 := 0;
    for _, v in overlaps {
        if v > 1 {
            res_p1 += 1;
        }
    }

    res_p2 := 0;
    for c, i in claims {
        if !check_overlap(c) {
            res_p2 = i + 1;
            break;
        }
    }

    strings.write_int(p1, res_p1);
    strings.write_int(p2, res_p2);

    spacing: c.int : 50 when EXAMPLE else 2;
    minus: c.int : 5 when EXAMPLE else 0;
    offset: c.int : 225 when EXAMPLE else 0;
    margin :: 2 when EXAMPLE else 0;
    dims :: 800 when EXAMPLE else 1000;
    rl.InitWindow(dims, dims, strings.to_cstring(&title));
    rl.SetTargetFPS(60);
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);

        for y in (min.y - margin)..<(max.y + margin) do for x in (min.x - margin)..<(max.x + margin) {
            xpos := c.int(x) * spacing;
            ypos := c.int(y) * spacing;
            p: ivec2 = { x, y };

            color_idx := overlaps[p] or_else 0;
            rl.DrawRectangleLines(xpos+offset, ypos+offset, spacing-minus, spacing-minus, OColors[color_idx]);
        }

        rl.EndDrawing();
    }
    rl.CloseWindow();
}

check_overlap :: proc (c: Claim) -> bool {
    for y in c.pos.y..<(c.pos.y + c.size.y) do for x in c.pos.x..<(c.pos.x + c.size.x) {
        if num, _ := overlaps[{ x, y }]; num > 1 {
            return true;
        }
    }

    return false;
}
