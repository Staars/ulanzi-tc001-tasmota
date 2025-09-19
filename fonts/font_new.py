import os
from PIL import ImageFont

def generate_font_blob(font_path, point_size, order, cell_width, cell_height):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    abs_font_path = os.path.join(script_dir, font_path)
    if not os.path.exists(abs_font_path):
        raise FileNotFoundError(f"Font file not found: {abs_font_path}")

    font = ImageFont.truetype(abs_font_path, point_size)
    widths = []
    raw_bytes = bytearray()

    for ch in order:
        bitmap = font.getmask(ch)
        w, h = bitmap.size

        cols = []
        for x in range(w):
            col_byte = 0
            for y in range(min(h, cell_height)):
                if bitmap.getpixel((x, y)):
                    col_byte |= 1 << (7 - y)
            cols.append(col_byte)

        eff_w = 0
        for cx in range(len(cols) - 1, -1, -1):
            if cols[cx] != 0:
                eff_w = cx + 1
                break
        widths.append(eff_w)

        cols = cols[:cell_width] + [0] * (cell_width - len(cols))
        raw_bytes.extend(cols)

    packed_widths = bytearray()
    for i in range(0, len(widths), 2):
        w1 = widths[i] & 0x0F
        w2 = widths[i + 1] & 0x0F if i + 1 < len(widths) else 0
        packed_widths.append((w1 << 4) | w2)

    return {
        "width": cell_width,
        "height": cell_height,
        "first_char": ord(order[0]),
        "count": len(order),
        "widths_hex": packed_widths.hex(),
        "data_hex": raw_bytes.hex()
    }

if __name__ == "__main__":
    order = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

    font_specs = [
        {
            "name": "Mono5x8",
            "path": "monomin-6x5.ttf",
            "size": 7,
            "cell_width": 5,
            "cell_height": 8
        },
        {
            "name": "Tiny3x5",
            "path": "tiny-3x5.ttf",
            "size": 5,
            "cell_width": 3,
            "cell_height": 5
        }
    ]

    print("#@solidify:fonts")
    print("var fonts = module(\"fonts\")\n")

    font_map_entries = []

    for spec in font_specs:
        packed = generate_font_blob(
            spec["path"], spec["size"], order,
            spec["cell_width"], spec["cell_height"]
        )
        var_name = spec["name"]
        print(f"fonts.{var_name} = {{")
        print(f"  'width': {packed['width']},")
        print(f"  'height': {packed['height']},")
        print(f"  'first_char': {packed['first_char']},")
        print(f"  'count': {packed['count']},")
        print(f"  'widths': bytes(\"{packed['widths_hex']}\"),")
        print(f"  'data': bytes(\"{packed['data_hex']}\")")
        print("}\n")
        font_map_entries.append(f"    '{var_name}': fonts.{var_name}")

    print("fonts.font_map = {")
    print(",\n".join(font_map_entries))
    print("}\n")

    # Helpers as top-level defs, then assign to module
    print("# Helper: unpack nibble-packed widths")
    print("def font_width(font, idx)")
    print("    var b = font.widths[idx >> 1]")
    print("    return (idx & 1) == 0 ? ((b >> 4) & 0x0F) : (b & 0x0F)")
    print("end\n")

    print("# Helper: wrap a glyph's bit-lines directly as a 1‑bpp Matrix")
    print("def glyph_matrix(font, idx)")
    print("    var bytes_per_line = (font.width + 7) >> 3")
    print("    var off = idx * bytes_per_line * font.height")
    print("    var len = bytes_per_line * font.height")
    print("    return Matrix(font.data[off .. off + len - 1], bytes_per_line)")
    print("end\n")

    print("fonts.font_width = font_width")
    print("fonts.glyph_matrix = glyph_matrix\n")

    print("return fonts")
