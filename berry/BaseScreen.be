import introspect

class BaseScreen
    var screenManager
    var matrixController, offscreenController
    var can_render
    var duration

    var hasValue
    var value

    def init(screenManager)
        print(classname(self), "Init")

        self.screenManager = screenManager
        self.matrixController = screenManager.matrixController
        self.offscreenController = screenManager.offscreenController
        self.duration = 10 # default value for auto change
    end

    def deinit()
        print(classname(self), "DeInit")
    end

    def loop()
    end

    def render(segue)
    end

end

return BaseScreen
