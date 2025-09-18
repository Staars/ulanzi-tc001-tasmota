class CRAZY_BEES
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var bees, num_bees

    def init()
        self.W = 32
        self.H = 8

        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 1  # fast movement
        self.num_bees = 5   # number of bees

        # Each bee: [x, y, target_x, target_y, color]
        self.bees = []
        import crypto
        var i = 0
        while i < self.num_bees
            var bx = crypto.random(1)[0] % self.W
            var by = crypto.random(1)[0] % self.H
            var tx = crypto.random(1)[0] % self.W
            var ty = crypto.random(1)[0] % self.H
            var hue = crypto.random(1)[0]
            self.bees.push([bx, by, tx, ty, self.hsv_to_rgb(hue, 255, 255)])
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
        if self.tick % self.frame_div != 0
            return
        end
        self.update_bees()
        self.draw_bees()
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

    def update_bees()
        import crypto
        var i = 0
        while i < self.num_bees
            var bee = self.bees[i]
            var bx = bee[0]
            var by = bee[1]
            var tx = bee[2]
            var ty = bee[3]

            # Move bee toward target
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

            # If bee reached target, pick a new flower
            if bx == tx && by == ty
                tx = crypto.random(1)[0] % self.W
                ty = crypto.random(1)[0] % self.H
                var hue = crypto.random(1)[0]
                bee[4] = self.hsv_to_rgb(hue, 255, 255)
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
        # Fade background slightly for trails
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

                if r > 20
                    r -= 20
                else
                    r = 0
                end

                if g > 20
                    g -= 20
                else
                    g = 0
                end

                if b > 20
                    b -= 20
                else
                    b = 0
                end

                self.matrix.set(x, y, (r << 16) | (g << 8) | b)
                x += 1
            end
            y += 1
        end

        # Draw bees
        var i = 0
        while i < self.num_bees
            var bee = self.bees[i]
            self.matrix.set(bee[0], bee[1], bee[4])
            i += 1
        end

        self.strip.show()
    end
end

# Start the Crazy Bees effect
var bees = CRAZY_BEES()
