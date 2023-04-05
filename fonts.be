var TinyUnicode = {
'A': [0x60, 0x90, 0xf0, 0x90, 0x90],
'B': [0xe0, 0x90, 0xe0, 0x90, 0xe0],
'C': [0x60, 0x80, 0x80, 0x80, 0x60],
'D': [0xe0, 0x90, 0x90, 0x90, 0xe0],
'E': [0xe0, 0x80, 0xc0, 0x80, 0xe0],
'F': [0xe0, 0x80, 0xe0, 0x80, 0x80],
'G': [0x70, 0x80, 0xb0, 0x90, 0x70],
'H': [0x90, 0x90, 0xf0, 0x90, 0x90],
'I': [0xe0, 0x40, 0x40, 0x40, 0xe0],
'J': [0x70, 0x10, 0x10, 0x90, 0x60],
'K': [0x90, 0xa0, 0xc0, 0xa0, 0x90],
'L': [0x80, 0x80, 0x80, 0x80, 0xe0],
'M': [0x88, 0xd8, 0xa8, 0x88, 0x88],
'N': [0x90, 0xd0, 0xb0, 0x90, 0x90],
'O': [0x60, 0x90, 0x90, 0x90, 0x60],
'P': [0xe0, 0x90, 0xe0, 0x80, 0x80],
'Q': [0x60, 0x90, 0x90, 0x90, 0x60, 0x10],
'R': [0xe0, 0x90, 0x90, 0xe0, 0x90],
'S': [0x70, 0x80, 0x60, 0x10, 0xe0],
'T': [0xe0, 0x40, 0x40, 0x40, 0x40],
'U': [0x90, 0x90, 0x90, 0x90, 0x60],
'V': [0x90, 0x90, 0xa0, 0xa0, 0x40],
'W': [0x88, 0x88, 0xa8, 0xa8, 0x50],
'X': [0x90, 0x90, 0x60, 0x90, 0x90],
'Y': [0x90, 0x90, 0x70, 0x10, 0x60],
'Z': [0xe0, 0x20, 0x40, 0x80, 0xe0],
'a': [0x70, 0x90, 0x90, 0x70],
'b': [0x80, 0xe0, 0x90, 0x90, 0xe0],
'c': [0x60, 0x80, 0x80, 0x60],
'd': [0x10, 0x70, 0x90, 0x90, 0x70],
'e': [0x60, 0xb0, 0xc0, 0x60],
'f': [0x60, 0x40, 0xe0, 0x40, 0x40],
'g': [0x70, 0x90, 0x90, 0x70, 0x10, 0x60],
'h': [0x80, 0xe0, 0x90, 0x90, 0x90],
'i': [0x80, 0x00, 0x80, 0x80, 0x80],
'j': [0x40, 0x00, 0x40, 0x40, 0x40, 0x40, 0x80],
'k': [0x80, 0x90, 0xa0, 0xe0, 0x90],
'l': [0x80, 0x80, 0x80, 0x80, 0x80],
'm': [0xf0, 0xa8, 0xa8, 0xa8],
'n': [0xe0, 0x90, 0x90, 0x90],
'o': [0x60, 0x90, 0x90, 0x60],
'p': [0xe0, 0x90, 0x90, 0xe0, 0x80, 0x80],
'q': [0x70, 0x90, 0x90, 0x70, 0x10, 0x10],
'r': [0xa0, 0xc0, 0x80, 0x80],
's': [0x70, 0xc0, 0x30, 0xe0],
't': [0x40, 0xe0, 0x40, 0x40, 0x60],
'u': [0x90, 0x90, 0x90, 0x70],
'v': [0x90, 0x90, 0xa0, 0x40],
'w': [0x88, 0xa8, 0xa8, 0x50],
'x': [0xa0, 0x40, 0x40, 0xa0],
'y': [0x90, 0x90, 0x90, 0x70, 0x10, 0xe0],
'z': [0xf0, 0x20, 0x40, 0xf0],
'0': [0x60, 0x90, 0x90, 0x90, 0x60],
'1': [0x40, 0xc0, 0x40, 0x40, 0x40],
'2': [0x60, 0x90, 0x20, 0x40, 0xf0],
'3': [0xe0, 0x10, 0x70, 0x10, 0xe0],
'4': [0x20, 0x60, 0xa0, 0xf0, 0x20],
'5': [0xf0, 0x80, 0xe0, 0x10, 0xe0],
'6': [0x60, 0x80, 0xe0, 0x90, 0x60],
'7': [0xf0, 0x10, 0x20, 0x40, 0x40],
'8': [0x60, 0x90, 0x60, 0x90, 0x60],
'9': [0x60, 0x90, 0x70, 0x10, 0x60],
'!': [0x80, 0x80, 0x80, 0x00, 0x80],
'"': [0xa0, 0xa0, 0x00, 0x00, 0x00, 0x00],
'#': [0x28, 0x50, 0xf8, 0x50, 0xa0],
'$': [0x40, 0x70, 0xc0, 0x30, 0xe0, 0x20],
'%': [0xa0, 0x20, 0x40, 0x80, 0xa0],
'&': [0x60, 0x80, 0x68, 0x90, 0x68],
'(': [0x40, 0x80, 0x80, 0x80, 0x80, 0x80, 0x40],
')': [0x80, 0x40, 0x40, 0x40, 0x40, 0x40, 0x80],
'*': [0xa0, 0x40, 0xa0, 0x00, 0x00, 0x00],
'+': [0x40, 0xe0, 0x40, 0x00],
',': [0x40, 0x80],
'-': [0xe0, 0x00, 0x00],
'.': [0x80],
'/': [0x20, 0x20, 0x40, 0x80, 0x80],
':': [0x80, 0x00, 0x80],
';': [0x40, 0x00, 0x40, 0x80],
'<': [0x40, 0x80, 0x40, 0x00],
'=': [0xf0, 0x00, 0xf0, 0x00],
'>': [0x80, 0x40, 0x80, 0x00],
'?': [0xe0, 0x10, 0x60, 0x00, 0x40],
'@': [0x3c, 0x42, 0x9a, 0xaa, 0x9c, 0x40, 0x3c],
'[': [0xc0, 0x80, 0x80, 0x80, 0x80, 0xc0],
']': [0xc0, 0x40, 0x40, 0x40, 0x40, 0xc0],
'^': [0x40, 0xa0, 0x00, 0x00, 0x00],
'_': [0xf8],
'`': [0x80, 0x40, 0x00, 0x00, 0x00],
'{': [0x60, 0x40, 0x40, 0x80, 0x40, 0x40, 0x60],
'|': [0x80, 0x80, 0x80, 0x80, 0x80],
'}': [0xc0, 0x40, 0x40, 0x20, 0x40, 0x40, 0xc0],
'~': [0x48, 0xa8, 0x90, 0x00],
' ': [0x48, 0xa8, 0x90, 0x00],
}

