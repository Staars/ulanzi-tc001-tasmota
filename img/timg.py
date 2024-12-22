from PIL import Image, ImageSequence
import requests


fname = 'img'
ftype = '.gif'
id =  64761

page_start = int(id/10000)
url = 'https://developer.lametric.com/api/v2/icons?page='+ str(page_start) + "&page_size=10000"

r = requests.get(url)
j = r.json()
for icon in j['data']:
    if icon['id'] == id:
        print("Found image id",icon['id'],"with title:",icon['title'])
        fname = icon['title'].replace(' ','_')
url = 'https://developer.lametric.com/content/apps/icon_thumbs/'+str(id)+'_icon_thumb'+ftype
r = requests.get(url)
if r.text.startswith('<!DOCTYPE html>'):
    print("This is probably no GIF, let's try PNG ...")
    ftype = '.png'
    url = 'https://developer.lametric.com/content/apps/icon_thumbs/'+str(id)+'_icon_thumb'+ftype
    r = requests.get(url)
    if r.text.startswith('<!DOCTYPE html>'):
        print('Nope, PNG failed too .. giving up!')
        exit()
open(fname + ftype , 'wb').write(r.content)

# Opening the input image:
im = Image.open(fname + ftype)

# iterate over the frames of the GIF or use the one from PNG as save
f = open(fname + '.bin',"wb")
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

f.write(buf)
f.close()
print("Raw data size:",len(buf),"bytes, image number:",image_counter)