import fonts

class MatrixController
    var leds
    var matrix
    var font
    var font_width
    var row_size
    var col_size
    var long_string
    var long_string_offset

    var prev_color
    var prev_brightness
    var prev_corrected_color

    def init(w,h,p)
        import gpio
        print("MatrixController Init")
        self.long_string = ""
        self.long_string_offset = 0
        self.col_size = w
        self.row_size = h
        if p == nil
            p = gpio.pin(gpio.WS2812, 0)
        end
        self.leds = Leds(
            self.row_size * self.col_size,
            p
        )
        self.leds.gamma = false
        self.matrix = self.leds.create_matrix(self.col_size, self.row_size)
        self.matrix.set_alternate(true)

        self.change_font('MatrixDisplay3x5')

        self.leds.set_bri(127) # for emulator

        self.clear()

        self.prev_color = 0
        self.prev_brightness = 0
        self.prev_corrected_color = 0
    end

    def clear()
        var pbuf = self.matrix.pixels_buffer()
        for i:range(0,size(pbuf)-1)
            pbuf[i] = 0
        end
        self.matrix.dirty()
    end

    def draw()
        self.matrix.show()
    end

    def change_font(font_key)
        self.font = fonts.font_map[font_key]['font']
        self.font_width = fonts.font_map[font_key]['width']
    end

    # x is the column, y is the row, (0,0) from the top left
    def set_matrix_pixel_color(x, y, color, brightness)
        # if y is odd, reverse the order of y
        if y & 1 == 1
            x = self.col_size - x - 1
        end

        if x < 0 || x >= self.col_size || y < 0 || y >= self.row_size
            # print("Invalid pixel: ", x, ", ", y)
            return
        end

        # Cache brightness calculation and gamma correction for this tuple of bri, color
        if brightness != self.prev_brightness || color != self.prev_color
            self.prev_brightness = brightness
            self.prev_color = color
            self.prev_corrected_color = self.leds.to_gamma(color, brightness)
        end

        # call the native function directly, bypassing set_matrix_pixel_color, to_gamma etc
        # this is faster as otherwise to_gamma would be called for every single pixel even if they are the same
        # self.leds.call_native(10, y * self.col_size + x, self.prev_corrected_color)
        self.leds.set_pixel_color(y * self.col_size + x, self.prev_corrected_color)        
    end

    # set pixel column to binary value
    def print_binary(value, column, color, brightness)
        for i: 0..7
            if value & (1 << i) != 0
                # print("set pixel ", i, " to 1")
                self.set_matrix_pixel_color(column, i, color, brightness)
            end
        end
    end

    def print_char(char, x, y, collapse, color, brightness)
        var actual_width = collapse ? -1 : self.font_width

        if char == " "
            return self.font_width - 2 # no collapse to zero
        end

        if self.font.contains(char) == false
            print("Font does not contain char: ", char)
            return 0
        end

        var char_bitmap = bytes().fromb64(self.font[char])
        var font_height = size(char_bitmap)
        var y_offset = 7 - font_height
        for i: 0..(font_height-1)
            var code = char_bitmap[i]
            for j: 0..self.font_width
                if code & (1 << (7 - j)) != 0
                    self.set_matrix_pixel_color(x+j, y+i+y_offset, color, brightness)
                    if j > actual_width
                        actual_width = j
                    end
                end
            end
        end

        return collapse ? actual_width + 1 : actual_width
    end

    def print_string(string, x, y, collapse, color, brightness)
        var char_offset = 0

        for i: 0..(size(string)-1)
            var actual_width = 0

            if x + char_offset > 1 - self.font_width
                actual_width = self.print_char(string[i], x + char_offset, y, collapse, color, brightness)
            end

            if actual_width == 0
                actual_width = 1
            end

            char_offset += actual_width + 1
            self.print_binary(0, x + char_offset, y, color, brightness)
        end
    end

end

return MatrixController
