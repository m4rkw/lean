
require 'json'

class Lean::Model
  include Lean::Renderer

  @table = nil

  def self.table
    @table
  end

  def self.method_missing method, *args, &block
    if !@table
      raise "Table name is not defined for #{self.to_s}"
    end

    Lean::ModelQuery.new(Lean::DB.con[@table].clone, self.to_s).send method, *args, &block
  end

  def self.hydrate(data)
    if data.is_a? Array
      objects = []

      data.each do |item|
        objects.push Object::const_get(self.to_s).new(item)
      end

      objects
    else
      Object::const_get(self.to_s).new(data)
    end
  end

  def initialize(attributes={})
    attributes.each do |key, value|
      if respond_to? "hydrate_#{key}"
        value = send "hydrate_#{key}", value
      end
      begin
        instance_variable_set("@#{key}",value)
      rescue NameError
      end
    end
  end

  def self.get(id)
    self.where(:id => id).first
  end

  def serialize(list='default')
    if respond_to? 'serializeAttributes'
      map = serializeAttributes
      if !map[list]
        raise "List #{list} is not defined for #{self.class} in serializeAttributes"
      end
      keys = map[list]
    else
      keys = instance_variables
    end

    serialized = {}

    keys.each do |key|
      if respond_to? key
        serialized[key] = send key
      else
        serialized[key] = instance_variable_get("@#{key}")
      end
    end

    serialized
  end

  def save
    if respond_to? 'beforeSave'
      beforeSave
    end

    keys = {}

    Lean::DB.con.schema(self.class.table).each do |key|
      if key[0] != 'id'
        keys[key[0]] = instance_variable_get("@#{key[0]}")
      end
    end

    if @id
      self.class.where(:id => @id).update(keys)
    else
      self.class.insert(keys)
    end

    if respond_to? 'afterSave'
      afterSave
    end
  end

  def delete
    self.class.where(:id => @id).delete
  end
end
