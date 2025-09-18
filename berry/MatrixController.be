class MatrixController
    var leds
    var matrix
    var font
    var font_width
    var row_size
    var col_size
    var long_string
    var long_string_offset

    def init(w, h, p)
        import gpio
        print("MatrixController Init")
        self.long_string = ""
        self.long_string_offset = 0
        self.col_size = w
        self.row_size = h

        if p >= 0
            # --- Hardware-backed mode ---
            self.leds = Leds(self.row_size * self.col_size, p)
            var buf = self.leds.pixels_buffer()
            var bpp = self.leds.pixel_size()
            self.matrix = Matrix(buf, self.col_size, self.row_size, bpp, true)  # serpentine
            self.leds.set_bri(127)  # default brightness / emulator
        else
            # --- Offscreen/virtual mode ---
            var bpp = 3  # RGB; change to 4 if RGBW target
            self.matrix = Matrix(self.col_size, self.row_size, bpp, true)  # serpentine
            self.leds = nil
        end

        self.change_font('MatrixDisplay3x5')
        self.clear()
    end

    def clear()
        if self.leds != nil
            self.leds.clear()
        end
    end

    def draw()
        if self.leds != nil
            self.leds.show()
        end
    end

    def change_font(font_key)
        import fonts
        self.font = fonts.font_map[font_key]['font']
        self.font_width = fonts.font_map[font_key]['width']
    end

    def set_matrix_pixel_color(x, y, color, brightness)
        self.matrix.set(x, y, color, brightness)
    end

    def print_binary(value, column, color, brightness)
        for i: 0..7
            if value & (1 << i) != 0
                self.matrix.set(column, i, color, brightness)
            end
        end
    end

    def print_char(char, x, y, collapse, color, brightness)
        var actual_width = collapse ? -1 : self.font_width
        if char == " "
            return self.font_width - 2
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
                    self.matrix.set(x+j, y+i+y_offset, color, brightness)
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
