class AURORA
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var hue_offset, wave_offset

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
        self.wave_offset = 0

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
        self.draw_aurora()
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

    def draw_aurora()
        import math
        var w = self.W
        var h = self.H
        var hue_base = self.hue_offset
        var wave = self.wave_offset

        var y = 0
        while y < h
            var x = 0
            while x < w
                # Create a wave pattern for brightness
                var wave_val = math.sin((x + wave) / 5.0) + math.cos((y + wave) / 7.0)
                var brightness = int((wave_val + 2) * 63)  # scale to 0–255

                # Hue shifts across X and Y
                var hue_val = (hue_base + x * 4 + y * 8) % 256
                var col = self.hsv_to_rgb(hue_val, 200, brightness)
                self.matrix.set(x, y, col)
                x += 1
            end
            y += 1
        end

        self.strip.show()

        # Animate
        self.hue_offset = (self.hue_offset + 1) % 256
        self.wave_offset += 0.5
    end
end

var aurora = AURORA()
