
class Lean::DB
  include Singleton

  attr_accessor :con

  def self.con=(con)
    Lean::DB.instance.con = con
  end

  def self.con
    Lean::DB.instance.con
  end
end
