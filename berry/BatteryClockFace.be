import BaseClockFace

class BatteryClockFace: BaseClockFace
    var clockfaceManager
    var matrixController
    var showVoltage

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('MatrixDisplay3x5');
        self.matrixController.clear();

        self.showVoltage = false
    end

    def handleActionButton()
        self.showVoltage = !self.showVoltage
    end

    def render()
        self.matrixController.clear()
        import ULP
        var value = ULP.get_mem(24)
       
        var x_offset = 2
        var y_offset = 1
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

        self.matrixController.print_string(bat_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return BatteryClockFace
