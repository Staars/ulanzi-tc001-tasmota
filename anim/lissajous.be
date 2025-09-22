#@ solidify:LISSAJOUS_2D
class LISSAJOUS_2D
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    var cols, rows
    var speed
    var custom3
    var fade_amount
    var hsv_buf   # 2D array of [h, s, v]
    var phase     # Track phase separately from time

    def init()
        self.cols = 32
        self.rows = 8
        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 2))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = pixmat(buf, self.cols, self.rows, bpp, true)

        self.speed = 5  # Reduced for better visibility
        self.custom3 = 0
        self.fade_amount = 20   # lower = longer trails
        self.phase = 0          # Initialize phase

        # init hsv buffer
        self.hsv_buf = []
        var y = 0
        while y < self.rows
            var row = []
            var x = 0
            while x < self.cols
                row.push([0, 0, 0])  # h, s, v
                x += 1
            end
            self.hsv_buf.push(row)
            y += 1
        end

        self.tick = 0
        self.frame_div = 1

        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_fast_loop(self.fast_loop_closure)
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0
            return
        end
        self.draw()
    end

    # --- Helpers ---
    def sin8_t(val)
        import math
        var ang = (val % 256) / 256.0 * 2.0 * math.pi
        return int((math.sin(ang) + 1.0) * 127.5)
    end

    def cos8_t(val)
        return self.sin8_t(val + 64)
    end

    def map_value(x, in_min, in_max, out_min, out_max)
        var val = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
        if val < out_min val = out_min end
        if val > out_max val = out_max end
        return int(val)
    end

    def fade_all(amount)
        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                var hsv = self.hsv_buf[y][x]
                var v = hsv[2] - amount
                if v < 0 v = 0 end
                hsv[2] = v
                x += 1
            end
            y += 1
        end
    end

    def push_to_matrix()
        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                var hsv = self.hsv_buf[y][x]
                if hsv[2] > 0
                    self.matrix.set(x,y,hsv[0],hsv[1],hsv[2])
                end
                x += 1
            end
            y += 1
        end
    end

    # --- Main draw ---
    def draw()
        # Update phase
        self.phase += self.speed
        if self.phase >= 256
            self.phase = 0
        end

        # Fade previous frame in buffer
        self.fade_all(self.fade_amount)

        var i = 0
        while i < 16  # Reduced number of points for better performance
            # Calculate positions using phase
            var x_phase = (self.phase + i * 16) % 256
            var y_phase = (self.phase + i * 24) % 256  # Different multiplier for Y
            
            var xlocn = self.sin8_t(x_phase)
            var ylocn = self.cos8_t(y_phase)

            # Map to matrix coordinates
            var xi = self.map_value(xlocn, 0, 255, 0, self.cols - 1)
            var yi = self.map_value(ylocn, 0, 255, 0, self.rows - 1)

            # Clamp to valid indices
            if xi < 0 xi = 0 end
            if xi >= self.cols xi = self.cols - 1 end
            if yi < 0 yi = 0 end
            if yi >= self.rows yi = self.rows - 1 end

            var hue = (self.phase + i * 16) % 256
            self.hsv_buf[yi][xi] = [hue, 255, 255]

            i += 1
        end

        # Push buffer to matrix
        self.push_to_matrix()
        self.strip.show()
    end
end

# Instantiate animation
var anim = LISSAJOUS_2D()