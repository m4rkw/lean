
class Lean::HTTPFileMapper
  def initialize(
    filesystem_path:,
    sort_field: nil,
    sort_dir: nil,
    request_path: nil,
    model_class: 'MappedFile'
  )
    @filesystem_path = filesystem_path.gsub(/\/*\z/,'')
    @uri = request_path.nil? ? URI.unescape(Lean::Request.path) : request_path
    @full_path = (@filesystem_path + @uri).gsub(/\/*\z/,'')

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
    @uri == '/' ? nil : @uri.gsub(/\/*\z/,'').gsub(/\/[^\/]*?\z/,'') + '/'
  end

  def is_file?
    File.file? @full_path
  end

  def open
    escaped = Shellwords.escape(@full_path)
    mimetype = `file -bi #{escaped} |cut -d ';' -f1`.chomp

    [200, {
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
      files.push Object::const_get(@model_class).new(file)
    end

    files = files.sort_by do |file|
      file.instance_variable_get("@#{@sort_field}")
    end

    @sort_dir == 'desc' ? files.reverse : files
  end
end
