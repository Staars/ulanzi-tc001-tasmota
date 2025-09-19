class THEATER_CHASE_RAINBOW
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var chase_pos, hue

    def init()
        self.W = 32
        self.H = 8

        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 2  # adjust for speed
        self.chase_pos = 0
        self.hue = 0

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
        self.draw_effect()
    end

    def draw_effect()
        var w = self.W
        var h = self.H
        var hue_offset = self.hue

        var y = 0
        while y < h
            var x = 0
            while x < w
                if (x + self.chase_pos) % 3 == 0
                    var hue_val = (hue_offset + (x * 256 / w)) % 256
                    self.matrix.set(x, y, hue_val, 255, 255)
                else
                    self.matrix.set(x, y, 0)  # off
                end
                x += 1
            end
            y += 1
        end

        self.strip.show()

        # Advance chase and hue
        self.chase_pos = (self.chase_pos + 1) % 3
        self.hue = (self.hue + 2) % 256
    end
end

var anim = THEATER_CHASE_RAINBOW()
