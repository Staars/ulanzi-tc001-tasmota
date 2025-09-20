class CRAZY_BEES
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var bees, num_bees
    var hue_buf, val_buf   # linear buffers, size W*H

    def init()
        self.W = 32
        self.H = 8
        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 1
        self.num_bees = 5

        self.hue_buf = bytes(-(self.W * self.H))
        self.val_buf = bytes(-(self.W * self.H))

        self.bees = []
        import crypto
        var i = 0
        while i < self.num_bees
            var bx = crypto.random(1)[0] % self.W
            var by = crypto.random(1)[0] % self.H
            var tx = crypto.random(1)[0] % self.W
            var ty = crypto.random(1)[0] % self.H
            var hue = crypto.random(1)[0]
            self.bees.push([bx, by, tx, ty, hue])  # [x, y, target_x, target_y, hue]
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

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.update_bees()
        self.draw_bees()
    end

    def idx(x, y)
        return y * self.W + x
    end

    def update_bees()
        import crypto
        var i = 0
        while i < self.num_bees
            var bee = self.bees[i]
            var bx = bee[0]
            var by = bee[1]
            var tx = bee[2]
            var ty = bee[3]

            if bx < tx
                bx += 1
            elif bx > tx
                bx -= 1
            end
            if by < ty
                by += 1
            elif by > ty
                by -= 1
            end

            if bx == tx && by == ty
                tx = crypto.random(1)[0] % self.W
                ty = crypto.random(1)[0] % self.H
                bee[4] = crypto.random(1)[0]  # new hue
            end

            bee[0] = bx
            bee[1] = by
            bee[2] = tx
            bee[3] = ty
            self.bees[i] = bee
            i += 1
        end
    end

    def draw_bees()
        var w = self.W
        var h = self.H
        var hue = self.hue_buf
        var val = self.val_buf

        # decay trails in value buffer
        var n = w * h
        var i = 0
        while i < n
            var v = val[i]
            if v > 20
                v -= 20
            else
                v = 0
            end
            val[i] = v
            i += 1
        end

        # stamp bees at full brightness, keep their hue
        i = 0
        while i < self.num_bees
            var bee = self.bees[i]
            var x = bee[0]
            var y = bee[1]
            var k = self.idx(x, y)
            hue[k] = bee[4]
            val[k] = 255
            i += 1
        end

        # render entire frame using HSV buffers (saturation fixed at 255)
        var y = 0
        while y < h
            var x = 0
            while x < w
                var k = y * w + x
                var v = val[k]
                if v > 0
                    self.matrix.set(x, y, hue[k], 255, v)
                else
                    self.matrix.set(x, y, 0, 0, 0)
                end
                x += 1
            end
            y += 1
        end

        self.strip.show()
    end
end

var anim = CRAZY_BEES()
