import BaseClockFace

class BasicClockFace: BaseClockFace
    var showSecondsDots, OutBuf

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('Glance');
        self.matrixController.clear();

        self.showSecondsDots = false
        self.OutBuf = bytes(-(3 * 32)) # width * RGB
    end

    def handleActionButton()
        self.showSecondsDots = !self.showSecondsDots
        tasmota.cmd("buzzer")
    end

    def loop()
        if self.needs_render == true return end
        # var start = tasmota.millis()
        self.matrixController.scroll_matrix(2,self.OutBuf)
        self.matrixController.leds.show();
        # print("Redraw took", tasmota.millis() - start, "ms")
    end

    def render()
        self.matrixController.clear()
        var rtc = tasmota.rtc()

        var time_str = tasmota.strftime('%H:%M', rtc['local'])
        var x_offset = 4
        var y_offset = 0
        self.matrixController.print_string(time_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)



        var current_seconds = tasmota.time_dump(rtc['local'])['sec']
        var seconds_brightness = self.clockfaceManager.brightness >> 1

        if current_seconds >= 12 && self.showSecondsDots
            self.matrixController.set_matrix_pixel_color(0, 0, self.clockfaceManager.color, seconds_brightness)
        end
        if current_seconds >= 24 && self.showSecondsDots
            self.matrixController.set_matrix_pixel_color(31, 0, self.clockfaceManager.color, seconds_brightness)
        end
        if current_seconds >= 36 && self.showSecondsDots
            self.matrixController.set_matrix_pixel_color(31, 7, self.clockfaceManager.color, seconds_brightness)
        end
        if current_seconds >= 48 && self.showSecondsDots
            self.matrixController.set_matrix_pixel_color(0, 7, self.clockfaceManager.color, seconds_brightness)
        end
    end

end

return BasicClockFace
