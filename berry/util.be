def min(x, y)
    if x < y
        return x
    end 
    return y
end

def max(x, y)
    if x > y
        return x
    end 
    return y
end

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

var util = module("util")
util.min = min
util.max = max
util.splitStringToChunks = splitStringToChunks

return util