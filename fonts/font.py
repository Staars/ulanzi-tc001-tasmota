import os
import string
from PIL import ImageFont
import base64


def print_hex_as_binary(hex_string):
    binary_string = "".join([bin(int(hex_str, 16))[2:].zfill(8)
                            for hex_str in hex_string.split(", ")])
    for i in range(0, len(binary_string), 8):
        print(binary_string[i:i+8])


def generate_hex_strings(font_path, point_size, characters):
    font = ImageFont.truetype(font_path, point_size)
    hex_strings = {}
    for char in characters:
        bitmap = font.getmask(char)
        width, height = bitmap.size
        print(f"Char '{char}': {width}x{height}")
        hex_array = []
        for y in range(height):
            for x in range(0, width, 8):
                byte = 0
                for i in range(8):
                    if x+i < width and bitmap.getpixel((x+i, y)):
                        byte |= 1 << (7-i)
                hex_array.append(f"0x{byte:02x}")
            hex_string = ", ".join(hex_array)
        # if hex string is less then 5 bytes, pad with 0x00 in front
        if len(hex_array) == 0:
            hex_string = "0x00, 0x00, 0x00, 0x00, 0x00"
        elif len(hex_array) < 5:
            hex_string = ", ".join(["0x00"] * (5-len(hex_array))) + ", " + hex_string
        hex_strings[char] = hex_string
        print(f"Char '{char}': {hex_string}")
        print_hex_as_binary(hex_string)
    return hex_strings


def save_hex_strings_to_file(hex_strings, filename):
    with open(filename, 'w') as f:
        f.write("var font = {\n")
        for char, hex_string in hex_strings.items():
            f.write(f"'{char}': [{hex_string}],\n")
        f.write("}")

def save_hex_strings_to_bytes_file(hex_strings, filename):
    with open(filename, 'w') as f:
        f.write("var font = {\n")
        for char, hex_string in hex_strings.items():
            hex_string = hex_string.split(",")
            buf_string = ""
            for it in hex_string:
                buf_string += it.replace("0x","").replace(" ","")
            f.write(f"'{char}': '{buf_string}',\n")
        f.write("}")

def save_hex_strings_to_b64_file(hex_strings, filename):
    with open(filename, 'w') as f:
        f.write("var font = {\n")
        for char, hex_string in hex_strings.items():
            hex_string = hex_string.split(",")
            buf_string = ""
            for it in hex_string:
                buf_string += it.replace("0x","").replace(" ","")
            b = bytes.fromhex(buf_string)
            base64_bytes = base64.b64encode(b)
            f.write(f"'{char}': '{base64_bytes.decode("ascii")}',\n")
        f.write("}")


def main():
    point_size = 7
    font_path = os.path.join(".", "monomin-6x5.ttf")
    characters = [char for char in string.ascii_uppercase]
    characters += [char for char in string.ascii_lowercase]
    characters += [char for char in string.digits]
    characters += [char for char in string.punctuation]
    characters += [" "]
    # remove single quote
    characters.remove("'")
    characters.remove("\\")
    hex_strings = generate_hex_strings(font_path, point_size, characters)
    filename = "./hex_strings.txt"
    save_hex_strings_to_file(hex_strings, filename)
    filename = "./hex_strings_bytes.txt"
    save_hex_strings_to_bytes_file(hex_strings, filename)
    filename = "./hex_strings_b64.txt"
    save_hex_strings_to_b64_file(hex_strings, filename)


if __name__ == "__main__":
    main()
