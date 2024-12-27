import BaseScreen

class ImgScreen: BaseScreen

    var img, img_idx

    def init(screenManager)
        super(self).init(screenManager);

        self.screenManager.change_font('MatrixDisplay3x5');
        var f = open("red_eye.bin","r")
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
        self.matrixController.draw()
    end

    def showImg(screen)
        var img_start = self.img_idx * 64 * 3
        var color = img_start
        for y:0..7
            for x:0..7
                var pixel = self.img[color]<<16 | self.img[color+1]<<8 | self.img[color+2]
                screen.set_matrix_pixel_color(x,y, pixel ,self.screenManager.brightness)
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
        var x_offset = 12
        var y_offset = 0

        screen.print_string(time_str, x_offset, y_offset, true, self.screenManager.color, self.screenManager.brightness)
    end
end

return ImgScreen
