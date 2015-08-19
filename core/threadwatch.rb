
class ThreadWatch
    def initialize
        hash = scan_dir "."

        while 1
            new_hash = scan_dir "."

            if differs hash, new_hash
                exit
            end

            sleep 1
        end
    end

    def scan_dir(path, hash={})
        Dir.glob("../**/*").each do |file|
            hash[path + "/" + file] = File.stat(path + "/" + file).mtime
        end

        hash
    end

    def differs(hash, new_hash)
        if hash.keys != new_hash.keys
            return true
        end

        hash.each do |key,value|
            if new_hash[key] != value
                return true
            end
        end

        false
    end
end
