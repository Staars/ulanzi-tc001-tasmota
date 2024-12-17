import mqtt
import fonts
import string

import BaseClockFace

class BEDClockFace: BaseClockFace
    var clockfaceManager
    var matrixController

    var hasValue
    var value

    def init(clockfaceManager)
        super(self).init(clockfaceManager);

        self.matrixController.change_font('Mono65');

        self.hasValue = false
        self.value = 0

        mqtt.subscribe("esp8266-geigercounter/GEIGERCTR-920FC2_usv/state", /topic, idx, payload, bindata -> self.handleMqttUpdate(payload))
    end

    def deinit()
        super(self).deinit();

        mqtt.unsubscribe("esp8266-geigercounter/GEIGERCTR-920FC2_usv/state")
    end

    def handleMqttUpdate(payload)
        self.hasValue = true
        self.value = number(payload) / 0.1
    end

    def render()
        var screen = segue ? self.offscreenController : self.matrixController
        screen.clear()
        var bed_str = ""
        if self.hasValue
            bed_str = string.format("%3.1f", self.value)
        else
            bed_str = "???"
        end

        var x_offset = 2
        var y_offset = 1

        screen.print_char("\xa5", x_offset, 0, false, fonts.palette['yellow'], self.clockfaceManager.brightness)
        screen.print_string(bed_str, x_offset + 12, y_offset, false, fonts.palette['yellow'], self.clockfaceManager.brightness)
    end

    def handleActionButton()
        print("Banana")
    end
end

return BEDClockFace
