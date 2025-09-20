class METEOR_RAIN
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var hue, meteor_pos, meteor_len
    var hue_buf, val_buf   # per-pixel hue and brightness

    def init()
        self.W = 32
        self.H = 8
        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 1
        self.hue = 0
        self.meteor_pos = 0
        self.meteor_len = 6

        self.hue_buf = bytes(-(self.W * self.H))
        self.val_buf = bytes(-(self.W * self.H))

        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_driver(self)
    end

    def idx(x, y)
        return y * self.W + x
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.update_meteor()
    end

    def fade_all()
        var n = self.W * self.H
        var i = 0
        while i < n
            var v = self.val_buf[i]
            if v > 10
                v -= 10
            else
                v = 0
            end
            self.val_buf[i] = v
            i += 1
        end
    end

    def update_meteor()
        self.fade_all()

        # Draw meteor trail in hue/val buffers
        var y = 0
        while y < self.meteor_len && y < self.H
            var k = self.idx(self.meteor_pos, y)
            self.hue_buf[k] = self.hue
            # fade along the trail: head bright, tail dimmer
            var v = 255 - (y * (255 / self.meteor_len))
            if v < 0 v = 0 end
            self.val_buf[k] = v
            y += 1
        end

        # Render all pixels from hue/val buffers
        var yy = 0
        while yy < self.H
            var xx = 0
            while xx < self.W
                var k = self.idx(xx, yy)
                var v = self.val_buf[k]
                if v > 0
                    self.matrix.set(xx, yy, self.hue_buf[k], 255, v)
                else
                    self.matrix.set(xx, yy, 0, 0, 0)
                end
                xx += 1
            end
            yy += 1
        end

        self.strip.show()

        # Move meteor
        self.meteor_pos += 1
        if self.meteor_pos >= self.W
            self.meteor_pos = 0
            self.hue = (self.hue + 32) % 256
        end
    end
end

var anim = METEOR_RAIN()
