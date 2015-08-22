
class Lean::Controller
  include Lean::Renderer
  include Lean::URITool

  attr_reader :flash
  attr_reader :js_passthru

  def initialize
    @db = Lean::DB.con
    @layout = "main"
    @flash = []
  end

  def notfound
    render "_404"
  end
end
