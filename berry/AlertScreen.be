import fonts
import BaseScreen
import MatrixController
import util

class AlertScreen: BaseScreen
    var textPosition, text
    var scrollsLeft
    var img, img_matrix, img_idx
    var can_render

    def init(screenManager)
        super(self).init(screenManager)
        self.screenManager.change_font('TinyUnicode')

        self.textPosition = 0
        self.text = " >> Demo alert !! >>"
        self.duration = 20

        self.img = bytes(192)
        self.img_matrix = util.imgFromFile(self.img, "caution.bin", 8, 8, 3)
        self.can_render = true
    end

    def loop()
        if self.can_render == true return end
        self.offscreenController.matrix.scroll(1)
        self.matrixController.matrix.scroll(1, self.offscreenController.matrix)
        self.matrixController.leds.show()
        self.scrollsLeft -= 1
        if self.scrollsLeft > 0 return end
        self.nextChar()
    end

    def showImg(screen)
        screen.matrix.blit(self.img_matrix, 0, 0, self.screenManager.brightness)
        screen.matrix.blit(self.img_matrix, 12, 0, self.screenManager.brightness)
    end

    def nextChar()
        self.offscreenController.clear()
        self.scrollsLeft = self.offscreenController.print_char(
            self.text[self.textPosition], 0, 0, true,
            self.screenManager.color, self.screenManager.brightness
        ) + 1
        self.textPosition += 1
        if self.textPosition == (size(self.text) - 1) self.textPosition = 0 end
    end

    def render(segue)
        if self.can_render == false return end
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        self.showImg(screen)
        self.scrollsLeft = 8
        self.can_render = false
    end
end

return AlertScreen
