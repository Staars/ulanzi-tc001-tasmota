class FIRE2012_DEMO_BYTES
    var strip, matrix
    var fast_loop_closure
    var tick, frame_div
    var heat
    var W, H, total
    var coolmax, w, h
    var palette  # Precomputed color palette

    def init()
        self.W = 32
        self.H = 8
        self.total = self.W * self.H
        self.w = self.W
        self.h = self.H
        self.coolmax = ((55 * 10) / self.H) + 2

        self.strip = Leds(self.total, gpio.pin(gpio.WS2812, 32))
        var bpp = self.strip.pixel_size()
        var buf = self.strip.pixels_buffer()
        self.matrix = Matrix(buf, self.W, self.H, bpp, true)

        # Heat buffer: fixed size, all zeros (optimized initialization)
        self.heat = bytes(-self.total)

        # Precompute color palette for faster rendering
        self.build_palette()

        self.tick = 0
        self.frame_div = 2  # update every other fast_loop tick

        self.fast_loop_closure = def () self.fast_loop() end
        tasmota.add_fast_loop(self.fast_loop_closure)
    end

    def build_palette()
        # Precompute all possible color values for heat values 0-255
        self.palette = []
        for temperature: 0..255
            # Fixed-point arithmetic optimization: (temperature * 191) / 255
            var t192 = (temperature * 191) / 255
            var heatramp = (t192 & 63) << 2
            var col = 0
            if t192 > 128
                col = (255 << 16) | (255 << 8) | heatramp
            elif t192 > 64
                col = (255 << 16) | (heatramp << 8)
            else
                col = (heatramp << 16)
            end
            self.palette.push(col)
        end
    end

    def deinit()
        if self.strip
            self.strip.clear()
        end
        if self.fast_loop_closure
            tasmota.remove_fast_loop(self.fast_loop_closure)
        end
    end

    def fast_loop()
        self.tick += 1
        if self.tick % self.frame_div != 0
            return
        end
        self.update_fire()
        self.draw_fire()
    end

    def update_fire()
        import crypto
        var heat = self.heat
        var total = self.total
        var w = self.w
        var h = self.h
        var coolmax = self.coolmax

        # Pre-generate all random numbers needed for this frame
        var rand_bytes = crypto.random(total + w)  # Enough for cooling + sparks
        
        # Step 1: Cool down - using pre-generated random numbers
        var i = 0
        while i < total
            var cooldown = rand_bytes[i] % coolmax
            var v = heat[i]
            heat[i] = (v > cooldown) ? v - cooldown : 0
            i += 1
        end

        # Step 2: Improved heat diffusion with better upward propagation
        # Process from bottom to top, averaging with neighbors
        var y = h - 1
        while y >= 1  # Start from the second row from the bottom
            var row = y * w
            var row_below = (y - 1) * w
            
            var x = 0
            while x < w
                var idx = row + x
                
                # Get left and right neighbors (with wrapping)
                var left = (x - 1 + w) % w
                var right = (x + 1) % w
                
                # Average the pixel below with its neighbors
                var avg = (heat[row_below + x] + 
                          heat[row_below + left] + 
                          heat[row_below + right]) / 3
                
                # Add some randomness to make it look more natural
                var rand_factor = 10 + (rand_bytes[idx] % 20)
                heat[idx] = (avg * 9 + rand_factor) / 10
                
                x += 1
            end
            y -= 1
        end

        # Step 3: Sparks at bottom - using pre-generated random numbers
        var x2 = 0
        while x2 < w
            if rand_bytes[total + x2] < 150  # Increased probability
                var idx2 = x2  # Bottom row is at index 0 to w-1
                if idx2 < total
                    var addv = 200 + (rand_bytes[total + x2] % 55)  # Higher base heat
                    var nv = heat[idx2] + addv
                    heat[idx2] = (nv > 255) ? 255 : nv
                end
            end
            x2 += 1
        end
    end

    def draw_fire()
        var heat = self.heat
        var w = self.w
        var h = self.h
        var total = self.total
        var palette = self.palette
        
        var y = 0
        while y < h
            var x = 0
            while x < w
                var idx = y * w + x
                if idx < total
                    var temperature = heat[idx]
                    
                    # Apply a slight gamma correction for better visual appearance
                    var corrected_temp = (temperature * temperature) / 255
                    if corrected_temp > 255
                        corrected_temp = 255
                    end
                    
                    self.matrix.set(x, (h - 1) - y, palette[corrected_temp])
                end
                x += 1
            end
            y += 1
        end
        self.strip.show()
    end
end

var fire = FIRE2012_DEMO_BYTES()