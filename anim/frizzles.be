#@ solidify:FRIZZLES
class FRIZZLES
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var cols, rows
    var cross_sprite
    var dot_bri    # bytes: per-dot brightness
    var dot_cd     # bytes: per-dot cooldown frames
    var dot_phase  # list: per-dot ms phase offsets

    def init()
        import math
        math.srand(tasmota.millis())  # seed RNG

        self.cols = 32
        self.rows = 8
        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 2))
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.cols, self.rows, self.strip.pixel_size(), true)

        # 3×3 cross bit pattern: b010, b111, b010 → 0x40, 0xE0, 0x40
        var sprite_buf = bytes("40E040")
        var bytes_per_line = 1
        self.cross_sprite = Matrix(sprite_buf, bytes_per_line)

        # Per-dot brightness (all start bright)
        self.dot_bri = bytes("FFFFFFFFFFFFFFFF")
        # Per-dot cooldown (all start active)
        self.dot_cd  = bytes("0000000000000000")
        # Per-dot motion phase offsets in ms (desync movement)
        self.dot_phase = []
        var i = 0
        while i < 8
            self.dot_phase.push( math.rand() % 1000 )   # 0..999 ms
            i += 1
        end

        self.tick = 0
        self.frame_div = 1
        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
        tasmota.add_driver(self)
    end

    def deinit()
        self.matrix.clear()
        self.strip.show()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_driver(self)
    end

    # Global fade for smooth trails (slower fade for visible motion/trails)
    def fade_all(scale)
        var y = 0
        while y < self.rows
            var x = 0
            while x < self.cols
                var rgb = self.matrix.get(x, y)
                var r = (rgb >> 16) & 0xFF
                var g = (rgb >> 8) & 0xFF
                var b = rgb & 0xFF
                r = (r * scale) >> 8
                g = (g * scale) >> 8
                b = (b * scale) >> 8
                self.matrix.set(x, y, (r << 16) | (g << 8) | b)
                x += 1
            end
            y += 1
        end
    end

    # beatsin with optional ms phase offset for per-dot desync
    def beatsin8(bpm, low, high, phase_ms)
        import math
        var ms = tasmota.millis() + phase_ms
        var phase = (ms * bpm / 60000.0) % 1.0
        var angle = phase * 2 * math.pi
        var sine = (math.sin(angle) + 1) * 0.5
        return int(low + sine * (high - low))
    end

    # Lightweight RGB wheel (0–255 → rainbow)
    def color_wheel(pos)
        pos = 255 - pos
        if pos < 85
            return ((255 - pos * 3) << 16) | (0 << 8) | (pos * 3)
        elif pos < 170
            pos -= 85
            return (0 << 16) | (pos * 3 << 8) | (255 - pos * 3)
        else
            pos -= 170
            return (pos * 3 << 16) | (255 - pos * 3 << 8) | 0
        end
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.draw()
    end

    def draw()
        import math
        # Slightly gentler fade for visible motion
        self.fade_all(248)  # was 239

        var i = 0
        while i < 8
            # Cooldown handling
            var cd = self.dot_cd.get(i)
            if cd > 0
                cd -= 1
                self.dot_cd.set(i, cd)
                # Skip drawing while in cooldown
                i += 1
                continue
            end

            # Linear decay for a stable visible lifetime
            var bri = self.dot_bri.get(i)
            if bri > 0
                var decay = 4     # brightness steps per frame
                if bri > decay
                    bri -= decay
                else
                    bri = 0
                end
            end

            # If fully faded, schedule a random cooldown, then respawn later
            if bri == 0
                var new_cd = 10 + (math.rand() % 40)   # 10..49 frames
                self.dot_cd.set(i, new_cd)
                # Prepare next life at full brightness
                self.dot_bri.set(i, 255)
                i += 1
                continue
            end

            # Write updated brightness back
            self.dot_bri.set(i, bri)

            # Desynced motion via per-dot ms phase
            var x = self.beatsin8(12 + i, 0, self.cols - 1, self.dot_phase[i])
            var y = self.beatsin8(15 - i, 0, self.rows - 1, self.dot_phase[i])

            # Colour from simple RGB wheel, desynced per dot
            var tint_rgb = self.color_wheel((self.tick * 3 + i * 31) & 255)

            # Draw star
            self.matrix.blit(self.cross_sprite, x - 1, y - 1, bri, tint_rgb)

            i += 1
        end

        self.strip.show()
    end
end

# Instantiate
var anim = FRIZZLES()
