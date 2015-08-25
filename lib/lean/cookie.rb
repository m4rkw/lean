
class Lean::Cookie
  include Singleton

  attr_accessor :cookies

  def initialize
    @cookies = {}
  end

  def self.set(key, attrs)
    Lean::Cookie.instance.cookies[key] = attrs
  end

  def self.get(key)
    Lean::Cookie.instance.cookies[key]
  end
end
