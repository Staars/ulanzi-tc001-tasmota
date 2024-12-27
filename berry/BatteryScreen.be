import BaseScreen

class BatteryScreen: BaseScreen
    var showVoltage

    def init(screenManager)
        super(self).init(screenManager);

        self.screenManager.change_font('MatrixDisplay3x5');

        self.showVoltage = false
    end

    def handleActionButton()
        self.showVoltage = !self.showVoltage
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        import ULP
        var value = ULP.get_mem(33)
       
        var x_offset = 2
        var y_offset = 0
        var bat_str = "???"

        if self.showVoltage
            bat_str = str(value) + "mV"
            x_offset += 3
        else
            var min = 2000
            var max = 2700

            if value < min
                value = min
            end
            if value > max
                value = max
            end

            value = int(((value - min) * 100) / (max - min))
            bat_str = 'BAT' + format("%3i", value) + "%"
        end

        screen.print_string(bat_str, x_offset, y_offset, true, self.screenManager.color, self.screenManager.brightness)
    end
end

return BatteryScreen
