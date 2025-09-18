class BOUNCING_BALLS
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var num_balls
    var height, impact_velocity, time_since_last_bounce, dampening, colors

    def init()
        self.W = 32
        self.H = 8

        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 1

        self.num_balls = 3
        self.height = []
        self.impact_velocity = []
        self.time_since_last_bounce = []
        self.dampening = []
        self.colors = []

        import crypto
        var i = 0
        while i < self.num_balls
            self.height.push(0)
            # initial velocity for full height drop
            self.impact_velocity.push(self.calc_sqrt(2 * 9.81 * (self.H - 1)))
            self.time_since_last_bounce.push(0)
            self.dampening.push(0.90 + ((crypto.random(1)[0] % 20) / 100.0))  # 0.90–1.10
            self.colors.push(self.hsv_to_rgb((i * 85) % 256, 255, 255))
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
        if self.tick % self.frame_div != 0
            return
        end
        self.update_balls()
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

    def update_balls()
        var w = self.W
        var h = self.H

        # Clear display
        var y = 0
        while y < h
            var x = 0
            while x < w
                self.matrix.set(x, y, 0)
                x += 1
            end
            y += 1
        end

        var i = 0
        while i < self.num_balls
            # time step
            self.time_since_last_bounce[i] += 0.05
            var t = self.time_since_last_bounce[i]

            # height = 0.5 * a * t^2 + v0 * t
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
            if pos_y >= h
                pos_y = h - 1
            end

            # Draw ball in its column
            var col_x = int((i * (w / self.num_balls)) + (w / (self.num_balls * 2)))
            self.matrix.set(col_x, (h - 1) - pos_y, self.colors[i])

            i += 1
        end

        self.strip.show()
    end
end

var balls = BOUNCING_BALLS()
