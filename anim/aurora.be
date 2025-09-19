class AURORA
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var hue_offset, wave_offset

    def init()
        self.W = 32
        self.H = 8

        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 2  # adjust for speed
        self.hue_offset = 0
        self.wave_offset = 0

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
        self.draw_aurora()
    end

    def draw_aurora()
        import math
        var w = self.W
        var h = self.H
        var hue_base = self.hue_offset
        var wave = self.wave_offset

        var y = 0
        while y < h
            var x = 0
            while x < w
                # Create a wave pattern for brightness
                var wave_val = math.sin((x + wave) / 5.0) + math.cos((y + wave) / 7.0)
                var brightness = int((wave_val + 2) * 63)  # scale to 0–255

                # Hue shifts across X and Y
                var hue_val = (hue_base + x * 4 + y * 8) % 256
                self.matrix.set(x, y, hue_val, 200, brightness)
                x += 1
            end
            y += 1
        end

        self.strip.show()

        # Animate
        self.hue_offset = (self.hue_offset + 1) % 256
        self.wave_offset += 0.5
    end
end

var anim = AURORA()
