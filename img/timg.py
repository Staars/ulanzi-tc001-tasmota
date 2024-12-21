from PIL import Image, ImageSequence
import io
import requests


fname = 'img.gif'
id ='23041'
url = 'https://developer.lametric.com/content/apps/icon_thumbs/'+id+'_icon_thumb.gif'
r = requests.get(url)
open(fname , 'wb').write(r.content)

# Opening the input gif:
im = Image.open("img.gif")

# create an empty list to store the frames
frames = []

# iterate over the frames of the gif as save
f = open("img.bin","wb")
buf = bytearray()
image_counter = 0
for frame in ImageSequence.Iterator(im):
    image_counter += 1
    frame = frame.convert("RGB")
    for y in range(5,45,5):
        for x in range(5,45,5):
            r, g, b = frame.getpixel((x, y))
            if r < 0x27:
                r = 0
            if g < 0x27:
                g = 0
            if b < 0x27:
                b = 0
            buf.append(r)
            buf.append(g)
            buf.append(b)
            # print(r,g,b)
    #frame.save(imgByteArr,frame=image.format)
    #imgByteArr = imgByteArr.getvalue()

f.write(buf)
f.close()
print(len(buf),image_counter)