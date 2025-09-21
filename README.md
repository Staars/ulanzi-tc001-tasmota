# Tasmota Berry Apps for the Ulanzi TC001

This repository contains a few berry script files that run on my Ulanzi TC001.
It is just a cloud backup/should serve for inspiration for others. Don't expect any support whatsoever.

Thanks a lot to [https://github.com/iliaan/ulanzi-lab](https://github.com/iliaan/ulanzi-lab) for laying the groundwork!

## Flash Tasmota firmware

### **Warning**: 
Flashing Tasmota firmware on your device may potentially brick or damage the device. It is important to proceed with caution and to understand the risks involved before attempting to flash the firmware. Please note that any modifications to the device's firmware may void the manufacturer's warranty and may result in permanent damage to the device. It is strongly recommended to thoroughly research the flashing process and to follow instructions carefully. The user assumes all responsibility and risk associated with flashing the firmware.

To install Tasmota firmware on the Ulanzi TC001, follow these steps:

1. Download the Tasmota firmware from the [official Tasmota website](http://ota.tasmota.com/tasmota32/release/).
2. Follow installation guide [here](https://templates.blakadder.com/ulanzi_TC001.html).
3. In the Tasmota web interface, go to "Consoles" and select "Console". Enter the command "Pixels 256" to enable the 256-pixel display mode.
4. Set the time zone via the console by entering the correct command according to [the tasmota docs](https://tasmota.github.io/docs/Timezone-Table/).


## Misc Notes

- To stop processing of button events by tasmota, use `SetOption73 1`

- To give exclusive matrix access to Berry:
  - Set the real GPIO 32 to WS2812 ID 2
  - Remember that the WS2812 ID starts at 0 in berry

```
[env:tasmota32-ulanzi]
extends                 = env:tasmota32_base
build_flags             = ${env:tasmota32_base.build_flags}
                          -DFIRMWARE_BLUETOOTH
                          -DUSE_MI_EXT_GUI
                          -DUSE_BERRY_ULP
                          -DUSE_RTC_CHIPS
                          -DUSE_DS3231
                          -DUSE_SHT3X
                          -DOTA_URL='"http://ota.tasmota.com/tasmota32/release/tasmota32-bluetooth.bin"'
lib_extra_dirs          = lib/libesp32, lib/libesp32_div, lib/lib_basic, lib/lib_i2c, lib/lib_ssl
lib_ignore              =   Micro-RTSP
custom_berry_solidify   = https://raw.githubusercontent.com/Staars/ulanzi-tc001-tasmota/refs/heads/master/berry/fonts.be
```


### Easy upload

- get IP of computer, like `ipconfig getifaddr en0`
- run `python3 -m http.server 8000` in berry folder
- start berry script on Ulanzi clock:

```
def l(name)
var cl = webclient()
cl.begin(f"http://<IP of computer>:8000/{name}")
var r = cl.GET()
print(r)
cl.write_file(f"/{name}")
cl.close()
end

# modify if needed
files = [
"AlertScreen.be",
"autoexec.be",
"BaseScreen.be",
"BasicScreen.be",
"BatteryScreen.be",
"cal.bin",
"CalendarScreen.be",
"caution.bin",
"fonts.be",
"ImgScreen.be",
"MatrixController.be",
"NetScreen.be",
"red_eye.bin",
"ScreenManager.be",
"StartScreen.be",
"Tasmota.bin",
"TsensScreen.be",
"util.be",
"weather.bin",
"WeatherScreen.be"
]
import path
for f:files
 path.remove(f"/{f}")
 l(f)
end
```