import BaseScreen
import util

class ImgScreen: BaseScreen

    var frames, img_idx, img
    static isAuto


    def init(screenManager)
        super(self).init(screenManager)
        self.screenManager.change_font('MatrixDisplay3x5')
        self.img = bytes()
        self.frames = util.animFromFile(self.img, "red_eye.bin", 8, 8, 3)
        self.img_idx = 0
    end

    def loop()
        self.img_idx += 1
        if self.img_idx >= size(self.frames)
            self.img_idx = 0
        end
        self.showImg(self.matrixController)
        self.matrixController.draw()
    end

    def showImg(screen)
        screen.matrix.blit(self.frames[self.img_idx], 0, 0, self.screenManager.brightness)
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        self.showImg(screen)
        var rtc = tasmota.rtc()
        var time_str = tasmota.strftime('%H:%M', rtc['local'])
        screen.print_string(time_str, 12, 2, true,
                            self.screenManager.color, self.screenManager.brightness)
    end
end

return ImgScreen
