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
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

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

    def hsv_to_rgb(h, s, v)
        var r, g, b
        var i = (h / 43) % 6
        var f = (h % 43) * 6
        var p = (v * (255 - s)) / 255
        var q = (v * (255 - ((s * f) / 255))) / 255
        var t = (v * (255 - ((s * (255 - f)) / 255))) / 255
        if i == 0
            r = v; g = t; b = p
        elif i == 1
            r = q; g = v; b = p
        elif i == 2
            r = p; g = v; b = t
        elif i == 3
            r = p; g = q; b = v
        elif i == 4
            r = t; g = p; b = v
        else
            r = v; g = p; b = q
        end
        return (r << 16) | (g << 8) | b
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
                var col = self.hsv_to_rgb(hue_val, 255, 255)
                self.matrix.set(x, y, col)
                x += 1
            end
            y += 1
        end

        self.strip.show()

        # Advance hue for animation
        self.hue_offset = (self.hue_offset + 1) % 256
    end
end

var rainbow = RAINBOW_CYCLE()
