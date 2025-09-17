import BaseScreen
import util

class CalendarScreen: BaseScreen
    var img, img_matrix, img_idx

    def init(screenManager)
        super(self).init(screenManager)
        self.screenManager.change_font('MatrixDisplay3x5')

        self.img = bytes(192)
        self.img_matrix = util.imgFromFile(self.img, "cal.bin", 8, 8, 3)
    end

    def showImg(screen)
        screen.matrix.blit(self.img_matrix, 0, 0)
        var y = 0
        while y < 8
            var pixel = screen.matrix.get(7, y)
            screen.matrix.set(8, y, pixel, self.screenManager.brightness)
            y += 1
        end
    end

    def drawBars(screen)
        var wd = tasmota.time_dump(tasmota.rtc()["local"])["weekday"]
        var i = 10
        var day = 1
        while i < 30
            var color = day == wd ? self.screenManager.color : 0x606060
            screen.matrix.set(i, 7, color, self.screenManager.brightness)
            screen.matrix.set(i+1, 7, color, self.screenManager.brightness)
            i += 3
            day += 1
        end
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        self.showImg(screen)
        self.drawBars(screen)
        var rtc = tasmota.rtc()
        var day_str = tasmota.strftime('%d', rtc['local'])
        screen.print_string(day_str, 1, 1, true, 0x101010, self.screenManager.brightness)
        var time_str = tasmota.strftime('%H:%M', rtc['local'])
        screen.print_string(time_str, 12, -1, true, self.screenManager.color, self.screenManager.brightness)
    end
end

return CalendarScreen
