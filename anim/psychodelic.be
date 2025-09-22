

###############################

import math

#@ solidify:PSYCHEDELIC_SCROLL_LAYERED
class PSYCHEDELIC_SCROLL_LAYERED
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    var offset_x, offset_y
    var dir_x, dir_y
    var change_dir_tick
    var zoom_phase_x, zoom_phase_y

    def init()
        self.strip = Leds(32 * 8, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = pixmat(buf, 32, 8, bpp, true)

        self.tick = 0
        self.frame_div = 3  # slower updates

        self.offset_x = 0.0
        self.offset_y = 0.0
        self.dir_x = 0.2
        self.dir_y = 0.0
        self.change_dir_tick = 0

        self.zoom_phase_x = 0.0
        self.zoom_phase_y = math.pi / 2

        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_driver(self)
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0
            return
        end

        # Occasionally change scroll direction
        if self.tick - self.change_dir_tick > 150
            import crypto
            self.dir_x = ((crypto.random(1)[0] % 3) - 1) * 0.3
            self.dir_y = ((crypto.random(1)[0] % 3) - 1) * 0.3
            if self.dir_x == 0 && self.dir_y == 0
                self.dir_x = 0.3
            end
            self.change_dir_tick = self.tick
        end

        self.offset_x += self.dir_x
        self.offset_y += self.dir_y

        # Advance zoom phases
        self.zoom_phase_x += 0.04
        self.zoom_phase_y += 0.05
        if self.zoom_phase_x > math.pi * 2
            self.zoom_phase_x -= math.pi * 2
        end
        if self.zoom_phase_y > math.pi * 2
            self.zoom_phase_y -= math.pi * 2
        end

        self.draw()
    end

    def draw()
        var t = self.tick
        var zoom_x = 1.0 + 0.25 * math.sin(self.zoom_phase_x)
        var zoom_y = 1.0 + 0.25 * math.sin(self.zoom_phase_y)

        for y:0..7
            for x:0..31
                var zx = (x - 16) * zoom_x + 16
                var zy = (y - 4) * zoom_y + 4

                # First plasma layer
                var v1a = math.sin((zx + self.offset_x) / 6.0 + t / 40.0)
                var v1b = math.sin((zy + self.offset_y) / 6.0 - t / 55.0)
                var v1c = math.sin(((zx + self.offset_x) + (zy + self.offset_y)) / 6.0 + t / 70.0)
                var hue1 = ((v1a + v1b + v1c) / 3.0 + 1) * 180

                # Second plasma layer (different scale/speed/offset)
                var v2a = math.sin((zx * 1.3 + self.offset_x * 0.7) / 5.0 - t / 60.0)
                var v2b = math.sin((zy * 1.3 + self.offset_y * 0.7) / 5.0 + t / 45.0)
                var v2c = math.sin(((zx * 1.3 + self.offset_x * 0.7) - (zy * 1.3 + self.offset_y * 0.7)) / 5.0 - t / 80.0)
                var hue2 = ((v2a + v2b + v2c) / 3.0 + 1) * 180 + 120  # offset hue

                # Blend hues by averaging
                var hue = int(((hue1 + hue2) / 2.0) % 360)
                self.matrix.set(x, y, hue,255,255)
            end
        end
        self.strip.show()
    end
end

var anim = PSYCHEDELIC_SCROLL_LAYERED()

