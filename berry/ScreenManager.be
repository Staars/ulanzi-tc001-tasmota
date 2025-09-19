import MatrixController

import BasicScreen
import NetScreen
import ImgScreen
import StartScreen
import CalendarScreen
import WeatherScreen
import AlertScreen
import BatteryScreen

var Screens = [
    StartScreen, # only shown once
    CalendarScreen,
    BatteryScreen,
    BasicScreen,
    WeatherScreen,
    NetScreen,
    ImgScreen,
    AlertScreen, # only shown on event
];

class ScreenManager
    var matrixController, offscreenController
    var brightness
    var color
    var currentScreen
    var currentScreenIdx
    var nextScreen, segueCtr, loop_50ms
    var changeCounter


    def init()
        import fonts
        import gpio
        import mqtt
        print("ScreenManager Init")

        var matrix_width = 32
        var matrix_height = 8

        self.matrixController = MatrixController(matrix_width, matrix_height, gpio.pin(gpio.WS2812, 2))
        self.offscreenController = MatrixController(matrix_width, matrix_height, -1) # -1 is a dummy pin, that MUST not be configured for WS2812

        self.brightness = 40;
        self.color = self.getColor()

        self.initULP()

        self.matrixController.print_string("booting", 0, 0, true, self.color, self.brightness)
        self.matrixController.draw()

        self.currentScreenIdx = 0
        self.currentScreen = Screens[self.currentScreenIdx](self)
        self.loop_50ms = /->self.currentScreen.loop()
        self.changeCounter = 0
        self.segueCtr = 0
        mqtt.subscribe("ulanzi_alert")
        tasmota.add_driver(self)
    end

    def deinit()
        import mqtt
        tasmota.remove_driver(self)
        mqtt.unsubscribe("ulanzi_alert")
        for i:global.Screens
            i = nil
        end
        global.Screens = nil
    end

    def initULP()
        import ULP
        var c = bytes().fromb64("dWxwAAwAgAAAABgAAwKAcg4AANAaAAByDgAAaAAAgHIAAEB0HQAAUBAAAHAQAAB0EAAGhUAAwHITAoByDAAAaAAAgHIAAEB0IQAAUBAAAHAQAAB0EAAGhUAAwHIjAoByDAAAaBEC2C4zAoByDAAAaAkBuC5DAoByDAAAaAkB+C9TAoByDAAAaAAAALA=") 
        ULP.load(c)         
        if int(tasmota.cmd("status 2")["StatusFWR"]["Core"]) == 2
          ULP.adc_config(6,3,3) # battery
          ULP.adc_config(7,3,3) # light
        else
          ULP.adc_config(6,3,12) # battery
          ULP.adc_config(7,3,12) # light
        end

        # gpio.pin_mode(14,gpio.INPUT_PULLUP) # 3
        # gpio.pin_mode(26,gpio.INPUT_PULLUP) # 1
        # gpio.pin_mode(27,gpio.INPUT_PULLUP) # 2

        ULP.gpio_init(14, 0) # RTC_GPIO16, RTC_GPIO_MODE_INPUT_ONLY
        ULP.gpio_init(26, 0) # RTC_GPIO7,  RTC_GPIO_MODE_INPUT_ONLY
        ULP.gpio_init(27, 0) # RTC_GPIO17, RTC_GPIO_MODE_INPUT_ONLY

        ULP.wake_period(0,50000) # timer register 0 - every 50 millisecs 
        ULP.run() 
    end

    def getColor()
        if tasmota.wifi()["up"] == true
            return 0xaaaaaa
        else
            return 0xaaaaaa # for demo use white anyway
        end
    end

    def change_font(font)
        self.matrixController.change_font(font);
        self.offscreenController.change_font(font);
    end

    def on_button_prev()
        self.initSegue(-1)
    end

    def on_button_action()
        import introspect
        var handleActionMethod = introspect.get(self.currentScreen, "handleActionButton");

        if handleActionMethod != nil
            self.currentScreen.handleActionButton()
        end
    end

    def on_button_next()
        self.initSegue(1)
    end

    def initSegue(steps, screenIdx)
        if screenIdx
            self.currentScreenIdx = screenIdx # info/alert message or other override
            print("override screen with alert")
        else
            self.currentScreenIdx = (self.currentScreenIdx + steps) % (size(Screens) - 1)
        end
        if self.currentScreenIdx == 0 self.currentScreenIdx = 1 end # optional: show screen 0 only after reboot
        self.nextScreen = Screens[self.currentScreenIdx](self)
        self.nextScreen.render(true)
        self.segueCtr = self.matrixController.row_size
        var direction = steps > 0 ? 0 : 2
        self.loop_50ms = /->self.doSegue(direction)
    end

    def doSegue(direction)
        self.offscreenController.matrix.scroll(direction)
        self.matrixController.matrix.scroll(direction, self.offscreenController.matrix)
        self.matrixController.draw()

        self.segueCtr -= 1
        if self.segueCtr == 0
            self.currentScreen = self.nextScreen
            self.nextScreen = nil
            self.loop_50ms = /->self.currentScreen.loop()
            self.redraw()
        end
    end

    def autoChangeScreen()
        if self.changeCounter == self.currentScreen.duration
            self.on_button_next()
            self.changeCounter = 0
        end
        self.changeCounter += 1
    end

    def alert(message)
        self.changeCounter = 0 # prevent overlapping auto change
        self.initSegue(1,size(Screens) - 1) # last element of screens array
        self.nextScreen.text += message
        print(self.nextScreen.text)
    end

    # This will be called automatically every 1s by the tasmota framework
    def every_second()
        if self.segueCtr != 0 return end
        self.update_brightness_from_sensor();
        self.redraw()
        self.autoChangeScreen()
    end

    def every_50ms()
        self.loop_50ms()
    end

    def every_100ms()
        if self.segueCtr != 0 return end

        import ULP
        var gpio = ULP.get_mem(36) # low
        if gpio & (1<<7) == 0
            self.on_button_prev()
            return
        end
        gpio = ULP.get_mem(37) # high
        if gpio & (1<<0) == 0
            self.on_button_next()
        elif gpio & (1<<1) == 0
            self.on_button_action()
        end
    end

    def redraw()
        self.currentScreen.render()
        self.matrixController.draw()
    end

    def update_brightness_from_sensor()
        import ULP
        import math
        var illuminance = ULP.get_mem(34)/100
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

    def mqtt_data(topic, idx, payload, bindata)
        self.alert(payload)
    end

    def save_before_restart()
        # This function may be called on other occasions than just before a restart
        # => We need to make sure that it is in fact a restart
        if tasmota.global.restart_flag == 1 || tasmota.global.restart_flag == 2
            self.currentScreen = nil
            self.matrixController.change_font('MatrixDisplay3x5')
            self.matrixController.clear()

            self.matrixController.print_string("Reboot...", 0, 1, true, self.color, self.brightness)
            self.matrixController.draw()
            print("This is just to add some delay")
            print("   ")
            print("According to all known laws of aviation, there is no way a bee should be able to fly.")
            print("Its wings are too small to get its fat little body off the ground.")
            print("The bee, of course, flies anyway, because bees don't care what humans think is impossible")
        end
    end
end

return ScreenManager
