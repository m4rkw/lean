
module Lean::URITool
  def uri_sort(key, value, default_direction='asc')
    uri = Lean::Request.path.clone
    params = Lean::Request.params.clone

    alt_direction = (default_direction == 'asc') ? 'desc' : 'asc'

    if params[key] == value
      params['dir'] = (!params['dir'] || params['dir'] == default_direction) ? alt_direction : default_direction
    else
      params.delete('dir')
    end

    params[key] = value

    parameterise uri, params
  end

  def parameterise(uri, params)
    first = true
    params.each do |key, value|
      uri += first ? '?' : '&'
      uri += "#{key}=#{value}"
      first = false
    end

    uri
  end

  def uri(uri)
    parameterise uri, Lean::Request.params
  end
end
