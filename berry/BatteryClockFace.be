import BaseClockFace

class BatteryClockFace: BaseClockFace
    var clockfaceManager
    var matrixController, OutBuf, scrollDelay
    var showVoltage

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('MatrixDisplay3x5');
        self.matrixController.clear();
        self.needs_render = true

        self.showVoltage = false
        self.OutBuf = bytes(-(3 * 32)) # width * RGB
        self.scrollDelay = 3
    end

    def handleActionButton()
        self.showVoltage = !self.showVoltage
    end

    def loop()
        if self.needs_render == true return end
        if self.scrollDelay > 0
            self.scrollDelay -= 1
            return
        end
        self.scrollDelay = 3
        # var start = tasmota.millis()
        self.matrixController.scroll_matrix(0, self.OutBuf)
        self.matrixController.leds.show();
        # print("Redraw took", tasmota.millis() - start, "ms")
    end

    def render()
        if self.needs_render == false return end
        self.matrixController.clear()
        # import ULP
        # var value = ULP.get_mem(24)
        var value = 2700 # emulator
       
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
        self.needs_render = false
    end
end

return BatteryClockFace
