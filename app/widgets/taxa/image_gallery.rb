  module Taxa
    class ImageGallery < Templates::ImageGallery

      def initialize params
        params = {
          remove_image_path: 'project_taxon_image_path',
          join_classname:    'Taxon',
          join_obj:          params[:taxon] || fail('taxon required'),
          gallery_width:     650,
          gallery_height:    250
        }.merge(params)
        super
      end
    end
  end
