
class Lean::Config
  include Singleton

  def initialize
    @config = load_config
  end

  def load_config
    config = {}

    ["config/config.rb","../config/config.rb"].each do |path|
      if File.exist? path
        instance_eval(File.read(path)).each do |key, value|
          config[key] = value
        end
      end
    end

    config
  end

  def get(key)
    @config[key] or raise "Config key not found: #{key}"
  end

  def self.get(key)
    Lean::Config.instance.get key
  end
end
