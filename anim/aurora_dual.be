
############################################

import math

#@ solidify:AURORA_DUAL_WAVES
class AURORA_DUAL_WAVES
    var strip, matrix
    var tick, frame_div
    var fast_loop_closure

    def init()
        # LED strip + Matrix
        self.strip = Leds(32 * 8, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, 32, 8, bpp, true)

        self.tick = 0
        self.frame_div = 1  # update every fast_loop tick

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
        self.draw()
    end

    # Integer HSV (s=255). h: 0..359, v: 0..255
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

        # Wave parameters
        var speed1 = 2.0
        var speed2 = 1.3
        var hue_shift1 = 0
        var hue_shift2 = 180

        for y:0..7
            for x:0..31
                # First wave: horizontal bias
                var wave1 = math.sin((x * 0.3) + (t / speed1))
                # Second wave: diagonal bias
                var wave2 = math.sin(((x + y) * 0.25) - (t / speed2))

                # Combine waves for brightness modulation
                var combined = (wave1 + wave2) / 2.0
                var v = int(128 + combined * 127)

                # Hue also shifts with position and time
                var hue = int((x * 6 + y * 4 + t) % 360)

                # Alternate hue shift for second wave influence
                if wave2 > 0
                    hue = (hue + hue_shift2) % 360
                else
                    hue = (hue + hue_shift1) % 360
                end

                var col = self.hsvInt(hue, v)
                self.matrix.set(x, y, col)
            end
        end

        self.strip.show()
    end
end

var anim = AURORA_DUAL_WAVES()

