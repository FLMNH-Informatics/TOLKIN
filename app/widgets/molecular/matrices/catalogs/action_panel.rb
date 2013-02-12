class Molecular::Matrices::Catalogs::ActionPanel < Templates::ActionPanel

  def initialize options
    @buttons ||= [
            { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
            { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' }
    ]
    super
  end
end
