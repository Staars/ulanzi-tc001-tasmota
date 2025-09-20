#@ solidify:MULTI_SPRITE_TINT_DEMO
class MULTI_SPRITE_TINT_DEMO
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var sprites
    var actors   # [sprite_index, x, y, vx, vy, tint:int, bri:int]

    def init()
        self.strip = Leds(32 * 8, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, 32, 8, bpp, true)

        var smiley_mono = [
            0,   180, 200, 180,   0,
          180,    50,   0,   50, 180,
          200,     0,   0,    0, 200,
          180,    50,   0,   50, 180,
            0,   180, 200, 180,   0
        ]
        var heart_mono = [
          200, 200,   0, 200, 200,
          220, 240, 240, 240, 220,
          240, 255, 255, 255, 240,
            0, 220, 240, 220,   0,
            0,   0, 200,   0,   0
        ]
        var star_mono = [
            0,   0, 180,   0,   0,
            0, 180, 220, 180,   0,
          180, 220, 255, 220, 180,
            0, 180, 220, 180,   0,
            0,   0, 180,   0,   0
        ]

        self.sprites = [
            [5, 5, Matrix(bytes(-(5*5)), 5, 5, 1, false)],
            [5, 5, Matrix(bytes(-(5*5)), 5, 5, 1, false)],
            [5, 5, Matrix(bytes(-(5*5)), 5, 5, 1, false)]
        ]
        self.fillMono(self.sprites[0][2], smiley_mono)
        self.fillMono(self.sprites[1][2], heart_mono)
        self.fillMono(self.sprites[2][2], star_mono)

        # --- New 4th sprite: 8×4 pixels from bit_lines ---
        # Example pattern: arrow shape
        var arrow_bits = bytes("183c7eff")  # rows: 0x18,0x3C,0x7E,0xFF
        self.sprites.push([8, 4, Matrix(arrow_bits, 1)])

        self.actors = [
            [0, 0, 0, 1, 1,   0xFFFF00, 255],
            [1, 10, 2, -1, 1, 0xFF00FF, 200],
            [2, 20, 5, 1, -1, 0x00FFFF, 255],
            [3, 8,  1, 1, 1,  0xFF8000, 255]  # orange arrow
        ]

        self.tick = 0
        self.frame_div = 20
        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
    end

    def fillMono(m, arr)
        var buf = m._buf
        var i = 0
        while i < size(arr)
            buf[i] = arr[i]
            i += 1
        end
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_driver(self)
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.update()
        self.draw()
    end

    def update()
        for a: self.actors
            a[1] += a[3]
            a[2] += a[4]
            var sprite_w = self.sprites[a[0]][0]
            var sprite_h = self.sprites[a[0]][1]
            if a[1] <= 0 || a[1] + sprite_w >= 32
                a[3] = -a[3]
                a[1] += a[3]
            end
            if a[2] <= 0 || a[2] + sprite_h >= 8
                a[4] = -a[4]
                a[2] += a[4]
            end
            if self.tick % 50 == 0
                a[5] = self.nextTint(a[5])
            end
        end
    end

    def nextTint(col)
        if col == 0xFFFF00 return 0xFF00FF end
        if col == 0xFF00FF return 0x00FFFF end
        if col == 0x00FFFF return 0xFFFFFF end
        return 0xFFFF00
    end

    def draw()
        self.matrix.clear(0x000000)
        for a: self.actors
            var mono = self.sprites[a[0]][2]
            self.matrix.blit(mono, a[1], a[2], a[6], a[5])
        end
        self.strip.show()
    end
end

var anim = MULTI_SPRITE_TINT_DEMO()
