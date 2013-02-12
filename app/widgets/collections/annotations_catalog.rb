class Collections::AnnotationsCatalog < Templates::Catalog
  def initialize options = {}
    #@annotations ||= options[:annotations] || fail('annotations required')
    @collection ||= @collections
    @parent ||= options[:parent]
    @context ||= options[:context] || parent.context
    mode = interact_mode == 'browse' ?  false : true
    @columns ||= [
        { attribute: 'taxon', label: 'Taxon', width: 182, order_on: false },
        { attribute: 'name', label: 'Determiner', width: 150, order_on: false },
        { attribute: 'date', label: 'Date', width: 100, order_on: false },
        { attribute: 'inst', label: 'Institution', width: 150, order_on: false }
    ]
    @limit ||= nil
    @has_contents_form ||= false
    @has_filter_set ||= false
    widgets({
      action_panel: { init: ->{ Collections::AnnotationsCatalogActionPanel.new({ parent: self }) }},
      filter_set:   { init: ->{ Templates::Null.new({parent: self }) }}
    })
    super
  end

  alias_method :to_s, :render_to_string
end
