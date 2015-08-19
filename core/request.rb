
class Request
    include Singleton

    attr_reader :req

    def self.data=(data)
        Request.instance.req = data
    end

    def req=(req)
        @req = req
    end

    def self.respond_to?(method, include_private = false)
        Request.instance.req[method]
    end

    def self.method_missing method
        req = Request.instance.req

        if req.respond_to? method
            return req.send(method)
        else
            super
        end
    end
end
