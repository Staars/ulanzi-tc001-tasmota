class METEOR_RAIN
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var hue, meteor_pos, meteor_len

    def init()
        self.W = 32
        self.H = 8

        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 1  # adjust for speed
        self.hue = 0
        self.meteor_pos = 0
        self.meteor_len = 6  # trail length

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
        self.update_meteor()
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

    def fade_all()
        var w = self.W
        var h = self.H
        var y = 0
        while y < h
            var x = 0
            while x < w
                var c = self.matrix.get(x, y)
                var r = (c >> 16) & 0xFF
                var g = (c >> 8) & 0xFF
                var b = c & 0xFF

                if r > 10
                    r -= 10
                else
                    r = 0
                end
                if g > 10
                    g -= 10
                else
                    g = 0
                end
                if b > 10
                    b -= 10
                else
                    b = 0
                end

                self.matrix.set(x, y, (r << 16) | (g << 8) | b)
                x += 1
            end
            y += 1
        end
    end

    def update_meteor()
        self.fade_all()

        var w = self.W
        var h = self.H
        var col = self.hsv_to_rgb(self.hue, 255, 255)

        # Draw meteor vertically down column meteor_pos
        var y = 0
        while y < self.meteor_len && y < h
            self.matrix.set(self.meteor_pos, y, col)
            y += 1
        end

        self.strip.show()

        # Move meteor
        self.meteor_pos += 1
        if self.meteor_pos >= w
            self.meteor_pos = 0
            self.hue = (self.hue + 32) % 256  # change color each pass
        end
    end
end

var meteor = METEOR_RAIN()
