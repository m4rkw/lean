
class Lean::HTTPFileMapper::MappedFile < Lean::Model
  attr_reader :name
  attr_reader :uri
  attr_reader :size
  attr_reader :timestamp
  attr_reader :path

  def self.sortFields
    {
      'name' => 'asc',
      'size' => 'asc',
      'timestamp' => 'desc'
    }
  end

  def self.defaultSortField
    'timestamp'
  end

  def is_file
    File.file? @path
  end

  def is_directory
    File.directory? @path
  end
end
