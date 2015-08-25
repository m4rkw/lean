
class Lean::Controller
  include Lean::Renderer
  include Lean::URITool

  attr_reader :flash

  def initialize(method, args)
    @db = Lean::DB.con
    @layout = "main"
    @flash = []
  end

  def beforeAction(method, args)
  end

  def notfound
    render "_404"
  end

  def redirect uri
    response 302, {"Location" => uri}
  end
end
