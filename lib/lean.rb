
require 'cgi'
require 'shellwords'
require 'net/smtp'
require 'htmlentities'
require 'erubis'
require 'singleton'
require 'sequel'

$autoload_paths = [
    "core/",
    "lib/",
    "cont/",
    "form/",
    "model/"
]

class Object
  @@_const_missing_cache = {}

  def Object.const_missing(name)
    if @@_const_missing_cache[name]
      raise "Class not found: #{name.to_s}"
    end

    @@_const_missing_cache[name] = 1

    patterns = []

    $autoload_paths.each do |path|
      if File.exist? "#{path}"
        patterns.push "#{path}/**/*"
      end
    end

    patterns.push "#{File.dirname(__FILE__)}/lean/**/*"

    patterns.each do |pattern|
      Dir.glob(pattern).each do |file|
        if (file.split('/').pop.sub(/\.rb\z/,'') == name.to_s.downcase)
          if file.match /lean-[0-9\.]+\/lib\/lean\//
            require 'lean/' + name.to_s.downcase
          else
            require "./" + file
          end
          _class = const_get(name)
          return _class if _class

          raise "Class not found: #{name.to_s}"
        end
      end
    end
    raise "Class not found: #{name.to_s}"
  end
end

class Array
  def serialize
    serialized = []

    self.each do |item|
      if item.is_a?(Hash)
        serialized.push item
      else
        serialized.push item.serialize
      end
    end

    serialized
  end
end

class Lean
  def self.call(env)
    Lean::Request.data = Rack::Request.new(env)

    Lean.new.execute
  end

  def execute
    controller, method, args = Lean::Router::route

    db = Lean::Config.get(:db)

    Lean::Log.add("notice","#{Lean::Request.request_method} #{Lean::Request.url}")

    Lean::DB.con = Sequel.connect(db)
    #Lean::Auth.logged_in

    controller = Object::const_get(controller).new(method, args)

    if !controller.respond_to? method
      return Lean::Controller.new.notfound
    end

    if controller.respond_to? 'beforeAction'
      resp = controller.beforeAction(method, args)

      if resp.kind_of? Array
        return resp
      end
    end

    controller.send(method, *args)
  end
end
