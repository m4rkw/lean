
class Lean::ModelQuery
  def initialize(dataset, class_name)
    @dataset = dataset
    @class_name = class_name
  end

  def method_missing method, *args, &block
    resp = @dataset.send method, *args, &block

    if resp.is_a?(Hash) or resp.is_a?(Array)
      return Object::const_get(@class_name).hydrate(resp)
    elsif resp.is_a? Sequel::Dataset
      @dataset = resp
      return self
    end

    resp
  end
end
