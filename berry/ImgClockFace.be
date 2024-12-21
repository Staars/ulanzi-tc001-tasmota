import BaseClockFace

class SecondsClockFace: BaseClockFace

    var img, img_idx

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.clockfaceManager.change_font('MatrixDisplay3x5');
        var f = open("img.bin","r")
        self.img = f.readbytes()
        f.close()
        self.img_idx = 0
    end

    def loop()
        self.img_idx += 1
        if self.img_idx > (size(self.img)/64/3) - 1
            self.img_idx = 0
        end
        self.showImg(self.matrixController)
    end

    # def showImg_(idx)
    #     if idx == nil
    #         idx = 0
    #     end
    #     var img_start = idx * 64 * 3
    #     var buf = self.matrixController.matrix.pix_buffer
    #     for line:0..7
    #         var line_offset = line * self.matrixController.matrix.w * 3
    #         var img_offset = img_start + (line*24)
    #         if line%2 == 0
    #             buf.setbytes(line_offset,self.img[img_offset..img_offset+21])
    #         else
    #             buf.setbytes(line_offset + ((self.matrixController.matrix.w - 8)*3),self.img[img_offset..img_offset+21])
    #         end
    #     end
    # end

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
        var rtc = tasmota.rtc()

        var time_str = tasmota.strftime('%H:%M', rtc['local'])
        var x_offset = 10
        var y_offset = 0

        screen.print_string(time_str, x_offset, y_offset, true, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return SecondsClockFace
