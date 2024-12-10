import BaseClockFace

class DateClockFace: BaseClockFace
    var clockfaceManager
    var matrixController, OutBuf
    var showYear
    var needs_render
    var offscreen, scrollDirection, scrollIdx

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('Glance');
        self.matrixController.clear();

        self.showYear = false
        self.needs_render = true
        self.OutBuf = bytes(-(3 * 32)) # width * RGB aka the greater of width and height
        self.scrollDirection = 0
        self.scrollIdx = 0
    end

    def handleActionButton()
        self.showYear = !self.showYear
    end

    def loop()
        if self.needs_render == true return end
        # var start = tasmota.millis()
        self.matrixController.scroll_matrix(self.scrollDirection,self.OutBuf)
        self.matrixController.leds.show();
        self.scrollIdx += 1
        if self.scrollIdx%32 == 0 self.scrollDirection += 1 end
        if self.scrollDirection > 3 self.scrollDirection = 0 end
        # print("Redraw took", tasmota.millis() - start, "ms")
    end


    def render()
        if self.needs_render == false return end
        self.matrixController.clear()
        var rtc = tasmota.rtc()

        var time_data = tasmota.time_dump(rtc['local'])
        var x_offset = 4
        var y_offset = 0

        var date_str = ""
        if self.showYear != true
            date_str = format("%02i.%02i", time_data['day'], time_data['month'])
        else
            date_str = str(time_data["year"])
            x_offset += 2
        end

        self.matrixController.print_string(date_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)

        self.needs_render = false
    end
end

return DateClockFace
