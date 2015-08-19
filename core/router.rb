
class Router
    def self.routes
        ["../config/routes.rb","config/routes.rb"].each do |path|
            if File.exist? path
                return instance_eval File.read(path)
            end
        end

        raise "No config file found."
    end

    def self.route
        if routes[Request.request_method.downcase]
            routes[Request.request_method.downcase].each do |uri_pattern, route|
                case uri_pattern
                when String
                    if uri_pattern == Request.path
                        return route.split "#"
                    end
                when Regexp
                    if (m = Request.path.sub(/\A\//,'').sub(/\/\z/,'').match uri_pattern)
                        route = route.split "#"

                        if m.length >1
                            args = []

                            for i in 1...m.length
                                regex = Regexp.new(Regexp.escape("$#{i}"))
                                if route[0].match regex
                                    route[0].sub! regex, m[1]
                                    route[0][0] = route[0][0].upcase
                                elsif route[1].match regex
                                    route[1].sub! regex, m[i]
                                else
                                    args.push m[i]
                                end
                            end

                            if !args.empty?
                                route.push args
                            end
                        end

                        return route
                    end
                end
            end
        end

        raise "No route found for #{Request.request_method} #{Request.path}"
    end
end
