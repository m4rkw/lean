
class Controller
    include Renderer

    def initialize
        @layout = "main"
    end

    def notfound
        render "_404"
    end
end
