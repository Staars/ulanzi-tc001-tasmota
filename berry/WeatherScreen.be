import BaseScreen
import util

class WeatherScreen: BaseScreen
    var img, frames, img_idx

    def init(screenManager)
        super(self).init(screenManager)
        import json
        self.screenManager.change_font('MatrixDisplay3x5')

        self.img = bytes()
        self.frames = util.animFromFile(self.img, "weather.bin", 8, 8, 3)
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
        screen.matrix.blit(self.frames[self.img_idx], 0, 0)
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        self.showImg(screen)
        import global
        var temperature = global.weather_data['current']['temperature_2m']
        var time_str = format("%.1f `C", temperature)
        var x_offset = 10
        if temperature < 10 x_offset += 4 end
        screen.print_string(time_str, x_offset, 0, true, self.screenManager.color, self.screenManager.brightness)
    end
end

return WeatherScreen
