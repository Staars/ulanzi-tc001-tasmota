import BaseClockFace

class BasicClockFace: BaseClockFace
    var showSecondsDots

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.clockfaceManager.change_font('Mono65');
        self.showSecondsDots = false
    end

    def handleActionButton()
        self.showSecondsDots = !self.showSecondsDots
        tasmota.cmd("buzzer")
    end

    def render(segue)
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        var rtc = tasmota.rtc()

        var time_str = tasmota.strftime('%H:%M', rtc['local'])
        var x_offset = 1
        var y_offset = 0
        screen.print_string(time_str, x_offset, y_offset, false, self.clockfaceManager.color, self.clockfaceManager.brightness)



        var current_seconds = tasmota.time_dump(rtc['local'])['sec']
        var seconds_brightness = self.clockfaceManager.brightness >> 1

        if current_seconds >= 12 && self.showSecondsDots
            screen.set_matrix_pixel_color(0, 0, self.clockfaceManager.color, seconds_brightness)
        end
        if current_seconds >= 24 && self.showSecondsDots
            screen.set_matrix_pixel_color(31, 0, self.clockfaceManager.color, seconds_brightness)
        end
        if current_seconds >= 36 && self.showSecondsDots
            screen.set_matrix_pixel_color(31, 7, self.clockfaceManager.color, seconds_brightness)
        end
        if current_seconds >= 48 && self.showSecondsDots
            screen.set_matrix_pixel_color(0, 7, self.clockfaceManager.color, seconds_brightness)
        end

    end

end

return BasicClockFace
