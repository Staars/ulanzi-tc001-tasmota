import string
import base64
from PIL import Image, ImageFont  # global import

# -------------------------------------------------
# CONFIG
# -------------------------------------------------
FONTS = [
    {
        "name": "MatrixDisplay3x5",
        "file": "3x5MatrixDisplay.ttf",
        "cell_width": 3,
        "cell_height": 5,
        "max_width": 3
    },
    {
        "name": "TinyUnicode",
        "file": "TinyUnicode.ttf",
        "cell_width": 5,
        "cell_height": 7,
        "max_width": 5
    }
]

POINT_SIZE = 16
PREVIEW_SPACING_X = 2
PREVIEW_SPACING_Y = 2
MIN_TOTAL_BYTES = 5

CHARS = (
    string.ascii_uppercase +
    string.ascii_lowercase +
    string.digits +
    string.punctuation +
    " "
)
CHARS = CHARS.replace("'", "").replace("\\", "")

OUTPUT_BE = "fonts.be"

# -------------------------------------------------
# CORE LOGIC (left-trim columns, baseline y from cell_h - glyph_h)
# -------------------------------------------------
def glyph_bytes_width_y(font, ch, cell_w, cell_h):
    bitmap = font.getmask(ch)
    gw, gh = bitmap.size  # glyph mask width/height (tight box)

    # Compute vertical offset relative to baseline (bottom of cell)
    # Push shorter glyphs down so they sit on the bottom row(s).
    y_offset = max(0, cell_h - min(gh, cell_h))

    # Find horizontal bounds for left-trim
    first_col = None
    last_col = None
    for y in range(gh):
        for x in range(gw):
            if bitmap.getpixel((x, y)):
                if first_col is None or x < first_col:
                    first_col = x
                if last_col is None or x > last_col:
                    last_col = x

    if first_col is None:
        # Empty glyph
        actual_w = 0
        cell_img = Image.new("1", (cell_w, cell_h), 0)
    else:
        actual_w = last_col - first_col + 1

        # Build glyph image from mask
        glyph_img = Image.new("1", (gw, gh), 0)
        for y in range(gh):
            for x in range(gw):
                if bitmap.getpixel((x, y)):
                    glyph_img.putpixel((x, y), 1)

        # Crop horizontally only (keep full vertical extent gh)
        trimmed_cols = glyph_img.crop((first_col, 0, last_col + 1, gh))

        # Paste into fixed cell at top-left (top-aligned in data)
        cell_img = Image.new("1", (cell_w, cell_h), 0)
        paste_w = min(trimmed_cols.width, cell_w)
        paste_h = min(trimmed_cols.height, cell_h)
        cell_img.paste(trimmed_cols.crop((0, 0, paste_w, paste_h)), (0, 0, paste_w, paste_h))

    # Pack bits row-wise from fixed-size cell
    data_bytes = bytearray()
    pix = cell_img.load()
    for y in range(cell_h):
        row = 0
        for x in range(cell_w):
            if pix[x, y]:
                row |= (1 << (7 - x))
        data_bytes.append(row)

    # Pad to minimum total bytes (leading zeros)
    if len(data_bytes) < MIN_TOTAL_BYTES:
        data_bytes = bytearray([0x00] * (MIN_TOTAL_BYTES - len(data_bytes))) + data_bytes

    b64 = base64.b64encode(bytes(data_bytes)).decode("ascii")
    return b64, actual_w, y_offset, cell_img

# -------------------------------------------------
# PREVIEW RENDERING
# -------------------------------------------------
def save_preview_png(font, name, cell_w, cell_h, out_path):
    cols = 16
    rows = (len(CHARS) + cols - 1) // cols
    img_w = cols * (cell_w + PREVIEW_SPACING_X) - PREVIEW_SPACING_X
    img_h = rows * (cell_h + PREVIEW_SPACING_Y) - PREVIEW_SPACING_Y

    sheet = Image.new("1", (img_w, img_h), 0)

    for idx, ch in enumerate(CHARS):
        _, _, _, cell_img = glyph_bytes_width_y(font, ch, cell_w, cell_h)
        x = (idx % cols) * (cell_w + PREVIEW_SPACING_X)
        y = (idx // cols) * (cell_h + PREVIEW_SPACING_Y)
        sheet.paste(cell_img, (x, y, x + cell_w, y + cell_h))

    sheet.convert("L").save(out_path)
    print(f"🖼  Saved preview image: {out_path}")

# -------------------------------------------------
# FONTS.BE GENERATION
# -------------------------------------------------
with open(OUTPUT_BE, "w", encoding="utf-8") as f:
    for info in FONTS:
        name = info["name"]
        ttf = info["file"]
        cell_w = info["cell_width"]
        cell_h = info["cell_height"]

        font = ImageFont.truetype(ttf, size=POINT_SIZE)

        f.write(f"var {name} = {{\n")

        for ch in CHARS:
            b64, w, y_off, _ = glyph_bytes_width_y(font, ch, cell_w, cell_h)
            f.write(f"    '{ch}': {{ 'b': '{b64}', 'w': {w}, 'y': {y_off} }},\n")

        f.write("}\n\n")

        save_preview_png(font, name, cell_w, cell_h, f"{name}_preview.png")

    # Footer
    f.write("#@ solidify:fonts\n")
    f.write('var fonts = module("fonts")\n')
    f.write("fonts.font_map = {\n")
    for info in FONTS:
        f.write(f"    '{info['name']}': {{ 'font': {info['name']}, 'width': {info['max_width']} }},\n")
    f.write("}\n")
    f.write("fonts.palette = {\n")
    f.write("    'black': 0x000000,\n")
    f.write("    'white': 0xFFFFFF,\n")
    f.write("    'red': 0xFF0000,\n")
    f.write("    'orange': 0xFFA500,\n")
    f.write("    'yellow': 0xFFDD00,\n")
    f.write("    'green': 0x008800,\n")
    f.write("    'blue': 0x0000FF,\n")
    f.write("    'indigo': 0x4B0082,\n")
    f.write("    'violet': 0xEE82EE,\n")
    f.write("}\n")
    f.write("return fonts\n")

print("✅ fonts.be written with left-trimmed columns, accurate widths, and baseline-aligned y offsets.")
