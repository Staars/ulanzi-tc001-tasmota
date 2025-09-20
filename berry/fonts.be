import mono5x8
import tiny3x5

#@solidify:fonts
var fonts = module("fonts")

fonts.font_map = {}
for k in mono5x8.font_map.keys()
    fonts.font_map[k] = mono5x8.font_map[k]
end
for k in tiny3x5.font_map.keys()
    fonts.font_map[k] = tiny3x5.font_map[k]
end

def font_width(font, idx)
    var b = font.widths[idx >> 1]
    return (idx & 1) == 0 ? ((b >> 4) & 0x0F) : (b & 0x0F)
end

def glyph_matrix(font, idx)
    var bytes_per_line = (font.width + 7) >> 3
    var off = idx * bytes_per_line * font.height
    var len = bytes_per_line * font.height
    return Matrix(font.data[off .. off + len - 1], bytes_per_line)
end

fonts.font_width = font_width
fonts.glyph_matrix = glyph_matrix

return fonts
