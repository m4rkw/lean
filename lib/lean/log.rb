
class Lean::Log
  def self.add(type, message)
    begin
      File.open("log/lean.log","a+") do |f|
        f.write("#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} - [#{type}]: #{message}\n")
      end
    rescue Errno::EACCES
      raise Errno::EACCES, "Unable to write to log file: log/lean.log"
    end
  end
end
