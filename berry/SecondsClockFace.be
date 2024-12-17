import BaseClockFace

class SecondsClockFace: BaseClockFace

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('MatrixDisplay3x5');
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        var rtc = tasmota.rtc()

        var time_str = tasmota.strftime('%H:%M:%S', rtc['local'])
        var x_offset = 2
        var y_offset = 1

        screen.print_string(time_str, x_offset, y_offset, true, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return SecondsClockFace
