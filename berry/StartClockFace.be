import BaseClockFace

class SecondsClockFace: BaseClockFace

    var img, img_idx

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.clockfaceManager.change_font('MatrixDisplay3x5');
        var f = open("Tasmota.bin","r")
        self.img = f.readbytes()
        f.close()
        self.img_idx = 0
    end

    def showImg(screen)
        var img_start = self.img_idx * 64 * 3
        var color = img_start
        for y:0..7
            for x:0..7
                var pixel = self.img[color]<<16 | self.img[color+1]<<8 | self.img[color+2]
                screen.set_matrix_pixel_color(x,y, pixel ,self.clockfaceManager.brightness)
                color += 3
            end
        end
    end


    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()

        self.showImg(screen)

        var hello_str = '...GO!'
        var x_offset = 9
        var y_offset = 0

        screen.print_string(hello_str, x_offset, y_offset, true, 0x444444, self.clockfaceManager.brightness)
    end
end

return SecondsClockFace
