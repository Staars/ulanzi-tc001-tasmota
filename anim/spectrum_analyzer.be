
#####################################


import math

#@ solidify:SPECTRUM_ANALYZER_RANDOM
class SPECTRUM_ANALYZER_RANDOM
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    # Layout
    var cols, rows
    var bands, band_w

    # Signal model
    var level      # current bar heights (0..rows)
    var target     # target heights (signal input proxy)
    var peak       # peak-hold per band (0..rows)
    var phase      # per-band phase for sine driver
    var speed      # per-band phase speed
    var jitter     # per-band small noise accumulator

    # Tuning
    var rise, fall, peak_fall
    var jitter_amt, jitter_every

    # PRNG seed
    var rng_seed

    def init()
        # LED strip + Matrix
        self.cols = 32
        self.rows = 8
        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.cols, self.rows, bpp, true)

        # Analyzer layout
        self.bands = 8
        self.band_w = self.cols / self.bands  # 4

        # Arrays
        self.level = []
        self.target = []
        self.peak = []
        self.phase = []
        self.speed = []
        self.jitter = []

        # Dynamics tuning
        self.rise = 0.35
        self.fall = 0.15
        self.peak_fall = 0.30
        self.jitter_amt = 0.20
        self.jitter_every = 6

        # Seed arrays
        self.rng_seed = 123456789
        for i:0..self.bands-1
            self.level.push(0.0)
            self.target.push(0.0)
            self.peak.push(0.0)
            var base_phase = 2.0 * math.pi * (i / self.bands)
            self.phase.push(base_phase)
            var sp = 0.08 + 0.02 * i
            self.speed.push(sp)
            self.jitter.push(0.0)
        end

        # Timing
        self.tick = 0
        self.frame_div = 1

        # Register fast loop
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
        self.updateSignal()
        self.updateBars()
        self.draw()
    end

    def rand01()
        self.rng_seed = (1103515245 * self.rng_seed + 12345) % 2147483647
        return self.rng_seed / 2147483647.0
    end

    def updateSignal()
        var t = self.tick
        for i:0..self.bands-1
            self.phase[i] += self.speed[i]
            var base = (math.sin(self.phase[i]) + 1.0) * 0.5
            var tilt = 1.0 - (i / (self.bands * 1.5))
            if t % self.jitter_every == 0
                self.jitter[i] = (self.rand01() - 0.5) * 2.0 * self.jitter_amt
            end
            var val = base * tilt + self.jitter[i]
            if val < 0.0 val = 0.0 end
            if val > 1.0 val = 1.0 end
            var shaped = math.pow(val, 0.85)
            self.target[i] = shaped * self.rows
        end
    end

    def updateBars()
        for i:0..self.bands-1
            var cur = self.level[i]
            var tar = self.target[i]
            if tar > cur
                cur = cur + self.rise * (tar - cur)
            else
                cur = cur - self.fall * (cur - tar)
            end
            if cur < 0.0 cur = 0.0 end
            if cur > self.rows cur = self.rows end
            self.level[i] = cur

            if cur > self.peak[i]
                self.peak[i] = cur
            else
                self.peak[i] = self.peak[i] - self.peak_fall
                if self.peak[i] < 0.0
                    self.peak[i] = 0.0
                end
            end
        end
    end

    def barColor(y, h)
        var ratio = 0.0
        if h > 0.0
            ratio = y / (self.rows - 1.0)
        end
        var hue = int(120 - 120 * ratio)
        var v = 180 + int(75 * (1.0 - ratio))
        if v > 255 v = 255 end
        if v < 0 v = 0 end
        return [hue, v]
    end

    def draw()
        self.matrix.clear(0x000000)
        for i:0..self.bands-1
            var h = self.level[i]
            var p = self.peak[i]
            var x0 = i * self.band_w
            var x1 = x0 + self.band_w - 1

            for y:0..self.rows-1
                var y_pix = self.rows - 1 - y
                if y < int(h + 0.5)
                    var col = self.barColor(y, h)
                    for x:x0..x1
                        self.matrix.set(x, y_pix, col[0],255,col[1])
                    end
                end
            end

            var peak_y = int(p)
            if peak_y > 0
                var py = self.rows - 1 - peak_y
                var peak_col = 0xFFFFFF
                for x:x0..x1
                    self.matrix.set(x, py, peak_col)
                end
            end
        end
        self.strip.show()
    end
end

var anim = SPECTRUM_ANALYZER_RANDOM()

