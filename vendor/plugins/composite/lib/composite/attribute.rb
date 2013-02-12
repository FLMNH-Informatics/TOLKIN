class Composite::Attribute
  attr_reader :label, :attrs

  def initialize label, attrs
    @label = label
    @attrs = [*attrs]
  end
end
