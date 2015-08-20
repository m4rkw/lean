
class Lean::Controller
  include Lean::Renderer

  def initialize
    @db = Lean::DB.con
    @layout = "main"
  end

  def notfound
    render "_404"
  end
end
