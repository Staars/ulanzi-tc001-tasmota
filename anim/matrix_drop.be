#########################################

#-
 - LED driver for Ulanzi clock written in Berry
 - Matrix rain animation using Matrix + blit()
 - Uses packed integer hex colours
-#

#@ solidify:MATRIX_ANIM
class MATRIX_ANIM
    var strip
    var matrix
    var drop
    var positions
    var wait

    def init()
        import crypto

        # Create LED strip and wrap in Matrix (serpentine handled in C++)
        self.strip = Leds(32 * 8, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, 32, 8, bpp, true)

        # Create a 1×4 drop pattern (head bright green, tail dimmer)
        # Allocate exact size: width × height × bpp
        self.drop = Matrix(1, 4, bpp, false)
        self.drop.set(0, 0, 0x001800)  # head
        self.drop.set(0, 1, 0x001200)  # tail 1
        self.drop.set(0, 2, 0x000a00)  # tail 2
        self.drop.set(0, 3, 0x000500)  # tail 3

        # Initialise drop positions
        self.wait = 0
        self.positions = []
        for i: 0..31
            var y = (crypto.random(1)[0] % 10) - 3
            if i > 0 && y == self.positions[i - 1]
                y += 3
            end
            self.positions.push(y)
        end

        # Register driver
        tasmota.add_driver(self)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_driver(self)
    end

    def every_50ms()
        if self.wait == 0
            self.wait = 4
            return
        end
        self.wait -= 1

        # Clear the whole matrix to black
        self.matrix.clear(0x000000)

        # Draw each drop
        var x = 0
        for y: self.positions
            if y >= 9
                self.positions[x] = -3
            else
                # Blit the 1×4 drop into the main matrix at (x, y)
                self.matrix.blit(self.drop, x, y)
                self.positions[x] = y + 1
            end
            x += 1
        end

        self.strip.show()
    end
end

# Instantiate and return the driver
var anim = MATRIX_ANIM()