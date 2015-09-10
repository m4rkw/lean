
class Lean::Router
  def self.routes
    ["config/routes.rb",File.dirname(__FILE__) + "/config/routes.rb"].each do |path|
      if File.exist? path
        return instance_eval File.read(path)
      end
    end

    raise "routes.rb was not found."
  end

  def self.route
    if routes[Lean::Request.request_method.downcase]
      routes[Lean::Request.request_method.downcase].each do |uri_pattern, route|
        uri = Lean::Request.path.sub(/\A\//,'').sub(/\/\z/,'')

        if m = uri.match(uri_pattern)
          path = route.split '#'
          args = []

          for i in 0...path.length
            for j in 1...m.length
              path[i].gsub! "$#{j}", m[j]
            end

            if i >= 2
              args.push path[i]
            end
          end

          return [path[0], path[1], args]
        end
      end
    end

    raise "No route found for #{Lean::Request.request_method} #{Lean::Request.path}"
  end
end
