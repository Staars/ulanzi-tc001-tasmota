class BOUNCING_BALLS
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var num_balls
    var height, impact_velocity, time_since_last_bounce, dampening, hues

    def init()
        self.W = 32
        self.H = 8
        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var buf = self.strip.pixels_buffer()
        var bpp = self.strip.pixel_size()
        self.matrix = pixmat(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 1
        self.num_balls = 3
        self.height = []
        self.impact_velocity = []
        self.time_since_last_bounce = []
        self.dampening = []
        self.hues = []

        import crypto
        var i = 0
        while i < self.num_balls
            self.height.push(0)
            self.impact_velocity.push(self.calc_sqrt(2 * 9.81 * (self.H - 1)))
            self.time_since_last_bounce.push(0)
            self.dampening.push(0.90 + ((crypto.random(1)[0] % 20) / 100.0))
            self.hues.push((i * 85) % 256)  # store hue only
            i += 1
        end

        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
    end

    def calc_sqrt(val)
        import math
        return math.sqrt(val)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_driver(self)
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.update_balls()
    end

    def update_balls()
        var w = self.W
        var h = self.H

        # clear display in HSV (v=0)
        var y = 0
        while y < h
            var x = 0
            while x < w
                self.matrix.set(x, y, 0, 0, 0)
                x += 1
            end
            y += 1
        end

        var i = 0
        while i < self.num_balls
            self.time_since_last_bounce[i] += 0.05
            var t = self.time_since_last_bounce[i]
            self.height[i] = 0.5 * -9.81 * (t * t) + self.impact_velocity[i] * t

            if self.height[i] < 0
                self.height[i] = 0
                self.impact_velocity[i] *= self.dampening[i]
                self.time_since_last_bounce[i] = 0
                if self.impact_velocity[i] < 0.5
                    self.impact_velocity[i] = self.calc_sqrt(2 * 9.81 * (h - 1))
                end
            end

            var pos_y = int(self.height[i])
            if pos_y >= h pos_y = h - 1 end

            var col_x = int((i * (w / self.num_balls)) + (w / (self.num_balls * 2)))
            # set pixel in HSV: hue from list, full saturation, full brightness
            self.matrix.set(col_x, (h - 1) - pos_y, self.hues[i], 255, 255)
            i += 1
        end

        self.strip.show()
    end
end

var anim = BOUNCING_BALLS()
