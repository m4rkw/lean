
require 'cgi'
require 'shellwords'
require 'net/smtp'
require 'htmlentities'
require 'erubis'
require 'xmlsimple'

$autoload_paths = [
    "core/",
    "lib/",
    "cont/",
    "model/"
]

class Object
    def Object.const_missing(name)
        $autoload_paths.each do |path|
            patterns = []

            if File.exist? "../#{path}"
                patterns.push "../#{path}/**/*"
            end

            patterns.push "#{path}/**/*"

            patterns.each do |pattern|
                Dir.glob(pattern).each do |file|
                    if (file.split('/').pop.sub(/\.rb\z/,'') == name.to_s.downcase)
                        require "./" + file
                        _class = const_get(name)
                        return _class if _class
                        raise "Class not found: #{name.to_s}"
                    end
                end
            end
        end
        raise "Class not found: #{name.to_s}"
    end
end

class Lean
    def self.call(env)
        Request.data = Rack::Request.new(env)

        Lean.new.execute
    end

    def execute
        controller, method, args = Router::route

        controller = Object::const_get(controller).new

        if !controller.respond_to? method
            return Controller.new.notfound
        end

        controller.send(method, *args)
    end
end
