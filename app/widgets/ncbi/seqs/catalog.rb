class Ncbi::Bioentries::Catalog < Templates::Catalog
  def initialize options
    options = {
      columns: [
        { :attribute => "name", :width => 250 },
        { :attribute => "otu_groups", :map => 'name', :width => 200 },
        { :attribute => "creator.label", :label => 'Owner', :width => 150 }
      ]
    }.merge!(options)
    super
  end
end