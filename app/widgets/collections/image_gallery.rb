class Collections::ImageGallery < Templates::ImageGallery
  def initialize params
    params = {
      remove_image_path: 'project_collection_image_path',
      join_classname:    'Collection',
      join_obj:          params[:collection] || fail('collection required'),
      gallery_width:     450,
      gallery_height:    200
    }.merge(params)
    super
  end
end