import introspect

class BaseClockFace
    var clockfaceManager
    var matrixController, offscreenController
    var needs_render

    var hasValue
    var value

    def init(clockfaceManager)
        print(classname(self), "Init")

        self.clockfaceManager = clockfaceManager
        self.matrixController = clockfaceManager.matrixController
        self.offscreenController = clockfaceManager.offscreenController
    end

    def deinit()
        print(classname(self), "DeInit")
    end

    def loop()
    end

    def render(segue)
        self.matrixController.clear()
    end

end

return BaseClockFace
