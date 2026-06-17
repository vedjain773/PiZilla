const font = @import("font.zig");
const scheduler = @import("scheduler.zig");

var seconds: u8 = 0;
var minutes: u8 = 0;

pub fn update() noreturn {
    while (true) {
        seconds += 1;

        if (seconds == 60) {
            minutes += 1;
            seconds = 0;

            font.clearGlyph(600, 0);
            font.clearGlyph(610, 0);
            font.renderInt(600, 0, minutes / 10);
            font.renderInt(610, 0, minutes % 10);
        }

        font.clearGlyph(620, 0);
        font.clearGlyph(630, 0);
        font.renderInt(620, 0, seconds / 10);
        font.renderInt(630, 0, seconds % 10);

        scheduler.sleep(5);
    }
}
