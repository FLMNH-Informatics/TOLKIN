require 'widget'
class Viewport < Widget

  def initialize options
    @parent  ||= self
    @context ||= options[:context] || fail('context not provided')
    super
  end
  def id; 'viewport' end

  def to_s
    render partial: 'layouts/viewport', locals: { id: id }
  end
end
