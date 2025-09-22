def splitStringToChunks(value, chunkSize)
    var output = []
    var tmp = ""
    for i: 0..(size(value) - 1)
        tmp += value[i]
        if size(tmp) == chunkSize
            output.push(tmp)
            tmp = ""
        end
    end
    if size(tmp) > 0
        output.push(tmp)
    end
    return output
end

class pixmat end

def imgFromFile(buf, filename, width, height, bpp)
    var f = open(filename, "r")
    buf .. f.readbytes()
    f.close()
    return pixmat(buf, width, height, bpp, false)
end

def animFromFile(buf, filename, width, height, bpp)
    var f = open(filename, "r")
    buf .. f.readbytes()
    f.close()

    var frames = []
    var frame_len = width * height * bpp
    var frame_count = int(size(buf) / frame_len)

    var i = 0
    var pos = 0
    while i < frame_count
        frames.push(pixmat(buf[pos .. pos + frame_len - 1], width, height, bpp, false))
        pos += frame_len
        i += 1
    end
    return frames
end

#@ solidify:util
var util = module("util")
util.splitStringToChunks = splitStringToChunks
util.imgFromFile = imgFromFile
util.animFromFile = animFromFile

return util
