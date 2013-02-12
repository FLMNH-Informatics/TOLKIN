class Taxa::SynonymsCatalog < Templates::Catalog
  def initialize options
    @columns = [
        { attribute: :label,              label: 'Name',       width: 500, css_class: 'css_class' },
        { attribute: :'namestatus.label', label: 'Namestatus', width: 100, css_class: 'css_class' }
#        { attribute: :name,   width: 175 },
#        { attribute: :author, width: 100 },
#        { attribute: :publication, label: 'Publication Title', width: 175 },
#        { attribute: :volume_num,  label: 'Volume', width: 65 },
#        { attribute: :pages, width: 40 },
#        { attribute: :publication_date, label: 'Publication Date', width: 50 }
        ]

    @collection = options[:taxon].synonyms
    @limit = 10
    @has_filter_set = false
    @has_contents_form = false
    super
  end
end