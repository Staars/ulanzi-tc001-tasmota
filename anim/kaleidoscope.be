
#########################

import math

#@ solidify:KALEIDOSCOPE_SPIN
class KALEIDOSCOPE_SPIN
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div

    var cx, cy   # center coordinates
    var wedges   # number of mirrored segments
    var spin_speed

    def init()
        self.strip = Leds(32 * 8, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, 32, 8, bpp, true)

        self.cx = (32 - 1) / 2.0
        self.cy = (8 - 1) / 2.0
        self.wedges = 6           # number of symmetrical slices
        self.spin_speed = 0.02    # radians per frame

        self.tick = 0
        self.frame_div = 1

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
        var angle_offset = self.tick * self.spin_speed
        for y:0..7
            for x:0..31
                # Translate to center
                var dx = x - self.cx
                var dy = y - self.cy

                # Polar coordinates
                var r = math.sqrt(dx*dx + dy*dy)
                var ang = math.atan2(dy, dx) + angle_offset

                # Wrap angle into one wedge
                var wedge_angle = (2.0 * math.pi) / self.wedges
                ang = ang % wedge_angle
                if ang < 0
                    ang += wedge_angle
                end

                # Map wedge angle back to 0..1
                var norm_ang = ang / wedge_angle
                var norm_r = r / (math.sqrt(self.cx*self.cx + self.cy*self.cy))

                # Colour mapping: hue from angle, brightness from radius
                var hue = int((norm_ang * 360) % 360)
                var val = int(255 * (1.0 - norm_r))
                if val < 0 val = 0 end
                if val > 255 val = 255 end

                var col = self.hsvInt(hue, val)
                self.matrix.set(x, y, col)
            end
        end
        self.strip.show()
    end
end

var anim = KALEIDOSCOPE_SPIN()

