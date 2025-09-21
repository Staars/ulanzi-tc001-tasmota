#@ solidify:FLAGS_EFFECT
class FLAGS_EFFECT
    var strip, matrix
    var fast_loop_closure, every_second_closure
    var tick, frame_div

    var cols, rows
    var thisVal, thisMax
    var counter
    var flag
    var speed
    var change_flag, bg_level

    # used by every_second auto-change
    var sec_since_change

    def init()
        self.cols = 32
        self.rows = 8
        self.strip = Leds(self.cols * self.rows, gpio.pin(gpio.WS2812, 2))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.cols, self.rows, bpp, true)

        self.thisVal = 0
        self.thisMax = 0
        self.counter = 0.0
        self.flag = 0
        self.speed = 10
        self.change_flag = 10  # seconds; set <9 to lock to a specific flag (0..8)
        self.bg_level = 0
        self.sec_since_change = 0

        self.tick = 0
        self.frame_div = 2

        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
        tasmota.add_driver(self)
    end

    def deinit()
        self.matrix.clear()
        self.strip.show()
        tasmota.remove_fast_loop(self.fast_loop_closure)
        tasmota.remove_every_second(self.every_second_closure)
        tasmota.remove_driver(self)
    end

    # --- Flag patterns ---
    def germany(i, j)
        if j < self.thisMax - self.rows / 4
            # top: black -> very dark grey instead of pure black
            var v_black = self.thisVal >> 4  # up to ~15
            if v_black < 6 v_black = 6 end   # ensure barely visible
            if v_black > 18 v_black = 18 end # keep it dark
            self.matrix.set(i, j, 0, 0, v_black)
        elif j < self.thisMax + self.rows / 4
            # middle: red
            self.matrix.set(i, j, 0, 255, self.thisVal)
        else
            # bottom: gold/yellow
            self.matrix.set(i, j, 68, 255, self.thisVal)
        end
    end

    def ukraine(i, j)
        if j < self.thisMax
            self.matrix.set(i, j, 50, 255, self.thisVal)   # yellow
        else
            self.matrix.set(i, j, 180, 255, self.thisVal)  # blue
        end
    end

    def belarus(i, j)
        if j < self.thisMax - self.rows / 4
            self.matrix.set(i, j, 0, 0, self.thisVal)
        elif j < self.thisMax + self.rows / 4
            self.matrix.set(i, j, 0, 224, self.thisVal)
        else
            self.matrix.set(i, j, 0, 0, self.thisVal)
        end
    end

    def poland(i, j)
        if j < self.thisMax + 1
            self.matrix.set(i, j, 248, 214, int(self.thisVal * 0.83))  # white
        else
            self.matrix.set(i, j, 25, 3, int(self.thisVal * 0.91))     # red
        end
    end

    def usa(i, j)
        if (i <= self.cols / 2) && (j + self.thisMax > self.rows - 1 + self.rows / 16)
            if (i % 2) && (((j - self.rows / 16 + self.thisMax) % 2) != 0)
                self.matrix.set(i, j, 160, 0, self.thisVal)     # white star cell
            else
                self.matrix.set(i, j, 180, 255, self.thisVal)   # blue field
            end
        else
            if ((j + 1 + self.thisMax) % 6) < 3
                self.matrix.set(i, j, 0, 0, self.thisVal)       # white stripe
            else
                self.matrix.set(i, j, 0, 255, self.thisVal)     # red stripe
            end
        end
    end

    def italy(i, j)
        if i < self.cols / 3
            self.matrix.set(i, j, 90, 255, self.thisVal)   # green
        elif i < self.cols - 1 - self.cols / 3
            self.matrix.set(i, j, 0, 0, self.thisVal)      # white
        else
            self.matrix.set(i, j, 0, 255, self.thisVal)    # red
        end
    end

    def france(i, j)
        if i < self.cols / 3
            self.matrix.set(i, j, 180, 255, self.thisVal)  # blue
        elif i < self.cols - 1 - self.cols / 3
            self.matrix.set(i, j, 0, 0, self.thisVal)      # white
        else
            self.matrix.set(i, j, 0, 255, self.thisVal)    # red
        end
    end

    def uk(i, j)
        var cond1 = ((i > self.cols / 2 + 1 || i < self.cols / 2 - 2) && (i - (j + self.thisMax - (self.rows * 2 - self.cols) / 2) > -2 && i - (j + self.thisMax - (self.rows * 2 - self.cols) / 2) < 2))
        var cond2 = ((i > self.cols / 2 + 1 || i < self.cols / 2 - 2) && (self.cols - 1 - i - (j + self.thisMax - (self.rows * 2 - self.cols) / 2) > -2 && self.cols - 1 - i - (j + self.thisMax - (self.rows * 2 - self.cols) / 2) < 2))
        var cond3 = (self.cols / 2 - i == 0) || (self.cols / 2 - 1 - i == 0) || ((self.rows - (j + self.thisMax)) == 0) || ((self.rows - 1 - (j + self.thisMax)) == 0)
        var cond4 = ((i - (j + self.thisMax - (self.rows * 2 - self.cols) / 2) > -4 && i - (j + self.thisMax - (self.rows * 2 - self.cols) / 2) < 4))
        var cond5 = ((self.cols - 1 - i - (j + self.thisMax - (self.rows * 2 - self.cols) / 2) > -4 && self.cols - 1 - i - (j + self.thisMax - (self.rows * 2 - self.cols) / 2) < 4))
        var cond6 = (self.cols / 2 + 1 - i == 0) || (self.cols / 2 - 2 - i == 0) || (self.rows + 1 - (j + self.thisMax) == 0) || (self.rows - 2 - (j + self.thisMax) == 0)

        if cond1 || cond2 || cond3
            self.matrix.set(i, j, 0, 255, self.thisVal)     # red
        elif cond4 || cond5 || cond6
            self.matrix.set(i, j, 0, 0, self.thisVal)       # white
        else
            self.matrix.set(i, j, 180, 255, self.thisVal)   # blue
        end
    end

    def spain(i, j)
        if j < self.thisMax - self.rows / 3
            self.matrix.set(i, j, 250, 224, int(self.thisVal * 0.68))  # red
        elif j < self.thisMax + self.rows / 3
            self.matrix.set(i, j, 64, 255, int(self.thisVal * 0.98))   # yellow
        else
            self.matrix.set(i, j, 250, 224, int(self.thisVal * 0.68))  # red
        end
    end

    # --- Helpers ---
    def mix(a1, a2, l)
        return ((a1 * l) + (a2 * (255 - l))) / 255
    end

    # Fade RGB by scaling packed value and writing back as packed RGB
    def fade_all(scale)  # 0..255 (255=no fade)
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

                var new_rgb = (r << 16) | (g << 8) | b
                self.matrix.set(x, y, new_rgb)
                x += 1
            end
            y += 1
        end
    end

    # Called by Tasmota every second
    def every_second()
        if self.change_flag >= 9
            self.sec_since_change += 1
            if self.sec_since_change >= self.change_flag
                self.flag += 1
                if self.flag >= 9 self.flag = 0 end
                self.sec_since_change = 0
            end
        else
            # lock to a specific flag index (0..8)
            self.flag = self.change_flag
        end
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.draw()
    end

    def draw()
        # fade existing pixels down (adjust scale to taste)
        self.fade_all(224)

        var i = 0
        while i < self.cols
            # compute thisVal and thisMax for this column (sine placeholder for inoise8)
            import math
            var n = int((math.sin(((i * (512.0 / self.cols)) - self.counter) / 20.0) + 1) * 127.5)
            self.thisVal = self.mix(n, 128, int(i * (255 / self.cols)))
            self.thisMax = int((self.thisVal * (self.rows - 1)) / 255)

            var j = 0
            while j < self.rows
                var cond = ((self.flag == 1 || self.flag == 8) ? (self.rows - 1 - j) : j)
                var masked_out = (self.thisMax > cond + self.rows / 2) || (self.thisMax < cond - self.rows / 2)

                if masked_out
                    # background: black or very dark grey
                    var v = self.bg_level & 0xFF    # set self.bg_level in init(), e.g. 0 for black
                    var bg = (v << 16) | (v << 8) | v
                    self.matrix.set(i, j, bg)
                else
                    # draw the selected flag pixel
                    if self.flag == 0
                        self.ukraine(i, j)
                    elif self.flag == 1
                        self.uk(i, j)
                    elif self.flag == 2
                        self.germany(i, j)
                    elif self.flag == 3
                        self.poland(i, j)
                    elif self.flag == 4
                        self.belarus(i, j)
                    elif self.flag == 5
                        self.italy(i, j)
                    elif self.flag == 6
                        self.spain(i, j)
                    elif self.flag == 7
                        self.france(i, j)
                    elif self.flag == 8
                        self.usa(i, j)
                    end
                end
                j += 1
            end
            i += 1
        end

        # advance animation counter
        self.counter += self.speed * (self.cols * self.rows / 512.0)

        self.strip.show()
    end

end

# Instantiate
var anim = FLAGS_EFFECT()