
class Lean::Controller
  include Lean::Renderer
  include Lean::URITool

  attr_reader :flash
  attr_accessor :request
  attr_accessor :db

  def initialize(method, args)
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

  def cleanup
    @db.disconnect
  end
end
