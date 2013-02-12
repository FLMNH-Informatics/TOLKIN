class Library::Citations::AuthorsCatalog < Templates::Catalog
  def initialize options = {}
    @authors ||= options[:authors] || fail('authors required')
    @collection ||= @authors
    @parent ||= options[:parent]
    @context ||= options[:context] || parent.context
    mode = interact_mode == 'browse' ?  false : true
    @columns ||= [
      { attribute: :name, label: 'Author', width: 300, order_on: false },
      { move_controls: mode, label: '', width: 100 , order_on: false  }
    ]
    @limit ||= nil
    @has_contents_form ||= false
    @has_filter_set ||= false
    widgets({
      action_panel: { init: ->{ Library::Citations::AuthorsCatalogActionPanel.new({ parent: self }) }},
      filter_set:   { init: ->{ Templates::Null.new({parent: self }) }}
    })
    super
  end

  alias_method :to_s, :render_to_string
end
