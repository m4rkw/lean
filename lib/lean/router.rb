
class Lean::Router
  def self.routes
    ["config/routes.rb",File.dirname(__FILE__) + "/config/routes.rb"].each do |path|
      if File.exist? path
        return instance_eval File.read(path)
      end
    end

    raise "routes.rb was not found."
  end

  def self.route(request)
    if routes[request.request_method.downcase]
      routes[request.request_method.downcase].each do |uri_pattern, route|
        uri = request.path.sub(/\A\//,'').sub(/\/\z/,'')

        if matches = uri.match(uri_pattern)
          path = substitute route.split('#'), matches

          return [path[0], path[1], path[2...path.length]]
        end
      end
    end

    raise "No route found for #{request.request_method} #{request.path}"
  end

  def self.substitute(path, matches)
    path.map! do |item|
      for i in 1...matches.length
        item.gsub! "$#{i}", matches[i]
      end
      item
    end

    path
  end
end
