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

    var override_leds

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

    # def _reverse_line(buffer) # for RGB only ATM - no RGBA yet
    #     var px_size = self.leds.pixel_size()
    #     var len = size(buffer)
    #     var pos = 0
    #     var b0
    #     while pos < len
    #         b0 = buffer[pos]
    #         buffer[pos] = buffer[pos+2]
    #         buffer[pos+2] = b0
    #         pos += px_size
    #     end
    #     return buffer.reverse()
    # end

    # def scroll_matrix(direction, outshift, inshift) # 0 - up, 1 - left, 2 - down, 3 - right ; outshift madatory, inshift optional
    #     var buf = self.leds.pixels_buffer()
    #     var px_size = self.leds.pixel_size()
    #     var w = self.matrix.w
    #     var h = self.matrix.h
    #     var sz = w * px_size
    #     var pos
    #     if direction%2 == 0 #up/down
    #         if direction == 0 #up
    #             outshift.setbytes(0,self._reverse_line(buf[0..sz-1]))
    #             var line = 0
    #             while line < (h-1)
    #                 pos = 0
    #                 var offset_dst = line * sz
    #                 var offset_src = ((line+2) * sz) - px_size
    #                 while pos < sz
    #                     var dst = pos + offset_dst
    #                     var src = offset_src - pos
    #                     buf[dst] = buf[src]
    #                     buf[dst+1] = buf[src+1]
    #                     buf[dst+2] = buf[src+2]
    #                     if px_size == 4 buf[dst+3] = buf[src+3] end
    #                     pos += px_size
    #                 end
    #                 line += 1
    #             end
    #             if h%2 == 1
    #                 outshift.setbytes(0,self._reverse_line(outshift))
    #             end
    #             buf.setbytes((h-1) * sz, outshift)
    #         else # down
    #             outshift = self._reverse_line(buf[size(buf)-sz..])
    #             var line = h - 1
    #             while line > 0
    #                 buf.setbytes(line * sz,self._reverse_line(buf[(line-1) * sz..line * sz-1]))
    #                 line -= 1
    #             end
    #             if h%2 == 1
    #                 outshift = self._reverse_line(outshift)
    #             end
    #             buf.setbytes(0, outshift)
    #         end
    #     else # left/right
    #         var pixel_copy = bytes(-px_size)
    #         var line = 0
    #         var step = px_size
    #         if direction == 3 # right
    #             step *= -1
    #         end
    #         while line < h
    #             pos = line * sz
    #             if step > 0
    #                 var line_end = pos + sz - step
    #                 outshift[(line * 3)] = buf[pos]
    #                 outshift[(line * 3) + 1] = buf[pos+1]
    #                 outshift[(line * 3) + 2] = buf[pos+2]
    #                 while pos < line_end
    #                     buf[pos] = buf[pos+3]
    #                     buf[pos+1] = buf[pos+4]
    #                     buf[pos+2] = buf[pos+5]
    #                     pos += step
    #                 end
    #                 if inshift == nil
    #                     buf[line_end] = outshift[(line * 3)]
    #                     buf[line_end+1] = outshift[(line * 3) + 1]
    #                     buf[line_end+2] = outshift[(line * 3) + 2]
    #                 else
    #                     buf[line_end] = inshift[(line * 3)]
    #                     buf[line_end+1] = inshift[(line * 3) + 1]
    #                     buf[line_end+2] = inshift[(line * 3) + 2]
    #                 end
    #             else
    #                 var line_end = pos
    #                 pos = pos + sz + step
    #                 outshift[(line * 3)] = buf[pos]
    #                 outshift[(line * 3) + 1] = buf[pos+1]
    #                 outshift[(line * 3) + 2] = buf[pos+2]
    #                 while pos > line_end
    #                     buf[pos] = buf[pos-3]
    #                     buf[pos+1] = buf[pos-2]
    #                     buf[pos+2] = buf[pos-1]
    #                     pos += step
    #                 end
    #                 if inshift == nil
    #                     buf[line_end] = outshift[(line * 3)]
    #                     buf[line_end+1] = outshift[(line * 3) + 1]
    #                     buf[line_end+2] = outshift[(line * 3) + 2]
    #                 else
    #                     buf[line_end] = inshift[(line * 3)]
    #                     buf[line_end+1] = inshift[(line * 3) + 1]
    #                     buf[line_end+2] = inshift[(line * 3) + 2]
    #                 end
    #             end
    #             step *= -1
    #             line += 1
    #         end
    #     end
    # end

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

        if self.font.contains(char) == false
            print("Font does not contain char: ", char)
            return 0
        end

        var char_bitmap = bytes().fromb64(self.font[char])
        var font_height = size(char_bitmap)
        for i: 0..(font_height-1)
            var code = char_bitmap[i]
            for j: 0..7
                if code & (1 << (7 - j)) != 0
                    self.set_matrix_pixel_color(x+j, y+i, color, brightness)

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

    # Taken straight from the tasmota berry source-code
    # https://github.com/arendst/Tasmota/blob/e9d1e8c7250d89a24ade0c42a64731d6c492bbb2/lib/libesp32/berry_tasmota/src/embedded/leds.be#L158-L172
    # def to_gamma(rgbw, bri)
    #    bri = (bri != nil) ? bri : 100
    #    var r = tasmota.scale_uint(bri, 0, 100, 0, (rgbw & 0xFF0000) >> 16)
    #    var g = tasmota.scale_uint(bri, 0, 100, 0, (rgbw & 0x00FF00) >> 8)
    #    var b = tasmota.scale_uint(bri, 0, 100, 0, (rgbw & 0x0000FF))

    #    return light.gamma8(r) << 16 |
    #           light.gamma8(g) <<  8 |
    #           light.gamma8(b)
    # end
end

return MatrixController
