class PLASMA_NOISE
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var noise_size, noise
    var t

    def init()
        self.W = 32
        self.H = 8

        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 2))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 1
        self.t = 0.0

        # Small repeating noise grid
        self.noise_size = 16
        self.noise = []
        import crypto
        var i = 0
        while i < self.noise_size * self.noise_size
            self.noise.push(crypto.random(1)[0] % 256)
            i += 1
        end

        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_driver(self)
    end

    # Simple 2D value noise lookup with bilinear interpolation
    def noise2d(x, y)
        var ns = self.noise_size
        var xi = int(x) % ns
        var yi = int(y) % ns
        var xf = x - int(x)
        var yf = y - int(y)

        var x1 = (xi + 1) % ns
        var y1 = (yi + 1) % ns

        var v00 = self.noise[yi * ns + xi]
        var v10 = self.noise[yi * ns + x1]
        var v01 = self.noise[y1 * ns + xi]
        var v11 = self.noise[y1 * ns + x1]

        var i1 = v00 + (v10 - v00) * xf
        var i2 = v01 + (v11 - v01) * xf
        return i1 + (i2 - i1) * yf
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0
            return
        end
        self.draw_plasma()
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
        return (int(r) << 16) | (int(g) << 8) | int(b)
    end

    def draw_plasma()
        var w = self.W
        var h = self.H

        var y = 0
        while y < h
            var x = 0
            while x < w
                # Sample moving noise field
                var nx = (x / 4.0) + self.t
                var ny = (y / 4.0) + self.t * 0.7
                var nval = self.noise2d(nx, ny)  # 0–255

                # Map noise to hue & brightness
                var hue = (int(nval) + self.tick * 2) % 256
                var bright = 128 + ((int(nval) - 128) / 2)

                self.matrix.set(x, y, self.hsv_to_rgb(hue, 255, bright))
                x += 1
            end
            y += 1
        end

        self.strip.show()
        self.t += 0.1
    end
end

var anim = PLASMA_NOISE()
