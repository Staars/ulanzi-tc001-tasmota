import ClockfaceManager

_clockfaceManager = ClockfaceManager()

tasmota.set_timer(20000,def() import fonts _clockfaceManager.color = fonts.palette[_clockfaceManager.getColor()] end)

tasmota.add_driver(_clockfaceManager)
