
################################


import math

#@ solidify:MOIRE_DRIFT
class MOIRE_DRIFT
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    var offset1_x, offset1_y
    var offset2_x, offset2_y

    def init()
        self.strip = Leds(32 * 8, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, 32, 8, bpp, true)

        self.tick = 0
        self.frame_div = 1  # update every fast_loop tick

        self.offset1_x = 0.0
        self.offset1_y = 0.0
        self.offset2_x = 0.0
        self.offset2_y = 0.0

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

        # Move pattern offsets at slightly different speeds
        self.offset1_x += 0.07
        self.offset1_y += 0.04
        self.offset2_x += 0.05
        self.offset2_y += 0.06

        self.draw()
    end

    def hsvInt(h, v)
        var s = 255
        var sector = h / 60
        var f = h % 60
        var p = (v * (255 - s)) / 255
        var sf = (s * f) / 60
        var q = (v * (255 - sf)) / 255
        var s60f = (s * (60 - f)) / 60
        var t = (v * (255 - s60f)) / 255

        var r = 0
        var g = 0
        var b = 0

        if sector == 0
            r = v
            g = t
            b = p
        elif sector == 1
            r = q
            g = v
            b = p
        elif sector == 2
            r = p
            g = v
            b = t
        elif sector == 3
            r = p
            g = q
            b = v
        elif sector == 4
            r = t
            g = p
            b = v
        else
            r = v
            g = p
            b = q
        end

        return (r << 16) | (g << 8) | b
    end

    def draw()
        var t = self.tick
        for y:0..7
            for x:0..31
                # First grid pattern
                var g1 = math.sin((x + self.offset1_x) / 2.5) + math.sin((y + self.offset1_y) / 2.5)

                # Second grid pattern (different scale)
                var g2 = math.sin((x + self.offset2_x) / 3.0) + math.sin((y + self.offset2_y) / 3.0)

                # Combine patterns to get moiré interference
                var combined = (g1 + g2) / 4.0  # normalize to ~-1..1
                var hue = int(((combined + 1.0) * 180 + t) % 360)
                var v = 200

                var col = self.hsvInt(hue, v)
                self.matrix.set(x, y, col)
            end
        end
        self.strip.show()
    end
end

var anim = MOIRE_DRIFT()

