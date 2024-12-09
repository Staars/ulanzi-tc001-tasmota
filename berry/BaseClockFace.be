import introspect

class BaseClockFace
    var clockfaceManager
    var matrixController
    var needs_render

    var hasValue
    var value

    def init(clockfaceManager)
        print(classname(self), "Init");

        self.clockfaceManager = clockfaceManager;
        self.matrixController = clockfaceManager.matrixController;
    end

    def deinit()
        print(classname(self), "DeInit");
    end

    def loop()
    end

    def render()
        self.matrixController.clear()
    end

end

return BaseClockFace
