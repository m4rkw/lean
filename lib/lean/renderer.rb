
module Lean::Renderer
  def bind_values(data)
    b = binding()

    data.each do |key, value|
      b.local_variable_set(key, value)
    end

    b
  end

  def erubis_view(path, data={})
    Erubis::FastEruby.new(File.read(path)).result(bind_values(data))
  end

  def self.view_exists?(view)
    ["../view/**/*","view/**/*"].each do |pattern|
      files = Dir.glob(pattern)
      if !files.empty?
        files.each do |file|
          if file.gsub(/\A\.\.\/view\//, '').gsub(/view\//, '') == "#{view}.erb"
            return true
          end
        end
      end
    end

    false
  end

  def render(view, data={})
    if File.exists?("view/layout/#{@layout}.erb")
      layout_path = "view/layout/#{@layout}.erb"
    elsif File.exists?(File.dirname(__FILE__) + "/view/layout/#{@layout}.erb")
      layout_path = File.dirname(__FILE__) + "/view/layout/#{@layout}.erb"
    else
      raise "Layout not found: #{@layout}"
    end

    data['view'] = view

    layout = erubis_view(layout_path, data)

    return [200, {'Content-Type' => 'text/html'}, [layout]]
  end

  def partial(view, data={})
    ["view/**/*",File.dirname(__FILE__) + "/view/**/*"].each do |pattern|
      files = Dir.glob(pattern)
      if !files.empty?
        files.each do |file|
          if file.gsub(/\A.*?view\//, '') == "#{view}.erb"
            return erubis_view(file, data)
          end

        end
      end
    end

    raise "View not found: #{view}"
  end

  def render_file(file, headers={})
    return [200, headers, [File.open(file).read]]
  end
end