import os
import string
from PIL import ImageFont

def generate_font_map(font_path, point_size, cell_width, cell_height, characters):
    font = ImageFont.truetype(font_path, point_size)
    font_map = {}
    for ch in characters:
        bitmap = font.getmask(ch)
        glyph_w, glyph_h = bitmap.size
        hex_array = []
        # Loop over the fixed cell height
        for y in range(cell_height):
            byte = 0
            bit_count = 0
            for x in range(cell_width):
                # Only read pixels if inside the actual glyph bounds
                if x < glyph_w and y < glyph_h and bitmap.getpixel((x, y)):
                    byte |= 1 << (7 - bit_count)
                bit_count += 1
                if bit_count == 8:
                    hex_array.append(byte)
                    byte = 0
                    bit_count = 0
            if bit_count > 0:
                hex_array.append(byte)
        if not hex_array:
            hex_array = [0]
        # Store as a Berry bytes() literal string
        bytes_literal = "bytes(\"" + "".join(f"{b:02x}" for b in hex_array) + "\")"
        font_map[ch] = { 'data': bytes_literal, 'width': glyph_w }
    return font_map

def write_fonts_be(output_path, mono5x8_map, tiny3x5_map):
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("#@solidify:fonts\n")
        f.write("var fonts = module(\"fonts\")\n\n")
        f.write("fonts.font_map = {\n")
        f.write("    'Mono5x8': {\n")
        f.write("        'font': {\n")
        for ch, info in mono5x8_map.items():
            f.write(f"            '{ch}': {{ 'data': {info['data']}, 'width': {info['width']} }},\n")
        f.write("        },\n")
        f.write("        'width': 5,\n")
        f.write("        'height': 8\n")
        f.write("    },\n")
        f.write("    'Tiny3x5': {\n")
        f.write("        'font': {\n")
        for ch, info in tiny3x5_map.items():
            f.write(f"            '{ch}': {{ 'data': {info['data']}, 'width': {info['width']} }},\n")
        f.write("        },\n")
        f.write("        'width': 3,\n")
        f.write("        'height': 5\n")
        f.write("    }\n")
        f.write("}\n\n")
        f.write("def font_width(font, ch)\n")
        f.write("    return font.font[ch].width\n")
        f.write("end\n\n")
        f.write("class Matrix end\n\n")
        f.write("def glyph_matrix(font, ch)\n")
        f.write("    var char_bitmap = font.font[ch].data\n")
        f.write("    var bytes_per_line = (font.width + 7) >> 3\n")
        f.write("    return Matrix(char_bitmap, bytes_per_line)\n")
        f.write("end\n\n")
        f.write("fonts.font_width = font_width\n")
        f.write("fonts.glyph_matrix = glyph_matrix\n\n")
        f.write("return fonts\n")

def main():
    characters = list(string.ascii_uppercase + string.ascii_lowercase +
                      string.digits + string.punctuation + " ")
    # remove problematic chars for Berry keys
    if "'" in characters:
        characters.remove("'")
    if "\\" in characters:
        characters.remove("\\")
    mono5x8_map = generate_font_map("./monomin-6x5.ttf", 7, 5, 8, characters)
    tiny3x5_map = generate_font_map("./tiny-3x5.ttf", 5, 3, 5, characters)
    write_fonts_be("./fonts.be", mono5x8_map, tiny3x5_map)

if __name__ == "__main__":
    main()
