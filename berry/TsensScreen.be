import BaseScreen

class TsensScreen: BaseScreen

    def init(screenManager)
        super(self).init(screenManager);

        self.screenManager.change_font('MatrixDisplay3x5');
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController

        screen.clear()
        import ULP
        var tsens = (ULP.get_mem(35) - 32.0) * 5 / 9

        var sensor_str = format("%.2f C", tsens)

        screen.print_string(sensor_str, 2, 2, true, self.screenManager.color, self.screenManager.brightness)
    end
end

return TsensScreen
