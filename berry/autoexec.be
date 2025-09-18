if tasmota.cmd("pixels")["Pixels"] != 256
    tasmota.cmd("pixels 256")
end
import ScreenManager

_s = ScreenManager()

# tasmota.set_timer(20000,def() import fonts _screenManager.color = fonts.palette[_screenManager.getColor()] end)

def get_w()
    import json
    import global
    var cl = webclient()
    var lat = tasmota.cmd("latitude")["Latitude"]
    var long = tasmota.cmd("longitude")["Longitude"]
    cl.begin(f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={long}&current=temperature_2m")
    cl.GET()
    global.weather_data = json.load(cl.get_string())
end

tasmota.set_timer(20000, get_w)

tasmota.add_cron("* */15 * * * *",/->get_w(),"get_weather")
