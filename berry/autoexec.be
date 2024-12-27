import ScreenManager

_screenManager = ScreenManager()

# tasmota.set_timer(20000,def() import fonts _screenManager.color = fonts.palette[_screenManager.getColor()] end)
tasmota.set_timer(18000, def() _screenManager.alert("Test alert - could be from MQTT ") end)

tasmota.add_driver(_screenManager)

# for this demo we just fetch data into a global, this works in the emulator too
# usually we use a driver or cron
import json
var cl = webclient()
var lat = 52.477940
var long = 13.399330
cl.begin(f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={long}&current=temperature_2m")
cl.GET()
var weather_data = json.load(cl.get_string())
