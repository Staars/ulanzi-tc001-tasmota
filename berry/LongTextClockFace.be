import fonts

import BaseClockFace
import MatrixController

class LongTextClockFace: BaseClockFace
    var  inOutBuf, trashOutBuf
    var textPosition, text
    var scrollsLeft

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('Arcade');
        self.matrixController.clear();
        # self.offscreenController = MatrixController(8,8,1) # dummy gpio

        self.offscreenController.change_font('Arcade');
        self.textPosition = 0
        self.text = "THIS IS A VERY LONG TEXT MESSAGE, THAT WOULD NEVER FIT ON THE SCREEN OF A ULANZI CLOCK !  "
        self.needs_render = true
        self.trashOutBuf = bytes(-(3 * 8)) # height * RGB
    end


    def deinit()
        super(self).deinit();
    end

    def loop()
        if self.needs_render == true return end
        # var start = tasmota.millis()
        self.offscreenController.matrix.scroll(1, self.clockfaceManager.outShiftBuffer) # 1 - to left, output - inOutBuf, no input buffer
        self.matrixController.matrix.scroll(1, self.trashOutBuf, self.clockfaceManager.outShiftBuffer) # 1 - to left, unused output, input inOutBuf
        self.matrixController.leds.show();
        self.scrollsLeft -= 1
        if self.scrollsLeft > 0 return end
        self.nextChar()
        # print("Redraw took", tasmota.millis() - start, "ms")
    end

    def nextChar()
        self.scrollsLeft = self.matrixController.font_width + 1

        self.offscreenController.clear()
        self.offscreenController.print_char(self.text[self.textPosition], 0, 0, false, self.clockfaceManager.color, self.clockfaceManager.brightness)
        self.textPosition += 1

        if self.textPosition == (size(self.text)-1) self.textPosition = 0 end
    end

    def render(segue)
        if self.needs_render == false return end
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        self.nextChar()
        self.needs_render = false
    end

end

return LongTextClockFace
