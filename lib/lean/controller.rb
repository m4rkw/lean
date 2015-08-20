
class Lean::Controller
  include Lean::Renderer

  def initialize
    @layout = "main"
  end

  def notfound
    render "_404"
  end
end
