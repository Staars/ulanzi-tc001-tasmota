
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
        self.matrix = pixmat(buf, 32, 8, bpp, true)

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

                self.matrix.set(x, y, hue,255,v)
            end
        end
        self.strip.show()
    end
end

var anim = MOIRE_DRIFT()

