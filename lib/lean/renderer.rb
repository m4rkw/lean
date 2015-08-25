
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

    render_html erubis_view(layout_path, data)
  end

  def response(code, headers, data=[])
    resp = [code, headers, data]

    Lean::Cookie.instance.cookies.each do |key, attrs|
      Rack::Utils.set_cookie_header!(headers, key, attrs)
    end

    resp
  end

  def render_html(html)
    response 200, {'Content-Type' => 'text/html'}, [html]
  end

  def render_json(data)
    response 200, {"Content-Type" => "application/json"}, [data.to_json]
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
    response 200, headers, [File.open(file).read]
  end

  def json(data)
    if data.respond_to? 'serialize'
      data = data.serialize
    end

    render_json data
  end
end
