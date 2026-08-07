const fb = @import("../drivers/framebuffer.zig");
const utils = @import("../utils.zig");
const mini_uart = @import("../drivers/mini_uart.zig");
const full_uart = @import("../drivers/full_uart.zig");
const timer = @import("../irq/timer.zig");
const font = @import("../font.zig");
const console = @import("../console.zig");
const scheduler = @import("../sched/scheduler.zig");

var sx: u32 = 50;
var sy: u32 = 50;
var targ_up: u32 = 0;
var targ_down: u32 = 0;

var su: u32 = 0;
var sd: u32 = 0;

const Ball = struct {
    old_posx: i32,
    old_posy: i32,
    posx: i32,
    posy: i32,
    velx: i32,
    vely: i32,

    pub fn updatePos(self: *Ball) void {
        self.posx += self.velx;
        self.posy += self.vely;

        fb.drawPixel(@max(self.posx, 0), @max(self.posy, 0));
        fb.drawBlankPix(@max(self.old_posx, 0), @max(self.old_posy, 0));
    }

    pub fn resetPos(self: *Ball) void {
        self.posx = 50;
        self.posy = 50;
        self.old_posx = 50;
        self.old_posy = 50;
    }

};

const Paddle = struct {
    px1: u32,
    px2: u32,
    x1: u32,
    x2: u32,
    y: u32,

    pub fn moveRight(self: *Paddle) void {
        self.x1 += 2;
        self.x2 += 2;
        fb.updateLineH(self.px1, self.px2, self.x1, self.x2, self.y);
    }

    pub fn moveLeft(self: *Paddle) void {
        self.x1 -= 2;
        self.x2 -= 2;
        fb.updateLineH(self.px1, self.px2, self.x1, self.x2, self.y);
    }

};

pub fn detect_col(ball: *Ball, paddle: *Paddle) bool {
    if (@max(ball.posy, 0) == paddle.y) {
        const bx_u: u32 = @max(ball.posx, 0);
        if (bx_u > paddle.x1 and bx_u < paddle.x2) {
            return true;
        }
        return false;
    }
    return false;
}

pub fn find_target(vx: i32, vy: i32) void {
    if (vx * vy > 0) {
        const c: i32 = @as(i32, @intCast(sy)) - @as(i32, @intCast(sx));
        targ_up = utils.clamp(10 - c, 0, 639);
        targ_down = utils.clamp(470 - c, 0, 639);
    } else {
        const c: i32 = @as(i32, @intCast(sy)) + @as(i32, @intCast(sx));
        targ_up = utils.clamp(c - 10, 0, 639);
        targ_down = utils.clamp(c - 470, 0, 639);
    }
}

pub fn start() noreturn {
    fb.init_fb();

    var ball: Ball = .{
        .old_posx = 50,
        .old_posy = 50,
        .posx = 50,
        .posy = 50,
        .velx = 2,
        .vely = 2,
    };
    
    var pad_1: Paddle = .{
        .px1 = 300,
        .px2 = 350,
        .x1 = 300,
        .x2 = 350,
        .y = 10
    };
    
    var pad_2: Paddle = .{
        .px1 = 300,
        .px2 = 350,
        .x1 = 300,
        .x2 = 350,
        .y = 470,
    };
    
    font.renderStr(0, 0, "SCORE");
    font.renderInt(50, 0, su);
    font.renderInt(70, 0, sd);

    while (true) {
        find_target(ball.velx, ball.vely);
        pad_1.px1 = pad_1.x1;
        pad_1.px2 = pad_1.x2;

        pad_2.px1 = pad_2.x1;
        pad_2.px2 = pad_2.x2;

        ball.old_posx = ball.posx;
        ball.old_posy = ball.posy;

        ball.updatePos();

        const c: u8 = mini_uart.crec();
        if (c == 'd') {
            pad_2.moveRight();
        } else if (c == 'a') {
            pad_2.moveLeft();
        }

        if (ball.vely < 0) {
            if (targ_up > pad_1.x2 - 5) {
                pad_1.moveRight();
            } else if (targ_up < pad_1.x1 + 5) {
                pad_1.moveLeft();
            }
        }
        
        if (ball.posx <= 0 or ball.posx >= 639) {
            ball.velx *= -1;
            sx = @as(u32, @intCast(ball.posx));
            sy = @as(u32, @intCast(ball.posy));
        }
        
        if (detect_col(&ball, &pad_1) or detect_col(&ball, &pad_2)) {
            ball.vely *= -1;
            sx = @as(u32, @intCast(ball.posx));
            sy = @as(u32, @intCast(ball.posy));
        }

        if (ball.posy < 10 or ball.posy > 470) {
            if (ball.posy < 10) {sd += 1;}
            else if (ball.posy > 470) {su += 1;}

            fb.drawBlankPix(@max(ball.posx, 0), @max(ball.posy, 0));

            ball.resetPos(); 
            console.print("Score: %d - %d\n", .{su, sd});

            font.clearGlyph(50, 0);
            font.clearGlyph(70, 0);
            font.renderInt(50, 0, su);
            font.renderInt(70, 0, sd);
        }

        scheduler.sleep(1);
    }
}
