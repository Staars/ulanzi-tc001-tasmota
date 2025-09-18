import BaseScreen
import util

class StartScreen: BaseScreen

    var img_matrix
    var img

    def init(screenManager)
        super(self).init(screenManager)
        self.screenManager.change_font('MatrixDisplay3x5')

        self.img = bytes()
        self.img_matrix = util.imgFromFile(self.img, "Tasmota.bin", 8, 8, 3)
    end

    def showImg(screen)
        screen.matrix.blit(self.img_matrix, 0, 0, self.screenManager.brightness) # TODO: use self.screenManager.brightness later
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()

        self.showImg(screen)

        var hello_str = "...boot!"
        var x_offset = 9
        var y_offset = 0

        screen.print_string(hello_str, x_offset, y_offset, true,
                            0x444444, self.screenManager.brightness)
    end
end

return StartScreen
