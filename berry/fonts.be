import mono5x8
import tiny3x5

class Matrix end

def _font_width(font, idx)
    var b = font.widths[idx >> 1]
    return (idx & 1) == 0 ? ((b >> 4) & 0x0F) : (b & 0x0F)
end

def _glyph_matrix(font, idx)
    var bpl = (font.width + 7) >> 3
    var off = idx * bpl * font.height
    var len = bpl * font.height
    return Matrix(font.data[off .. off + len - 1], bpl)
end

def get_font_slice(base, ch)
    var code = ord(ch)
    var start = (code / 32) * 32
    var end = start + 31
    var key = base .. "_" .. str(start) .. "_" .. str(end)
    return font_slices[key]
end

def font_width(base, ch)
    var slice = get_font_slice(base, ch)
    var idx = ord(ch) - slice.first_char
    return (idx < 0 || idx >= slice.count) ? 0 : _font_width(slice, idx)
end

def glyph_matrix(base, ch)
    var slice = get_font_slice(base, ch)
    var idx = ord(ch) - slice.first_char
    return (idx < 0 || idx >= slice.count) ? nil : _glyph_matrix(slice, idx)
end

#@solidify:fonts
var fonts = module("fonts")

fonts.font_map = {
  'Mono5x8': mono5x8,
  'Tiny3x5': tiny3x5
}

fonts.font_slices = {}
for k in mono5x8.font_map.keys()
    fonts.font_slices[k] = mono5x8.font_map[k]
end
for k in tiny3x5.font_map.keys()
    fonts.font_slices[k] = tiny3x5.font_map[k]
end

fonts.font_width = font_width
fonts.glyph_matrix = glyph_matrix
return fonts
