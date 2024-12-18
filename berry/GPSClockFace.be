import fonts

import BaseClockFace

class GPSClockFace: BaseClockFace
    var showSpeed
    var hasSpeed
    var speed
    var hasHeading
    var heading

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.clockfaceManager.change_font('MatrixDisplay3x5');

        self.hasSpeed = true
        self.speed = 8.2
        self.showSpeed = true
        self.hasHeading = true
        self.heading = "NO"
    end

    def handleActionButton()
        self.showSpeed = !self.showSpeed
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        var _str = "Speed?"
        var x_offset = 0
        var y_offset = 0
        if self.showSpeed
            if self.hasSpeed
                _str = format("%.2fkm/h", self.speed)
            end
        else
            x_offset = 12
            if self.hasSpeed
                _str = format("%s", self.heading)
            end
        end
            screen.print_string(_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)
    end

end

return GPSClockFace
