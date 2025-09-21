#@ solidify:WAVE_WASH
import math

class WAVE_WASH
    var strip, matrix, W, H

    def init()
        self.W = 32
        self.H = 8
        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        self.matrix = Matrix(self.strip.pixels_buffer(), self.W, self.H, self.strip.pixel_size(), true)
        tasmota.add_driver(self)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_driver(self)
    end

    def every_50ms()
        self.draw_effect()
        self.strip.show()
    end

    def draw_effect()
        # Oscillating offsets
        var offsetX = self.beatsin(3, -360.0, 360.0, 0)
        var offsetY = self.beatsin(2, -360.0, 360.0, 12000)
        var waveXscale = self.beatsin(10, 1.0, 10.0, 0)

        var x = 0
        var W = self.W
        while x < W
            var y = 0
            var H = self.H
            while y < H
                var idx = self.gridIndexHorizontal(x, y)
                if idx < 0
                    break
                end

                # First pass HSV (lower frequency → bigger dark holes)
                var hue1 = int(x * waveXscale + offsetY) & 0xFF
                var val1 = self.sin8(x * 64.0 + offsetX)

                # Second pass HSV (lower frequency)
                var hue2 = int(y * 3.0 + offsetX) & 0xFF
                var val2 = self.sin8(y * 64.0 + offsetY)

                # Blend in HSV space (simple additive value blend)
                var h = hue1
                var s = 200
                var v = val1 + val2
                if v > 255 v = 255 end

                # Direct HSV to matrix
                self.matrix.set(x, y, h, s, v)

                y += 1
            end
            x += 1
        end
    end

    # Horizontal serpentine index mapping
    def gridIndexHorizontal(x, y)
        if x < 0 || x >= self.W || y < 0 || y >= self.H
            return -1
        end
        if y % 2 == 0
            return y * self.W + x
        else
            return y * self.W + (self.W - 1 - x)
        end
    end

    def beatsin(bpm, low, high)
        var s = (math.sin(tasmota.millis() * bpm / 60000.0 * math.pi * 2) + 1) * 0.5
        return low + s * (high - low)
    end

    # 0..255 sine lookup using math.rad()
    def sin8(x)
        return int((math.sin(math.rad(x % 360)) + 1.0) * 127.5)
    end
end

var anim = WAVE_WASH()