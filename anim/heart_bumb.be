#@ solidify:HEART_BUMP
class HEART_BUMP
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var chsvLut, bump_bytes
    var TEX_SIZE

    def init()
        import math
        math.srand(tasmota.millis())

        # Set your matrix size here
        self.W = 32
        self.H = 8

        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 1  # adjust for speed

        # Texture is 16x16 data; keep TEX_SIZE in sync with data layout
        self.TEX_SIZE = 16

        # bump texture as bytes from your provided hex string (16x16 = 256 bytes used)
        self.bump_bytes = bytes("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003112b290f000000000000000000000e2d34342c0d00000000000000000d2c383c3c372a0b00000000000000000b28383e41423f37280900000000000926363e434646423f3525080000000000182e38414746464540382c16000000031c2d393f434747443f372d1a02000000172632393e41423e39312615000000000b1e262c302f30302c261b0b000000000b121813090a15181208000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")

        # Precompute LUT using our own HeatColor (packed 0xRRGGBB)
        self.chsvLut = []
        var j = 0
        while j < 256
            self.chsvLut.push(self.HeatColor(int(j / 1.7)))
            j += 1
        end

        tasmota.add_driver(self)
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_driver(self)
    end

    def every_50ms()
        self.draw_effect()
    end

    def draw_effect()
        var lightX = 1 - self.beatsin8(6, 1, self.W + 1, 64)
        var lightY = 1 - self.beatsin8(3, 1, self.H + 1, 0)
        self.bumpmap(lightX, lightY)
        self.strip.show()
    end

    def bumpmap(lightx, lighty)
        import math
        var TEX = self.TEX_SIZE
        var vly = lighty
        var y = 0
        while y < self.H
            vly += 1
            var vlx = lightx
            var ty = int((y * TEX) / self.H)
            var tyU = (ty - 1 + TEX) % TEX
            var tyD = (ty + 1) % TEX
            var x = 0
            while x < self.W
                vlx += 1
                var tx = int((x * TEX) / self.W)
                var txL = (tx - 1 + TEX) % TEX
                var txR = (tx + 1) % TEX

                var idx  = ty * TEX + tx
                var idxL = ty * TEX + txL
                var idxR = ty * TEX + txR
                var idxU = tyU * TEX + tx
                var idxD = tyD * TEX + tx

                var nx = self.bump_bytes[idxR] - self.bump_bytes[idxL]
                var ny = self.bump_bytes[idxD] - self.bump_bytes[idxU]

                var difx = math.abs(vlx * 7 - nx)
                var dify = math.abs(vly * 7 - ny)
                var temp = difx * difx + dify * dify

                var col_val = 255
                if temp != 0
                    col_val = 255 - int(math.sqrt(temp) * 3)
                end
                if col_val < 0
                    col_val = 0
                end
                if col_val > 255
                    col_val = 255
                end

                self.matrix.set(x, y, self.chsvLut[col_val])
                x += 1
            end
            y += 1
        end
    end

    # Berry implementation of FastLED's HeatColor returning packed 0xRRGGBB
    def HeatColor(temperature)
        if temperature < 0
            temperature = 0
        end
        if temperature > 255
            temperature = 255
        end

        var t192 = (temperature * 191) / 255
        var heatramp = (t192 & 0x3F) << 2
        var r = 0
        var g = 0
        var b = 0

        if t192 > 128
            r = 255
            g = 255
            b = heatramp
        else
            if t192 > 64
                r = 255
                g = heatramp
                b = 0
            else
                r = heatramp
                g = 0
                b = 0
            end
        end

        return (r << 16) | (g << 8) | b
    end

    # Berry replacement for FastLED's beatsin8
    def beatsin8(speed, low, high, phase)
        import math
        var now = tasmota.millis()
        var angle = ((now + phase) * speed) / 1000.0
        var s = (math.sin(angle) + 1.0) / 2.0
        return int(low + s * (high - low))
    end
end

var anim = HEART_BUMP()
