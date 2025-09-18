
#############################

import math

#@ solidify:PULSE_RINGS
class PULSE_RINGS
    var strip, matrix
    var frame, bpp

    def init()
        # Create LED strip and wrap in Matrix (serpentine handled in C++)
        self.strip = Leds(32 * 8, gpio.pin(gpio.WS2812, 32))
        self.bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, 32, 8, self.bpp, true)

        self.frame = 0
        tasmota.add_driver(self)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_driver(self)
    end

    def every_50ms()
        self.draw()
        self.frame += 1
        if self.frame > 14
            self.frame = 0
        end
    end

    def draw()
        self.matrix.clear(0x000000)

        # Centre of the panel
        var cx = 15.5
        var cy = 3.5

        # Draw rings at radii based on frame
        for y:0..7
            for x:0..31
                var dx = x - cx
                var dy = y - cy
                var dist = math.sqrt(dx*dx + dy*dy)

                # Pulse: ring radius grows each frame
                var radius = (self.frame % 8) + 1

                # If pixel is near the current radius, colour it
                if math.abs(dist - radius) < 0.5
                    # Fade colour based on radius
                    var fade = 255 - (radius * 30)
                    if fade < 0
                        fade = 0
                    end
                    var col = (fade << 16) | (fade << 8) | fade  # white fade
                    self.matrix.set(x, y, col)
                end
            end
        end

        self.strip.show()
    end
end

var anim = PULSE_RINGS()

