#@ solidify:DROP_EFFECT
class DROP_EFFECT
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    var cols, rows, max_rad
    var loading_flag
    var hue, sat

    var rad, posx, posy

    def init()
        self.cols = 32
        self.rows = 8
        self.max_rad = self.cols + self.rows

        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 2))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = pixmat(buf, self.cols, self.rows, bpp, true)

        self.loading_flag = true
        self.hue = 180
        self.sat = 200

        var count = int((self.cols + self.rows) / 8)
        self.rad = []
        self.posx = []
        self.posy = []
        var i = 0
        while i < count
            self.rad.push(0)
            self.posx.push(0)
            self.posy.push(0)
            i += 1
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

    def fill_all(h, s, v)
        self.matrix.clear()
        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                self.matrix.set(x, y, h, s, v)
                x += 1
            end
            y += 1
        end
    end

    def draw_pixel_xy(x, y, h, s, v)
        if x < 0 || x >= self.cols || y < 0 || y >= self.rows
            return
        end
        self.matrix.set(x, y, h, s, v)
    end

    def draw_circle(x0, y0, radius, h, s, v)
        var a = radius
        var b = 0
        var radius_error = 1 - a

        if radius == 0
            self.draw_pixel_xy(x0, y0, h, s, v)
            return
        end

        while a >= b
            self.draw_pixel_xy(a + x0, b + y0, h, s, v)
            self.draw_pixel_xy(b + x0, a + y0, h, s, v)
            self.draw_pixel_xy(-a + x0, b + y0, h, s, v)
            self.draw_pixel_xy(-b + x0, a + y0, h, s, v)
            self.draw_pixel_xy(-a + x0, -b + y0, h, s, v)
            self.draw_pixel_xy(-b + x0, -a + y0, h, s, v)
            self.draw_pixel_xy(a + x0, -b + y0, h, s, v)
            self.draw_pixel_xy(b + x0, -a + y0, h, s, v)
            b += 1
            if radius_error < 0
                radius_error += 2 * b + 1
            else
                a -= 1
                radius_error += 2 * (b - a + 1)
            end
        end
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.draw()
    end

    def draw()
        import math
        if self.loading_flag
            self.loading_flag = false
            var i = 0
            while i < self.rad.size()
                self.posx[i] = math.rand() % self.cols
                self.posy[i] = math.rand() % self.rows
                self.rad[i] = (math.rand() % (self.max_rad + 1)) - 1
                i += 1
            end
        end

        # Background fill
        self.fill_all(self.hue, self.sat , 40)

        # Draw circles
        var i = self.rad.size() - 1
        while i >= 0
            var h1 = (self.hue + ((8.5 * 16) - self.rad[i])) % 256
            var h2 = (self.hue + ((7.5 * 16) - self.rad[i])) % 256
            self.draw_circle(self.posx[i], self.posy[i], self.rad[i], h1, self.sat, 255)
            self.draw_circle(self.posx[i], self.posy[i], self.rad[i] - 1, h2, self.sat, 210)

            if self.rad[i] >= self.max_rad
                self.rad[i] = -1
                self.posx[i] = math.rand() % self.cols
                self.posy[i] = math.rand() % self.rows
            else
                self.rad[i] += 1
            end
            i -= 1
        end

        if self.hue == 0
            self.hue += 1
        end

        # No blur2d in Berry core — could be added if needed
        self.strip.show()
    end
end

# Instantiate
var anim = DROP_EFFECT()