
class Lean::ThreadWatch
  def initialize
    exclude_paths = [
      'public/',
      'view/',
      'log/',
      'bin/',
      'run.sh'
    ]

    hash = scan_dir(exclude_paths)

    while 1
      new_hash = scan_dir(exclude_paths)

      if differs hash, new_hash
        exit
      end

      sleep 1
    end
  end

  def scan_dir(exclude_paths, hash={})
    Dir.glob("**/*").each do |file|
      if File.file?(file) and !excluded(file, exclude_paths)
        hash[path + "/" + file] = File.stat(path + "/" + file).mtime
      end
    end

    hash
  end

  def excluded(file, exclude_paths)
    exclude_paths.each do |excluded|
      if file[0,excluded.length] == excluded
        return true
      end
    end
    false
  end

  def differs(hash, new_hash)
    if hash.keys != new_hash.keys
      return true
    end

    hash.each do |key,value|
      if new_hash[key] != value
        puts "File changed: [#{key}] restarting..."
        return true
      end
    end

    false
  end
end
