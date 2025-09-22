class AURORA
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var W, H
    var timer
    var speed, scale
    var palette
    var noise_buffer

    def init()
        import math
        
        self.W = 32
        self.H = 8
        self.strip = Leds(self.W * self.H, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = pixmat(buf, self.W, self.H, bpp, true)

        self.tick = 0
        self.frame_div = 1
        self.timer = 0
        
        # Parameters
        self.speed = 20  # Slower for smoother animation
        self.scale = 40  # Adjusted for smoother noise
        
        # Green Aurora color palette (16 colors)
        self.palette = [
            0x000000, 0x003300, 0x006600, 0x009900, 0x00cc00, 
            0x00ff00, 0x33ff00, 0x66ff00, 0x99ff00, 0xccff00, 
            0xffff00, 0xffcc00, 0xff9900, 0xff6600, 0xff3300, 0xff0000
        ]

        # Initialize noise buffer for smoother transitions
        self.noise_buffer = bytes(-(self.W * self.H))

        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
        
        # Pre-fill noise buffer
        self.generate_noise()
    end

    def deinit()
        self.strip.clear()
        tasmota.remove_fast_loop(self.fast_loop_closure)
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0 return end
        self.draw()
    end

    # Improved noise function with smoother transitions
    def generate_noise()
        import crypto
        var i = 0
        while i < size(self.noise_buffer)
            self.noise_buffer[i] = crypto.random(1)[0]
            i += 1
        end
    end

    # Smoother noise function using interpolation
    def smooth_noise(x, y, time)
        import math
        
        # Get integer coordinates
        var xi = int(x)
        var yi = int(y)
        
        # Calculate fractional parts
        var xf = x - xi
        var yf = y - yi
        
        # Wrap coordinates
        xi = xi % self.W
        yi = yi % self.H
        
        # Get noise values at surrounding points
        var idx_tl = yi * self.W + xi
        var idx_tr = yi * self.W + ((xi + 1) % self.W)
        var idx_bl = ((yi + 1) % self.H) * self.W + xi
        var idx_br = ((yi + 1) % self.H) * self.W + ((xi + 1) % self.W)
        
        # Get noise values
        var tl = self.noise_buffer[idx_tl]
        var tr = self.noise_buffer[idx_tr]
        var bl = self.noise_buffer[idx_bl]
        var br = self.noise_buffer[idx_br]
        
        # Interpolate between noise values
        var top = tl + xf * (tr - tl)
        var bottom = bl + xf * (br - bl)
        return top + yf * (bottom - top)
    end

    def draw()
        import math
        self.timer += 1
        
        # Calculate time-based movement
        var time_factor = self.timer / 100.0
        
        # Draw the aurora effect with smoother noise
        var x = 0
        while x < self.W
            var y = 0
            while y < self.H
                # Calculate smoother noise value with time-based animation
                var noise_val = self.smooth_noise(
                    x / 4.0 + time_factor,  # X coordinate with time-based movement
                    y / 3.0,                # Y coordinate
                    time_factor              # Time factor
                )
                
                # Apply height-based adjustment (stronger at top and bottom)
                var center = self.H / 2.0
                var distance_from_center = math.abs(y - center)
                var adjustment = distance_from_center * 20
                
                # Calculate value with adjustment
                var value = noise_val - adjustment
                if value < 0 value = 0 end
                if value > 255 value = 255 end
                
                # Map value to palette index (0-15)
                var palette_idx = 0
                if value > 0
                    palette_idx = int(value * 15 / 255)
                    if palette_idx < 0 palette_idx = 0 end
                    if palette_idx > 15 palette_idx = 15 end
                end
                
                # Set the pixel color
                if value > 0
                    self.matrix.set(x, y, self.palette[palette_idx])
                else
                    self.matrix.set(x, y, 0, 0, 0)
                end
                y += 1
            end
            x += 1
        end
        
        self.strip.show()
        
        # Occasionally regenerate noise for variation
        if self.timer % 100 == 0
            self.generate_noise()
        end
    end

    # Helper functions
    def fmap_value(x, in_min, in_max, out_min, out_max)
        return (out_max - out_min) * (x - in_min) / (in_max - in_min) + out_min
    end

    def map_value(x, in_min, in_max, out_min, out_max)
        return int((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)
    end
end

# Instantiate animation
var anim = AURORA()