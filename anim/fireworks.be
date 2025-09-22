#@ solidify:FIREWORKS_2D
class FIREWORKS_2D
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    var cols, rows
    var particles

    def init()
        self.cols = 32
        self.rows = 8
        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 2))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = pixmat(buf, self.cols, self.rows, bpp, true)

        self.particles = []  # list of [x, y, vx, vy, hue, val]

        self.tick = 0
        self.frame_div = 1
        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_driver(self)
    end

    def spawn_firework()
        import math
        var cx = math.rand() % self.cols
        var cy = math.rand() % self.rows
        var hue = math.rand() % 256
        var count = 12
        var angle_step = (2.0 * math.pi) / count
        var i = 0
        while i < count
            var angle = i * angle_step
            var vx = math.cos(angle)
            var vy = math.sin(angle)
            self.particles.push([cx, cy, vx, vy, hue, 255])
            i += 1
        end
    end

    def update_particles()
        var new_particles = []
        var idx = 0
        while idx < self.particles.size()
            var p = self.particles[idx]
            var x = p[0] + p[2]
            var y = p[1] + p[3]
            var hue = p[4]
            var val = p[5] - 20

            if val > 0 && x >= 0 && x < self.cols && y >= 0 && y < self.rows
                var xi = int(x)
                var yi = int(y)
                if xi < 0 xi = 0 end
                if xi >= self.cols xi = self.cols - 1 end
                if yi < 0 yi = 0 end
                if yi >= self.rows yi = self.rows - 1 end

                self.matrix.set(xi, yi, hue, 255, val)
                new_particles.push([x, y, p[2] * 0.9, p[3] * 0.9, hue, val])
            end
            idx += 1
        end
        self.particles = new_particles
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0
            return
        end
        self.draw()
    end

    def draw()
        import math
        # Clear screen completely each frame
        self.matrix.clear()

        # Occasionally spawn a new firework
        if (math.rand() % 20) == 0
            self.spawn_firework()
        end

        self.update_particles()
        self.strip.show()
    end
end

# Instantiate animation
var anim = FIREWORKS_2D()
