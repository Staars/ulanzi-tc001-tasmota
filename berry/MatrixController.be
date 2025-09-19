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
            var bpp = 3  # RGB
            self.matrix = Matrix(self.col_size, self.row_size, bpp, true)  # serpentine
            self.leds = nil
        end

        self.change_font('MatrixDisplay3x5')
        self.clear()
    end

    def clear()
        self.matrix.clear(0)
    end

    def draw()
        if self.leds != nil
            self.leds.show()
        end
    end

    def change_font(font_key)
        import fonts
        var f = fonts.font_map[font_key]
        self.font = f['font']       # packed font object
        self.font_width = f['width']
    end

    def set_matrix_pixel_color(x, y, color, brightness)
        self.matrix.set(x, y, color, brightness)
    end

    # --- print_char using fonts.glyph_matrix() ---
    def print_char(ch, x, y, collapse, tint, brightness)
        var idx = ord(ch) - self.font.first_char
        if idx < 0 || idx >= self.font.count return 1 end

        var eff_w = fonts.font_width(self.font, idx)
        var glyph = Matrix(fonts.glyph_bytes(self.font, idx),
                        (self.font.width + 7) >> 3)

        self.matrix.blit(glyph, x, y, brightness, tint)
        return collapse ? eff_w : self.font.width
    end

    def print_string(string, x, y, collapse, color, brightness)
        var cursor = 0
        for ch in string
            cursor += self.print_char(ch, x + cursor, y, collapse, color, brightness) + 1
        end
    end
end

return MatrixController
