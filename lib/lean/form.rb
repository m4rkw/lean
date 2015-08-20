
class Lean::Form
  include Lean::Renderer

  def initialize(postdata, fields)
    @postdata = postdata
    @fields = fields
    @errors = {}

    if !@postdata.empty?
      validate
    end
  end

  def config
    Lean::Config
  end

  def validate
    @fields.each do |field|
      if field['required'] and (!@postdata[field['name']] || @postdata[field['name']].length <1)
        if field['required_message']
          @errors[field['name']] = field['required_message']
        else
          @errors[field['name']] = "This field is required"
        end
      end
    end
  end

  def posted?
    Lean::Request.post?
  end

  def valid?
    @errors.empty?
  end

  def textinput(name, label, options={})
    partial('form/textinput',{
      'name' => name,
      'label' => label,
      'value' => HTMLEntities.new.encode(@postdata[name]),
      'error' => @errors[name]
    })
  end

  def textarea(name, label, options={})
    partial('form/textarea',{
      'name' => name,
      'label' => label,
      'value' => HTMLEntities.new.encode(@postdata[name]),
      'error' => @errors[name]
    })
  end

  def submit(name, label, options={})
    partial('form/submit',{
      'name' => name,
      'label' => label,
    })
  end

  def recaptcha(name)
    partial('form/recaptcha',{
      'error' => @errors[name]
    })
  end

  def render
    form = ''

    @fields.each do |field|
      case field['type']
      when "text"
        form += textinput(field["name"],field["label"])
      when "textarea"
        form += textarea(field["name"],field["label"])
      when "submit"
        form += submit(field["name"],field["label"])
      when "recaptcha"
        form += recaptcha(field['name'])
      else
        raise "Unknown field type: #{field['type']}"
      end
    end

    form
  end
end
