import BaseScreen

class WeatherScreen: BaseScreen

    var img, img_idx, weather_data

    def init(screenManager)
        super(self).init(screenManager);

        import json
        self.screenManager.change_font('MatrixDisplay3x5');
        var f = open("weather.bin","r")
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

        import global
        var temperature = global.weather_data['current']['temperature_2m']
        var time_str = format("%.1f `C", temperature)
        var x_offset = 10
        if temperature < 10 x_offset += 4 end
        var y_offset = 0

        screen.print_string(time_str, x_offset, y_offset, true, self.screenManager.color, self.screenManager.brightness)
    end
end

return WeatherScreen
