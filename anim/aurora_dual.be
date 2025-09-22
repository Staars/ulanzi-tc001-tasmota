
############################################

import math

#@ solidify:AURORA_DUAL_WAVES
class AURORA_DUAL_WAVES
    var strip, matrix
    var tick, frame_div
    var fast_loop_closure

    def init()
        # LED strip + pixmat
        self.strip = Leds(32 * 8, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = pixmat(buf, 32, 8, bpp, true)

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

                self.matrix.set(x, y, hue, 255,v)
            end
        end

        self.strip.show()
    end
end

var anim = AURORA_DUAL_WAVES()

