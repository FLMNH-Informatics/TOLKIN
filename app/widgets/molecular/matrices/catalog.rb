class Molecular::Matrices::Catalog < Templates::Catalog
  def initialize options
    @data_id ||= :id
    options = {
      columns: [
        { :attribute => "name",                                    :width => 250 },
        { :attribute => "description",                             :width => 150 },
        { :attribute => "copied_from",                             :width => 150 },
        { :attribute => "created_by",                              :width => 90 },
        { :attribute => "created_at",                              :width => 150 },
        { :attribute => "updated_by",    :label => 'Last Updater', :width => 90 },
        { :attribute => "updated_at",    :label => 'Last Update',  :width => 150 }
      ]
    }.merge!(options)
    widgets({
      action_panel: { init: ->{Molecular::Matrices::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }#,
      #filter_set:   { init: ->{Templates::Catalogs::FilterSetMatrix.new({ parent: self, context: context, catalog: self }) } }
    })
    super
  end
end
