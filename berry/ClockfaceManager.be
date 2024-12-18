import MatrixController

import BasicClockFace
import DateClockFace
import LongTextClockFace
import SecondsClockFace
import DepthClockFace
import GPSClockFace
import BatteryClockFace
import SensorClockFace
import NetClockFace

var clockFaces = [
    LongTextClockFace,
    DateClockFace,
    BatteryClockFace,
    BasicClockFace,
    SecondsClockFace,
    # DepthClockFace,
    # GPSClockFace,
    SensorClockFace,
    NetClockFace
];

class ClockfaceManager
    var matrixController, offscreenController
    var brightness
    var color
    var currentClockFace
    var currentClockFaceIdx
    var nextClockFace, segueCtr, loop_50ms, outShiftBuffer, trashBuffer
    var changeCounter


    def init()
        import fonts
        print("ClockfaceManager Init")
        self.matrixController = MatrixController(32,8,32)
        self.offscreenController = MatrixController(32,8,1)

        self.brightness = 40;
        self.color = fonts.palette[self.getColor()]

        self.matrixController.print_string("Hello :)", 3, 2, true, self.color, self.brightness)
        self.matrixController.draw()

        self.currentClockFaceIdx = 0
        self.currentClockFace = clockFaces[self.currentClockFaceIdx](self)
        self.loop_50ms = /->self.currentClockFace.loop()
        self.outShiftBuffer = bytes(-96) # 32 * 3
        self.trashBuffer = bytes(-96)
        self.changeCounter = 0
        self.segueCtr = 0

        tasmota.add_rule("Button1#State", / value, trigger, msg -> self.on_button_prev(value, trigger, msg))
        tasmota.add_rule("Button2#State", / value, trigger, msg -> self.on_button_action(value, trigger, msg))
        tasmota.add_rule("Button3#State", / value, trigger, msg -> self.on_button_next(value, trigger, msg))
    end

    def getColor()
        if tasmota.wifi()["up"] == true
            return 'white'
        elif tasmota.cmd('so115')['SetOption115'] == 'ON'
            return 'blue'
        else
            return 'green'
        end
    end

    def initULP()
        import ULP
        if int(tasmota.cmd("status 2")["StatusFWR"]["Core"]) == 2
          ULP.adc_config(6,3,3) # battery
          ULP.adc_config(7,3,3) # light
        else
          ULP.adc_config(6,3,12) # battery
          ULP.adc_config(7,3,12) # light
        end
        ULP.wake_period(0,1000 * 1000) # timer register 0 - every 1000 millisecs - max possible value !!
        var c = bytes().fromb64("dWxwAAwAXAAAAAwAcwGAcg4AANAaAAByDgAAaAAAgHIAAEB0HQAAUBAAAHAQAAB0EAAGhUAAwHKDAYByDAAAaAAAgHIAAEB0IQAAUBAAAHAQAAB0EAAGhUAAwHKTAYByDAAAaAAAALA=") 
        ULP.load(c) 
        ULP.run() 
    end

    def change_font(font)
        self.matrixController.change_font(font);
        self.offscreenController.change_font(font);
    end

    def on_button_prev(value, trigger, msg)
        self.initSegue(-1)
    end

    def on_button_action(value, trigger, msg)
        import introspect
        var handleActionMethod = introspect.get(self.currentClockFace, "handleActionButton");

        if handleActionMethod != nil
            self.currentClockFace.handleActionButton()
        end
    end

    def on_button_next(value, trigger, msg)
        self.initSegue(1)
    end

    def initSegue(steps)
        self.currentClockFaceIdx = (self.currentClockFaceIdx + steps) % size(clockFaces)
        self.nextClockFace = clockFaces[self.currentClockFaceIdx](self)
        self.nextClockFace.render(true)
        self.segueCtr = 8
        var direction = steps > 0 ? 0 : 2
        self.loop_50ms = /->self.doSegue(direction)
    end

    def doSegue(direction)
        self.offscreenController.matrix.scroll(direction, self.outShiftBuffer)
        self.matrixController.matrix.scroll(direction, self.trashBuffer, self.outShiftBuffer)
        self.matrixController.draw()

        self.segueCtr -= 1
        if self.segueCtr == 0
            self.currentClockFace = self.nextClockFace
            self.nextClockFace = nil
            self.loop_50ms = /->self.currentClockFace.loop()
            self.redraw()
        end
    end

    def autoChangeFace()
        if self.changeCounter == 10
            self.on_button_next()
            self.changeCounter = 0
        end
        self.changeCounter += 1
    end

    # This will be called automatically every 1s by the tasmota framework
    def every_second()
        if self.segueCtr != 0 return end
        self.update_brightness_from_sensor();
        self.redraw()
        self.autoChangeFace()
    end

    def every_50ms()
        self.loop_50ms()
    end

    def redraw()
        #var start = tasmota.millis()

        self.currentClockFace.render()
        self.matrixController.draw()

        #print("Redraw took", tasmota.millis() - start, "ms")
    end

    def update_brightness_from_sensor()
        import ULP
        import math
        var illuminance = ULP.get_mem(25)/50
        # var illuminance = 100
        var brightness = int(10 * math.log(illuminance))
        if brightness < 10
            brightness = 10;
        end
        if brightness > 128
            brightness = 128
        end
        # print("Brightness: ", self.brightness, ", Illuminance: ", illuminance);

        self.brightness = brightness;
    end

    def save_before_restart()
        # This function may be called on other occasions than just before a restart
        # => We need to make sure that it is in fact a restart
        if tasmota.global.restart_flag == 1 || tasmota.global.restart_flag == 2
            self.currentClockFace = nil;
            self.matrixController.change_font('MatrixDisplay3x5');
            self.matrixController.clear();

            self.matrixController.print_string("Reboot...", 0, 2, true, self.color, self.brightness)
            self.matrixController.draw();
            print("This is just to add some delay");
            print("   ")
            print("According to all known laws of aviation, there is no way a bee should be able to fly.")
            print("Its wings are too small to get its fat little body off the ground.")
            print("The bee, of course, flies anyway, because bees don't care what humans think is impossible")
        end
    end
end

return ClockfaceManager
