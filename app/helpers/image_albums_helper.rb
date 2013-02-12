module ImageAlbumsHelper

  def get_image_data(file)
    send_data
  end

  def images_catalog
    ImageAlbums::Catalog.new({
        collection: @images,
        parent: content_frame
      }).render_to_string

  end

  def image_list_widget
    ImageAlbums::ImageList.new({
        context: self,
        images: @images,
        parent: content_frame })
  end

  def image_albums_action_panel
    Widgets::ImageAlbums::Catalogs::ActionPanel.new({
      parent: viewport
    })
#    action_panel 'viewport_content_frame_molecular_bioentry_catalog_molecular_bioentry_action_panel',
#      [ { label: 'Import',
#          img: { src: '/images/addnew.gif' },
#        }
#      ]
  end

  def images
    @images
  end

  def images
    ImageAlbums::ImageGallery.new({
      context: self,
      images: @images,
      parent: content_frame,
    }).render_to_string
  end
end
