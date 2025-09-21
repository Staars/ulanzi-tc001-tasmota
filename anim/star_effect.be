#@ solidify:STARS_EFFECT
class STARS_EFFECT
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    var cols, rows, nstars
    var posX, posY, posW
    var pix_v
    var fade_scale

    def init()
        self.cols = 32
        self.rows = 8
        self.nstars = int((self.cols + self.rows) / 2)

        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 2))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.cols, self.rows, bpp, true)

        # star fields
        self.posX = []
        self.posY = []
        self.posW = []
        var i = 0
        while i < self.nstars
            self.posX.push(0)
            self.posY.push(0)
            self.posW.push(0)
            i += 1
        end

        # brightness buffer
        self.pix_v = []
        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                self.pix_v.push(0)
                x += 1
            end
            y += 1
        end

        # initialise stars with staggered depths
        var j = 0
        while j < self.nstars
            self.reg_star(j)
            j += 1
        end

        self.fade_scale = 180  # lower = faster fade, dimmer tails

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

    def reg_star(i)
        import math
        self.posX[i] = (math.rand() % (self.cols * 10)) - (self.cols * 5)
        self.posY[i] = (math.rand() % (self.rows * 10)) - (self.rows * 5)
        # randomise depth so stars don't reset in sync
        self.posW[i] = (math.rand() % (self.cols * 5)) + (self.cols * 2)
    end

    def fmap(x, in_min, in_max, out_min, out_max)
        return (out_max - out_min) * (x - in_min) / (in_max - in_min) + out_min
    end

    def add_pixel_xyf(x, y, v)
        var xx = int((x - int(x)) * 255)
        var yy = int((y - int(y)) * 255)
        var ix = 255 - xx
        var iy = 255 - yy
        var w0 = ((ix * iy + ix + iy) >> 8)
        var w1 = ((xx * iy + xx + iy) >> 8)
        var w2 = ((ix * yy + ix + yy) >> 8)
        var w3 = ((xx * yy + xx + yy) >> 8)

        var i = 0
        while i < 4
            var xn = int(x) + (i & 1)
            var yn = int(y) + ((i >> 1) & 1)
            if xn >= 0 && xn < self.cols && yn >= 0 && yn < self.rows
                var w = 0
                if i == 0 w = w0 elif i == 1 w = w1 elif i == 2 w = w2 else w = w3 end
                var v_adj = (v * w) >> 8
                if v_adj > 0
                    var k = self.idx(xn, yn)
                    var nv = self.pix_v[k] + v_adj
                    if nv > 255 nv = 255 end
                    self.pix_v[k] = nv
                end
            end
            i += 1
        end
    end

    def run_star(i)
        self.posW[i] -= 5
        # reset early to avoid tiny w values
        if self.posW[i] <= 5
            self.reg_star(i)
        end
        var w = self.posW[i]
        if w == 0 w = 1 end

        var SX = (self.cols * 0.5) + self.fmap(real(self.posX[i]) / real(w), 0.0, 1.0, 0.0, self.cols / 2.0)
        var SY = (self.rows * 0.5) + self.fmap(real(self.posY[i]) / real(w), 0.0, 1.0, 0.0, self.rows / 2.0)

        if SX > 0 && SX < self.cols && SY > 0 && SY < self.rows
            var b = int(255 - ((w * 155) / (self.cols * 5))) + 100
            if b > 255 b = 255 end
            if b < 0 b = 0 end
            b = (b * 180) >> 8   # scale brightness to ~70%
            self.add_pixel_xyf(SX, SY, b)
        end
    end

    def fade_buffer()
        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                var k = self.idx(x, y)
                self.pix_v[k] = (self.pix_v[k] * self.fade_scale) >> 8
                x += 1
            end
            y += 1
        end
    end

    def flush_to_matrix()
        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                var k = self.idx(x, y)
                self.matrix.set(x, y, 0, 0, self.pix_v[k])
                x += 1
            end
            y += 1
        end
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.draw()
    end

    def draw()
        self.fade_buffer()

        var i = 0
        while i < self.nstars
            self.run_star(i)
            i += 1
        end

        self.flush_to_matrix()
        self.strip.show()
    end
end

# Instantiate
var anim = STARS_EFFECT()