import BaseClockFace

class TsensClockFace: BaseClockFace

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.clockfaceManager.change_font('MatrixDisplay3x5');
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController

        screen.clear()

        var x_offset = 2
        var y_offset = 0

        import ULP
        var tsens = (ULP.get_mem(29) - 32.0) * 5 / 9

        var sensor_str = format("%.2f C", tsens)

        screen.print_string(sensor_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return TsensClockFace
