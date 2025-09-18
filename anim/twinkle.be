class TWINKLE
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var pixels

    def init()
        self.W = 32
        self.H = 8

        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        # Store current color of each pixel
        self.pixels = []
        var total = self.W * self.H
        var i = 0
        while i < total
            self.pixels.push(0)
            i += 1
        end

        self.tick = 0
        self.frame_div = 2  # adjust for speed

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
        self.update_twinkle()
        self.draw_twinkle()
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

    def update_twinkle()
        import crypto
        var total = self.W * self.H
        var pix = self.pixels

        # Fade all pixels slightly
        var i = 0
        while i < total
            var c = pix[i]
            var r = (c >> 16) & 0xFF
            var g = (c >> 8) & 0xFF
            var b = c & 0xFF

            if r > 5
                r -= 5
            else
                r = 0
            end

            if g > 5
                g -= 5
            else
                g = 0
            end

            if b > 5
                b -= 5
            else
                b = 0
            end

            pix[i] = (r << 16) | (g << 8) | b
            i += 1
        end

        # Randomly light up a few new twinkles
        var new_count = 3  # how many per frame
        var n = 0
        while n < new_count
            var idx = crypto.random(1)[0] % total
            var hue = crypto.random(1)[0]
            pix[idx] = self.hsv_to_rgb(hue, 200, 255)
            n += 1
        end
    end

    def draw_twinkle()
        var w = self.W
        var h = self.H
        var pix = self.pixels
        var y = 0
        while y < h
            var x = 0
            while x < w
                var idx = y * w + x
                self.matrix.set(x, y, pix[idx])
                x += 1
            end
            y += 1
        end
        self.strip.show()
    end
end

# Start the Twinkle effect
var twinkle = TWINKLE()
