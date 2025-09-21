#@ solidify:LOTUS_EFFECT
class LOTUS_EFFECT
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var cols, rows
    var petals
    var C_X, C_Y, mapp
    var rMap_angle, rMap_radius
    var t

    def init()
        import math
        self.cols = 32
        self.rows = 8
        self.petals = 5
        self.C_X = self.cols / 2
        self.C_Y = self.rows / 2
        self.mapp = 255 / self.cols

        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 2))
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.cols, self.rows, self.strip.pixel_size(), true)

        # Allocate rMap arrays
        self.rMap_angle = []
        self.rMap_radius = []
        var y = 0
        while y < self.rows
            self.rMap_angle.push([])
            self.rMap_radius.push([])
            var x = 0
            while x < self.cols
                self.rMap_angle[y].push(0)
                self.rMap_radius[y].push(0)
                x += 1
            end
            y += 1
        end

        # Precompute polar map
        var ox = -self.C_X
        while ox < self.C_X + (self.cols % 2)
            var oy = -self.C_Y
            while oy < self.C_Y + (self.rows % 2)
                var ax = ox + self.C_X
                var ay = oy + self.C_Y
                self.rMap_angle[ay][ax] = int(128 * (math.atan2(oy, ox) / math.pi))
                # replace math.hypot with sqrt(x*x + y*y)
                var dist = math.sqrt(ox * ox + oy * oy)
                self.rMap_radius[ay][ax] = int(dist * self.mapp)
                oy += 1
            end
            ox += 1
        end

        self.t = 0
        self.tick = 0
        self.frame_div = 1
        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
        tasmota.add_driver(self)
    end

    def deinit()
        self.matrix.clear()
        self.strip.show()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_driver(self)
    end

    # 8-bit sine approximation like FastLED's sin8()
    def sin8(val)
        import math
        return int((math.sin(val / 255.0 * 2 * math.pi) + 1) * 127.5)
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.draw()
    end

    def draw()
        self.matrix.clear()
        self.t += 5  # speed

        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                var angle = self.rMap_angle[y][x]
                var radius = self.rMap_radius[y][x]
                var v = self.sin8(self.t - radius + self.sin8(self.t + angle * self.petals) / 5)
                self.matrix.set(x, y, 248, 181, v)
                x += 1
            end
            y += 1
        end

        self.strip.show()
    end
end

# Instantiate
var anim = LOTUS_EFFECT()