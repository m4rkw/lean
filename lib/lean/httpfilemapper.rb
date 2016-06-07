
class Lean::HTTPFileMapper
  def initialize(
    request: nil,
    filesystem_path:,
    sort_field: nil,
    sort_dir: nil,
    request_path: nil,
    model_class: 'MappedFile',
    restrict_paths: []
  )
    @request = request
    @filesystem_path = filesystem_path.gsub(/\/*\z/,'')
    @uri = request_path.nil? ? URI.unescape(@request.path) : request_path
    @full_path = (@filesystem_path + @uri).gsub(/\/*\z/,'')
    @restrict_paths = restrict_paths

    @model_class = model_class
    if sort_field.nil?
      @sort_field = Object::const_get(model_class).defaultSortField
    else
      @sort_field = sort_field
    end
    if sort_dir.nil?
      @sort_dir = Object::const_get(model_class).sortFields[@sort_field]
    else
      @sort_dir = sort_dir
    end

    if !allowed(@uri, @full_path)
      raise RuntimeError, "Invalid path: #{@uri}"
    end

    if @uri != '/' and !@restrict_paths.empty?
      allowed = false

      @restrict_paths.each do |regex|
        if @full_path.match(regex)
          allowed = true
          break
        end
      end

      if !allowed
        raise RuntimeError, "Invalid path: #{@uri}"
      end
    end

    if File.file? @full_path
      download
    end
  end

  def allowed(uri, full_path)
    uri = uri.gsub(/\A\//,'').gsub(/\/\z/,'')
    uri.empty? and return true

    Dir.glob(@filesystem_path + "/**/*").include? full_path
  end

  def parent
    if @uri == '/'
      return nil
    end

    parent = @uri.gsub(/\/[^\/]*\z/,'')
    parent.length >0 ? parent : '/'
  end

  def is_file?
    File.file? @full_path
  end

  def open
    escaped = Shellwords.escape(@full_path)
    mimetype = `file -bi #{escaped} |cut -d ';' -f1`.chomp

    [200, {
        #'X-Accel-Redirect' => @full_path,
        'X-Sendfile' => @full_path,
        'Content-Type' => mimetype,
        'Content-disposition' => "attachment; filename=\"#{@uri.split('/').last}\""
      },
      []]
  end

  def download
    response = open

    response[1]["Content-Type"] = "application/octet-stream"
    response[1]["Content-Transfer-Encoding"] = "Binary"

    response
  end

  def files
    files = []

    Dir.glob(@full_path.gsub(/\[/,'\\\[').gsub(/\]/,'\\\]') + "/**").each do |file|
      while file.match /\/\//
        file.gsub!(/\/\//,'/')
      end

      if @restrict_paths.empty?
        allowed = true
      else
        allowed = false

        @restrict_paths.each do |regex|
          if file.match(regex)
            allowed = true
            break
          end
        end
      end

      if allowed
        files.push Object::const_get(@model_class).new(file)
      end
    end

    files = files.sort_by do |file|
      file.instance_variable_get("@#{@sort_field}")
    end

    @sort_dir == 'desc' ? files.reverse : files
  end
end
