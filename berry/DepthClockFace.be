import fonts

import BaseClockFace

class DepthClockFace: BaseClockFace

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('MatrixDisplay3x5');
        self.matrixController.clear();
        self.hasValue = true
        self.value = 150
    end

    def deinit()
        super(self).deinit();
    end

    def render()
        self.matrixController.clear()
        var solar_str = "Depth?"
        if self.hasValue
            solar_str = format("%3icm", self.value)
        end

        var x_offset = 10
        var y_offset = 0

        self.matrixController.print_string(solar_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end

end

return DepthClockFace
