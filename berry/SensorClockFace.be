import util

import BaseClockFace

var modes = ['illuminance']

class SensorClockFace: BaseClockFace
    var modeIdx

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.clockfaceManager.change_font('MatrixDisplay3x5');

        self.modeIdx = 0
    end

    def handleActionButton()
        self.modeIdx = (self.modeIdx + 1) % size(modes)
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController

        screen.clear()

        var x_offset = 2
        var y_offset = 1
        var sensor_str = "?????"

        var sensor_reading = ""
        var suffix = ""

        import ULP
        var illuminance = ULP.get_mem(25)/50
        # var illuminance = 50
        if modes[self.modeIdx] == "illuminance"
            sensor_reading = format("%5i", illuminance)
            suffix = "lx"
        end

        sensor_str = sensor_reading + suffix

        screen.print_string(sensor_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end
end

return SensorClockFace
