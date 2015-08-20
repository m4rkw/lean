
require 'cgi'
require 'shellwords'
require 'net/smtp'
require 'htmlentities'
require 'erubis'
require 'xmlsimple'
require 'singleton'

$autoload_paths = [
    "core/",
    "lib/",
    "cont/",
    "model/"
]

class Object
  def Object.const_missing(name)
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

class Lean
  def self.call(env)
    Lean::Request.data = Rack::Request.new(env)

    Lean.new.execute
  end

  def execute
    controller, method, args = Lean::Router::route

    controller = Object::const_get(controller).new

    if !controller.respond_to? method
      return Lean::Controller.new.notfound
    end

    controller.send(method, *args)
  end
end
