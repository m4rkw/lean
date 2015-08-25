
class Lean::Session < Lean::Model
  @table = :session

  attr_reader :session_id
  attr_accessor :user_id
  attr_accessor :ip_address
  attr_accessor :user_agent

  def beforeSave
    @expiry = Time.at(Time.now.to_i + Lean::Config.get(:session_expiry))

    if !@id
      @session_id = (0...128).map { (65 + rand(26)).chr }.join
    end
  end
end