var MatrixDisplay3x5 = {
'A': [0xe0, 0xa0, 0xe0, 0xa0, 0xa0],
'B': [0xe0, 0xa0, 0xe0, 0xa0, 0xe0],
'C': [0xe0, 0x80, 0x80, 0x80, 0xe0],
'D': [0xe0, 0xa0, 0xa0, 0xa0, 0xe0],
'E': [0xe0, 0x80, 0xe0, 0x80, 0xe0],
'F': [0xe0, 0x80, 0xe0, 0x80, 0x80],
'G': [0xe0, 0x80, 0xe0, 0xa0, 0xe0],
'H': [0xa0, 0xa0, 0xe0, 0xa0, 0xa0],
'I': [0xe0, 0x40, 0x40, 0x40, 0xe0],
'J': [0x60, 0x20, 0x20, 0xa0, 0xe0],
'K': [0xa0, 0xa0, 0xc0, 0xa0, 0xa0],
'L': [0x80, 0x80, 0x80, 0x80, 0xe0],
'M': [0xe0, 0xe0, 0xe0, 0xa0, 0xa0],
'N': [0xa0, 0xe0, 0xa0, 0xa0, 0xa0],
'O': [0xe0, 0xa0, 0xa0, 0xa0, 0xe0],
'P': [0xe0, 0xa0, 0xe0, 0x80, 0x80],
'Q': [0xe0, 0xa0, 0xa0, 0xe0, 0x20],
'R': [0xe0, 0xa0, 0xe0, 0xa0, 0xa0],
'S': [0xe0, 0x80, 0xe0, 0x20, 0xe0],
'T': [0xe0, 0x40, 0x40, 0x40, 0x40],
'U': [0xa0, 0xa0, 0xa0, 0xa0, 0xe0],
'V': [0xa0, 0xa0, 0xa0, 0xa0, 0x40],
'W': [0xa0, 0xa0, 0xe0, 0xe0, 0xe0],
'X': [0xa0, 0xa0, 0xe0, 0xa0, 0xa0],
'Y': [0xa0, 0xa0, 0xe0, 0x40, 0x40],
'Z': [0xe0, 0x20, 0xe0, 0x80, 0xe0],
'a': [0x60, 0xa0, 0x60, 0x00, 0x00],
'b': [0x80, 0x80, 0xe0, 0xa0, 0xe0],
'c': [0xe0, 0x80, 0xe0, 0x00, 0x00],
'd': [0x20, 0x20, 0xe0, 0xa0, 0xe0],
'e': [0xe0, 0xa0, 0xe0, 0x80, 0xe0],
'f': [0x60, 0x40, 0xe0, 0x40, 0x40],
'g': [0xe0, 0xa0, 0xe0, 0x20, 0xe0],
'h': [0x80, 0x80, 0xe0, 0xa0, 0xa0],
'i': [0x40, 0x00, 0x40, 0x40, 0x60],
'j': [0x40, 0x00, 0x40, 0x40, 0xc0],
'k': [0x80, 0x80, 0xa0, 0xe0, 0xa0],
'l': [0x40, 0x40, 0x40, 0x40, 0x60],
'm': [0xe0, 0xe0, 0xa0, 0x00, 0x00],
'n': [0xe0, 0xa0, 0xa0, 0x00, 0x00],
'o': [0xe0, 0xa0, 0xe0, 0x00, 0x00],
'p': [0xe0, 0xa0, 0xe0, 0x80, 0x80],
'q': [0xe0, 0xa0, 0xe0, 0x20, 0x20],
'r': [0xe0, 0x80, 0x80, 0x00, 0x00],
's': [0xe0, 0x80, 0xe0, 0x20, 0xe0],
't': [0x40, 0x40, 0xe0, 0x40, 0x60],
'u': [0xa0, 0xa0, 0xe0, 0x00, 0x00],
'v': [0xa0, 0xa0, 0x40, 0x00, 0x00],
'w': [0xa0, 0xe0, 0xe0, 0x00, 0x00],
'x': [0xa0, 0x40, 0xa0, 0x00, 0x00],
'y': [0xa0, 0x40, 0x80, 0x00, 0x00],
'z': [0xe0, 0x20, 0xe0, 0x80, 0xe0],
'0': [0xe0, 0xa0, 0xa0, 0xa0, 0xe0],
'1': [0x40, 0xc0, 0x40, 0x40, 0xe0],
'2': [0xe0, 0x20, 0xe0, 0x80, 0xe0],
'3': [0xe0, 0x20, 0xe0, 0x20, 0xe0],
'4': [0xa0, 0xa0, 0xe0, 0x20, 0x20],
'5': [0xe0, 0x80, 0xe0, 0x20, 0xe0],
'6': [0xe0, 0x80, 0xe0, 0xa0, 0xe0],
'7': [0xe0, 0x20, 0x20, 0x20, 0x20],
'8': [0xe0, 0xa0, 0xe0, 0xa0, 0xe0],
'9': [0xe0, 0xa0, 0xe0, 0x20, 0xe0],
'!': [0x40, 0x40, 0x40, 0x00, 0x40],
'"': [0xa0, 0xa0, 0x00, 0x00, 0x00],
'#': [0xa0, 0xe0, 0xa0, 0xe0, 0xa0],
'$': [0xe0, 0xc0, 0xe0, 0x60, 0xe0],
'%': [0xa0, 0x20, 0xe0, 0x80, 0xa0],
'&': [0xe0, 0xa0, 0xe0, 0xa0, 0xe0],
'(': [0x60, 0x40, 0x40, 0x40, 0x60],
')': [0xc0, 0x40, 0x40, 0x40, 0xc0],
'*': [0xe0, 0x40, 0xe0, 0x00, 0x00],
'+': [0x40, 0xe0, 0x40, 0x00, 0x00],
',': [0x40, 0x40, 0x00, 0x00, 0x00],
'-': [0x00, 0x00, 0xe0, 0x00, 0x00],
'.': [0x00, 0x00, 0x00, 0x00, 0x40],
'/': [0x20, 0x20, 0xe0, 0x80, 0x80],
':': [0x00, 0x40, 0x00, 0x40, 0x00],
';': [0x40, 0x00, 0x40, 0x40, 0x00],
'<': [0x20, 0x40, 0x80, 0x40, 0x20],
'=': [0xe0, 0x00, 0xe0, 0x00, 0x00],
'>': [0x80, 0x40, 0x20, 0x40, 0x80],
'?': [0xe0, 0x20, 0x60, 0x00, 0x40],
'@': [0xe0, 0xa0, 0xe0, 0xa0, 0xe0],
'[': [0xc0, 0x80, 0x80, 0x80, 0xc0],
']': [0x60, 0x20, 0x20, 0x20, 0x60],
'^': [0x40, 0xa0, 0x00, 0x00, 0x00],
'_': [0xe0, 0x00, 0x00, 0x00, 0x00],
'`': [0x80, 0x40, 0x00, 0x00, 0x00],
'{': [0x60, 0x40, 0xc0, 0x40, 0x60],
'|': [0x40, 0x40, 0x40, 0x40, 0x40],
'}': [0xc0, 0x40, 0x60, 0x40, 0xc0],
'~': [0x20, 0xe0, 0x80, 0x00, 0x00],
' ': [0x00, 0x00, 0x00, 0x00, 0x00],
}

var fonts = module("fonts")

fonts.font_map = {
    'TinyUnicode': { 'font' : TinyUnicode, 'width' : 5 },
    'MatrixDisplay3x5': { 'font' : MatrixDisplay3x5, 'width' : 3 },
}

fonts.palette = {
    'black': 0x000000,
    'white': 0xFFFFFF,
    'red': 0xFF0000,
    'orange': 0xFFA500,
    'yellow': 0xFFFF00,
    'green': 0x008800,
    'blue': 0x0000FF,
    'indigo': 0x4B0082,
    'violet': 0xEE82EE,
}

return fonts