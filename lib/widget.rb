require 'registry'
class Widget < ActionView::Base
  attr_reader :context,
              :parent

  def initialize options
    @parent  ||= options[:parent]  || fail("parent not provided")
    @context ||= options[:context] || @parent.context || fail("valid context not found")
    super @context.view_paths, {}, @context.controller
    (@widgets || {}).each do |k, v|
      @widgets[k] = v[]
    end
    yield if block_given?
  end

  def id
    @id ||= "#{parent.id}_#{self.class.to_s.sub(/^((Widgets::)|(Templates::)|(General::))/, '').gsub(/::/, '').underscore}"
  end

  # Both adds to and returns the widgets registry object.  When adding to the
  # registry object, only widgets with keys that have not already been occupied
  # will be initialized.  This is to allow easy overriding of default widgets
  # in inheriting classes.
  def widgets to_add = {}
    @widgets ||= Registry.new({ owner: self })
    to_add.each do |k,v|
      @widgets[k] = v[:init] unless @widgets[k]
    end
    @widgets
  end

  def params
    @context.params
  end

  def method_missing(sym, *args, &block)
    @context.send(sym, *args, &block)
  end
end
