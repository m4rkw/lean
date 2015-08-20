
class Lean::Model
  include Lean::Renderer

  @@table = nil

  def self.method_missing method, *args, &block
    if !@@table
      raise "Table name is not defined for #{self.class}"
    end

    Lean::DB.con[@@table].send method, *args, &block
  end

  def self.hydrate(data)
    objects = []

    data.each do |item|
      objects.push Object::const_get(self.to_s).new(item)
    end

    objects
  end

  def initialize(attributes)
    attributes.each do |key, value|
      if respond_to? "hydrate_#{key}"
        value = send "hydrate_#{key}", value
      end
      instance_variable_set("@#{key}",value)
    end
  end
end