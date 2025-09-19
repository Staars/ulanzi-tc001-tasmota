import os, string, base64
from PIL import ImageFont

def generate_font_blob(font_path, point_size, order, cell_width, cell_height):
    font = ImageFont.truetype(font_path, point_size)
    widths = []
    raw_bytes = bytearray()

    for ch in order:
        # Render glyph
        bitmap = font.getmask(ch)
        w, h = bitmap.size

        # Convert to column-major bytes (1 byte per column for height <= 8)
        cols = []
        for x in range(w):
            col_byte = 0
            for y in range(min(h, cell_height)):
                if bitmap.getpixel((x, y)):
                    col_byte |= 1 << (7 - y)  # top bit = row 0
            cols.append(col_byte)

        # Effective width = rightmost non-empty column + 1
        eff_w = 0
        for cx in range(len(cols)-1, -1, -1):
            if cols[cx] != 0:
                eff_w = cx + 1
                break
        widths.append(eff_w)

        # Pad/truncate columns to cell_width
        cols = cols[:cell_width] + [0] * (cell_width - len(cols))
        # Append to raw_bytes, row-major (col bytes in sequence)
        raw_bytes.extend(cols)

    # Encode blob
    blob_b64 = base64.b64encode(bytes(raw_bytes)).decode('ascii')
    return {
        "width": cell_width,
        "height": cell_height,
        "order": order,
        "widths": widths,
        "data": blob_b64
    }

if __name__ == "__main__":
    order = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    font_path = "./monomin-6x5.ttf"
    point_size = 7
    cell_width = 5
    cell_height = 8

    packed = generate_font_blob(font_path, point_size, order, cell_width, cell_height)

    # Output as Berry var
    print("var MyFont = {")
    print(f"  'width': {packed['width']},")
    print(f"  'height': {packed['height']},")
    print(f"  'order': '{packed['order']}',")
    print(f"  'widths': {packed['widths']},")
    print(f"  'data': '{packed['data']}'")
    print("}")
