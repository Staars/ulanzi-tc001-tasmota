import ScreenManager

_screenManager = ScreenManager()

# tasmota.set_timer(20000,def() import fonts _screenManager.color = fonts.palette[_screenManager.getColor()] end)

tasmota.add_driver(_screenManager)

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

tasmota.add_cron("* */15 * * * *",/->get_w())
