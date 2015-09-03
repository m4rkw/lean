
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
        case uri_pattern
        when String
          if uri_pattern == Lean::Request.path
            return route.split "#"
          end
        when Regexp
          if (m = Lean::Request.path.sub(/\A\//,'').sub(/\/\z/,'').match uri_pattern)
            route = route.split "#"

            if route[2]
              route[2] = [route[2]]
            end

            if m.length >1
              for i in 1...m.length
                regex = Regexp.new(Regexp.escape("$#{i}"))
                if route[0].match regex
                  route[0].sub! regex, m[1]
                  route[0][0] = route[0][0].upcase
                elsif route[1].match regex
                  route[1].sub! regex, m[i]
                end
              end
            end

            if route[2]
              for i in 0...route[2].length
                for j in 1...m.length
                  regex = Regexp.new(Regexp.escape("$#{j}"))
                  if route[2][i].match regex
                    route[2][i].sub! regex, m[j]
                  end
                end
              end
            end

            return route
          end
        end
      end
    end

    raise "No route found for #{Lean::Request.request_method} #{Lean::Request.path}"
  end
end
