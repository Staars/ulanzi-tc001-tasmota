
#########################################

#@ solidify:MULTI_SPRITE_DEMO
class MULTI_SPRITE_DEMO
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    # Sprite definitions: width, height, pixel data (0 = transparent)
    var sprites
    var actors   # list of [sprite_index, x, y, vx, vy]

    def init()
        self.strip = Leds(32 * 8, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, 32, 8, bpp, true)

        # Define sprites
        var smiley = [
            0,        0xFFFF00, 0xFFFF00, 0xFFFF00, 0,
            0xFFFF00, 0,        0x000000, 0,        0xFFFF00,
            0xFFFF00, 0,        0x000000, 0,        0xFFFF00,
            0xFFFF00, 0,        0,        0,        0xFFFF00,
            0,        0xFFFF00, 0xFFFF00, 0xFFFF00, 0
        ]
        var heart = [
            0xFF0000, 0xFF0000, 0,        0xFF0000, 0xFF0000,
            0xFF0000, 0xFF0000, 0xFF0000, 0xFF0000, 0xFF0000,
            0xFF0000, 0xFF0000, 0xFF0000, 0xFF0000, 0xFF0000,
            0,        0xFF0000, 0xFF0000, 0xFF0000, 0,
            0,        0,        0xFF0000, 0,        0
        ]
        var star = [
            0,        0,        0xFFFFFF, 0,        0,
            0,        0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0,
            0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF,
            0,        0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0,
            0,        0,        0xFFFFFF, 0,        0
        ]

        self.sprites = [
            [5, 5, smiley],
            [5, 5, heart],
            [5, 5, star]
        ]

        # Actors: [sprite_index, x, y, vx, vy]
        self.actors = [
            [0, 0, 0, 1, 1],
            [1, 10, 2, -1, 1],
            [2, 20, 5, 1, -1]
        ]

        self.tick = 0
        self.frame_div = 10  # update every 2 fast_loop ticks

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
        self.update()
        self.draw()
    end

    def update()
        for a: self.actors
            a[1] += a[3]  # x += vx
            a[2] += a[4]  # y += vy

            var sprite_w = self.sprites[a[0]][0]
            var sprite_h = self.sprites[a[0]][1]

            # Bounce horizontally
            if a[1] <= 0 || a[1] + sprite_w >= 32
                a[3] = -a[3]
                a[1] += a[3]
            end
            # Bounce vertically
            if a[2] <= 0 || a[2] + sprite_h >= 8
                a[4] = -a[4]
                a[2] += a[4]
            end
        end
    end

    def draw()
        self.matrix.clear(0x000000)
        for a: self.actors
            self.blitSprite(a[0], a[1], a[2])
        end
        self.strip.show()
    end

    def blitSprite(index, x, y)
        var sprite_w = self.sprites[index][0]
        var sprite_h = self.sprites[index][1]
        var data = self.sprites[index][2]

        for sy:0..sprite_h-1
            for sx:0..sprite_w-1
                var col = data[sy * sprite_w + sx]
                if col != 0
                    var px = x + sx
                    var py = y + sy
                    if px >= 0 && px < 32 && py >= 0 && py < 8
                        self.matrix.set(px, py, col)
                    end
                end
            end
        end
    end
end

var anim = MULTI_SPRITE_DEMO()
