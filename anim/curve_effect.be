#@ solidify:CURVE_EFFECT
class CURVE_EFFECT
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    var cols, rows
    var hue
    var sub_pix
    var speed

    # We'll store brightness for each pixel so we can fade without reading from matrix
    var pix_h, pix_s, pix_v

    def init()
        self.cols = 32
        self.rows = 8
        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 2))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.cols, self.rows, bpp, true)

        self.hue = 0
        self.sub_pix = false
        self.speed = 100

        # init brightness buffers
        self.pix_h = []
        self.pix_s = []
        self.pix_v = []
        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                self.pix_h.push(0)
                self.pix_s.push(0)
                self.pix_v.push(0)
                x += 1
            end
            y += 1
        end

        self.tick = 0
        self.frame_div = 1
        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
    end

    def deinit()
        self.matrix.clear()
        self.strip.show()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_driver(self)
    end

    def idx(x, y)
        return y * self.cols + x
    end

    def fade_all(amount)
        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                var i = self.idx(x, y)
                var v = self.pix_v[i] - amount
                if v < 0 v = 0 end
                self.pix_v[i] = v
                self.matrix.set(x, y, self.pix_h[i], self.pix_s[i], self.pix_v[i])
                x += 1
            end
            y += 1
        end
    end

    def set_pixel(x, y, h, s, v)
        if x >= 0 && x < self.cols && y >= 0 && y < self.rows
            var i = self.idx(x, y)
            self.pix_h[i] = h
            self.pix_s[i] = s
            self.pix_v[i] = v
            self.matrix.set(x, y, h, s, v)
        end
    end

    def draw_curve(x1, y1, x2, y2, x3, y3, hue, sat, val)
        import math
        var u = 0.0
        while u <= 1.0
            var xu = math.pow(1 - u, 3) * x1 + 3 * u * math.pow(1 - u, 2) * x2 + 3 * math.pow(u, 2) * (1 - u) * x3 + math.pow(u, 3) * x3
            var yu = math.pow(1 - u, 3) * y1 + 3 * u * math.pow(1 - u, 2) * y2 + 3 * math.pow(u, 2) * (1 - u) * y3 + math.pow(u, 3) * y3
            self.set_pixel(int(xu), int(yu), hue, sat, val)
            u += 0.01
        end
    end

    def draw_pixel_xyf(x, y, hue, sat, val)
        var xx = int((x - int(x)) * 255)
        var yy = int((y - int(y)) * 255)
        var ix = 255 - xx
        var iy = 255 - yy
        var wu = [
            ((ix * iy + ix + iy) >> 8),
            ((xx * iy + xx + iy) >> 8),
            ((ix * yy + ix + yy) >> 8),
            ((xx * yy + xx + yy) >> 8)
        ]
        var i = 0
        while i < 4
            var xn = int(x) + (i & 1)
            var yn = int(y) + ((i >> 1) & 1)
            var v_adj = (val * wu[i]) >> 8
            self.set_pixel(xn, yn, hue, sat, v_adj)
            i += 1
        end
    end

    def draw_curve_f(x1, y1, x2, y2, x3, y3, hue, sat, val)
        import math
        var u = 0.0
        while u <= 1.0
            var xu = math.pow(1 - u, 3) * x1 + 3 * u * math.pow(1 - u, 2) * x2 + 3 * math.pow(u, 2) * (1 - u) * x3 + math.pow(u, 3) * x3
            var yu = math.pow(1 - u, 3) * y1 + 3 * u * math.pow(1 - u, 2) * y2 + 3 * math.pow(u, 2) * (1 - u) * y3 + math.pow(u, 3) * y3
            self.draw_pixel_xyf(xu, yu, hue, sat, val)
            u += 0.01
        end
    end

    def beatsin8(bpm, low, high)
        import math
        var t = self.tick / 50.0
        var beat = math.sin((t * bpm * math.pi) / 60.0)
        var span = high - low
        return int(low + (span * (beat + 1) / 2))
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.draw()
    end

    def draw()
        self.fade_all(30)

        var x1 = self.beatsin8(18 + self.speed, 0, self.cols - 1)
        var x2 = self.beatsin8(23 + self.speed, 0, self.cols - 1)
        var x3 = self.beatsin8(27 + self.speed, 0, self.cols - 1)

        var y1 = self.beatsin8(20 + self.speed, 0, self.rows - 1)
        var y2 = self.beatsin8(26 + self.speed, 0, self.rows - 1)
        var y3 = self.beatsin8(15 + self.speed, 0, self.rows - 1)

        if self.sub_pix
            self.draw_curve_f(x1, y1, x2, y2, x3, y3, self.hue, 255, 255)
        else
            self.draw_curve(x1, y1, x2, y2, x3, y3, self.hue, 255, 255)
        end

        self.hue = (self.hue + 1) % 256
        self.strip.show()
    end
end

# Instantiate
var anim = CURVE_EFFECT()