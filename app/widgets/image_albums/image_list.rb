module ImageAlbums
class ImageList < Widget

  attr_accessor :images

    def initialize options
      @images = options[:images]
      widgets({
        action_panel: { init: ->{ ImageAlbums::Catalogs::ActionPanel.new({ parent: self }) }},
      })
      super
    end

    def to_s
      render partial: 'image_albums/album_index'
    end
  end
end