import BaseScreen

class BasicScreen: BaseScreen
    var showSecondsDots

    def init(screenManager)
        super(self).init(screenManager);

        self.screenManager.change_font('TinyUnicode');
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
        screen.print_string(time_str, x_offset, y_offset, false, self.screenManager.color, self.screenManager.brightness)



        var current_seconds = tasmota.time_dump(rtc['local'])['sec']
        var seconds_brightness = self.screenManager.brightness >> 1

        if current_seconds >= 12 && self.showSecondsDots
            screen.set_matrix_pixel_color(0, 0, self.screenManager.color, seconds_brightness)
        end
        if current_seconds >= 24 && self.showSecondsDots
            screen.set_matrix_pixel_color(31, 0, self.screenManager.color, seconds_brightness)
        end
        if current_seconds >= 36 && self.showSecondsDots
            screen.set_matrix_pixel_color(31, 7, self.screenManager.color, seconds_brightness)
        end
        if current_seconds >= 48 && self.showSecondsDots
            screen.set_matrix_pixel_color(0, 7, self.screenManager.color, seconds_brightness)
        end

    end

end

return BasicScreen
