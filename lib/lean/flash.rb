
class Lean::Flash
  WARNING = "warning"
  INFO = "info"
  CRITICAL = "critical"
  ERROR = "error"

  attr_reader :type
  attr_reader :message

  def initialize(type, message)
    @type = type
    @message = message
  end
end
