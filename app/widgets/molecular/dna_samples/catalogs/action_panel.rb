class Molecular::DnaSamples::Catalogs::ActionPanel < Templates::ActionPanel


  def initialize options
    @buttons ||= [
      { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
      { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' },
#      { label: 'Create a Report', img: { src: "/images/small_report.png" }, imode: [ 'browse', 'edit' ] }
    ]
    super
  end
    
end

