#@ solidify:SENDING_EFFECTS
class SENDING_EFFECTS
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    var cols, rows
    var sending, send_dir, loading
    var selX
    var posY
    var speed

    def init()
        self.cols = 32
        self.rows = 8
        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 2))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = pixmat(buf, self.cols, self.rows, bpp, true)

        self.sending = false
        self.send_dir = true
        self.loading = true
        self.selX = 0
        self.posY = []
        self.speed = 5

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

    # Wu‑pixel vertical draw (8.8 fixed‑point Y)
    def wu_pixelY(x, y_fp, hue, sat, val)
        var yy = y_fp & 0xff
        var iy = 255 - yy
        var weights = [iy, yy]
        var base_y = int(y_fp >> 8)
        var i = 1
        while i >= 0
            var py = base_y + ((i >> 1) & 1)
            if py >= 0 && py < self.rows
                var w_val = (val * weights[i]) >> 8
                self.matrix.set(x, py, hue, sat, w_val)
            end
            i -= 1
        end
    end

    def send_voxels_v2()
        import math
        if self.loading
            self.matrix.clear()
            var i = 0
            while i < self.cols
                if (math.rand() % 2) == 1
                    self.posY.push((self.rows - 1) * 256)
                else
                    self.posY.push(0)
                end
                i += 1
            end
            self.loading = false
        end

        var i = 0
        while i < self.cols
            var hue = 150
            var sat = 255
            var val = 255
            if i == self.selX
                self.wu_pixelY(i, self.posY[i], hue, sat, val)
            else
                self.matrix.set(i, int(self.posY[i] / 256), hue, sat, val)
            end
            i += 1
        end

        if !self.sending
            self.selX = math.rand() % self.cols
            if self.posY[self.selX] == 0
                self.send_dir = true
            elif self.posY[self.selX] == (self.rows - 1) * 256
                self.send_dir = false
            end
            self.sending = true
        else
            if self.send_dir
                self.posY[self.selX] += self.speed
                if self.posY[self.selX] >= (self.rows - 1) * 256
                    self.posY[self.selX] = (self.rows - 1) * 256
                    self.sending = false
                end
            else
                self.posY[self.selX] -= self.speed
                if self.posY[self.selX] <= 0
                    self.posY[self.selX] = 0
                    self.sending = false
                end
            end
        end
    end

    def dist(x1, y1, x2, y2)
        import math
        var a = y2 - y1
        var b = x2 - x1
        var d = math.sqrt(a*a + b*b)
        if d == 0 return 255 end
        return int(220 / d)
    end

    def lava_sending()
        import math
        if self.loading
            self.matrix.clear()
            var i = 0
            while i < self.cols
                if (math.rand() % 2) == 1
                    self.posY.push((self.rows - 1) * 256)
                else
                    self.posY.push(0)
                end
                i += 1
            end
            self.loading = false
        end

        if !self.sending
            self.selX = math.rand() % self.cols
            if self.posY[self.selX] == 0
                self.send_dir = true
            elif self.posY[self.selX] == (self.rows - 1) * 256
                self.send_dir = false
            end
            self.sending = true
        else
            if self.send_dir
                self.posY[self.selX] += self.speed
                if self.posY[self.selX] >= (self.rows - 1) * 256
                    self.posY[self.selX] = (self.rows - 1) * 256
                    self.sending = false
                end
            else
                self.posY[self.selX] -= self.speed
                if self.posY[self.selX] <= 0
                    self.posY[self.selX] = 0
                    self.sending = false
                end
            end
        end

        var i = 0
        while i < self.cols
            var j = 0
            while j < self.rows
                var sum = self.dist(i, j, 0, int(self.posY[0] / 256)) / 2
                var s = 1
                while s < self.cols
                    sum += self.dist(i, j, s, int(self.posY[s] / 256)) / 2
                    s += 1
                end
                self.matrix.set(i, j, (sum + 128) % 256, 255, 255)
                j += 1
            end
            i += 1
        end
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.draw()
    end

    def draw()
        var regime = 1  # 1 = sendVoxelsV2, 2 = LavaSending
        if regime == 1
            self.send_voxels_v2()
        elif regime == 2
            self.lava_sending()
        end
        self.strip.show()
    end
end

# Instantiate
var anim = SENDING_EFFECTS()
