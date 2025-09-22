class RAINBOW_CYCLE
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var hue_offset

    def init()
        self.W = 32
        self.H = 8

        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = pixmat(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 2  # adjust for speed
        self.hue_offset = 0

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
        self.draw_rainbow()
    end

    def draw_rainbow()
        var w = self.W
        var h = self.H
        var hue_base = self.hue_offset

        var y = 0
        while y < h
            var x = 0
            while x < w
                var hue_val = (hue_base + (x * 256 / w)) % 256
                self.matrix.set(x, y, hue_val, 255, 255)
                x += 1
            end
            y += 1
        end

        self.strip.show()

        # Advance hue for animation
        self.hue_offset = (self.hue_offset + 1) % 256
    end
end

var anim = RAINBOW_CYCLE()
