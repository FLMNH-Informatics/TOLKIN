class Templates::ImageGallery < Widget

  attr_reader :gallery_width, :gallery_height, :join_obj, :images, :curr_image

  def initialize params
    @gallery_width  ||= params[:gallery_width]  || fail('gallery width required')
    @gallery_height ||= params[:gallery_height] || fail('gallery height required')
    @join_obj       ||= params[:join_obj]       || fail('join obj required')
    @images         ||= load_images
    @curr_image     ||= @images.first && @images.first.scale_to((gallery_width*(2.0/3)).floor, gallery_height)
    super
  end

  def render_to_string
    %{  <div id='#{id}' class='widget image-gallery'>
          <div class='igallery-nav'>
            <table style='height: 2em; position: relative; width: #{gallery_width+30}px;'>
              <tr>
                <td class='igallery-back'>&lt;</td>
                <td class='igallery-thumbs' style='width: 100%'>
                  #{image_thumbnails}
                </td>
                <td class='igallery-forward'>&gt;</td>
              </tr>
            </table>
          </div>
          <div class='igallery-controls' style='height: 2.5em'>
            #{render_to_string_image_counter}
            <div class='igallery-add-image-control' style='float: right'>
              <span id='#{id}_add_image_control_placeholder'></span>
            </div>
          </div>
          #{render_to_string_curr_image}
        </div>  }
  end

  private

  def image_thumbnails
    %{  <div style='overflow: hidden; width: #{gallery_width}px'>
          <ul class='igallery-thumbs-list' style='width: #{thumbs_width}'>
            #{images.inject('') { |out, image|
                out << image_thumbnail(image) } }
          </ul>
        </div>  }
  end

  def render_to_string_image_counter
    %{  <div class='igallery-image-counter' style='float:left'>
          #{curr_image ? curr_image.place : 0}/#{images.size}
        </div>  }
  end

  def curr_image_offset
    (gallery_width - curr_image.width) / 2
  end

  def image_options
    %{  <div class='igallery-delete-image-control' style='
          padding: 6px;
          background-color: white;
          opacity: 0.8;
          position: absolute;
          top: 0px;
          right: 0px;
          color: #06C;
          cursor: pointer;
          font-size: 11px;
        '>
          <img src='/images/x.png' />
          Delete
        </div>  }
  end

  def render_to_string_curr_image
    %{<div class='igallery-image-and-description-wrapper'>
       #{curr_image.nil? ? '' :  %{
      <table border='1' style='border:1px'>
       <tr><td>
        <div class='igallery-image-wrapper' style='position:relative; width: #{(gallery_width*(2.0/3)).floor}px; height: #{gallery_height}px'>
            <div class='igallery-image'
              style='
                position: relative;
                width: #{curr_image.width}px;
                height: #{curr_image.height}px
              '
            >
              <a href='#{curr_image.image_src}' target='_blank'>
                <img 
                  style='
                    width: #{curr_image.width}px;
                    height: #{curr_image.height}px
                  '
                  src='#{curr_image.image_src}'
                />
              </a>
              </div>
              #{context.interact_mode.to_s == 'edit' ? image_options : ''}
              </div>
              </td><td
                class='igallery-image-description' style='
                width: #{(gallery_width*(1.0/3)).floor}px;
                height: #{gallery_height}px;
                background-color: white;
                opacity: 0.8;
                margin-bottom: 0px;
                font-size: 11px
              '>
                #{image_description}
              </div>
           </td></tr></table>
          }}
        </div>  }
  end

  def image_description
    %{<div style='width: 100%; height: 100%; position: relative'>
      #{
        (
          (context.interact_mode.to_s == 'edit') ?
            %{  <div style='padding-top: 6px; padding-bottom: 12px'>
                  <form method='post' action='#{context.project_image_path(context.current_project, curr_image)}'>
                    <input type='hidden' name='_method' value='put' />
                    <table style='width: 100%; padding: 6px'>
                      <tr>
                        <td>Caption:</td>
                      </tr>
                      <tr>
                        <td><textarea name='image[caption]' rows='5' style='width: 100%'>#{curr_image.caption || ''}</textarea></td>
                      </tr>
                      <tr>
                        <td>Photographer:</td>
                      </tr>
                      <tr>
                        <td><input type='text' style='width: 100%' name='image[photographers_credits]' value='#{curr_image.photographer || ''}' /></td>
                      </tr>
                    </table>
                    <input style='float: right; margin-right: 6px' type='submit' value='Save' />
                  </form>
                </div>  }
          :
          (curr_image.caption.blank? && curr_image.photographer.blank?  ? '' :
            %{  <p style='padding: 6px 6px 12px 6px; margin: 0'>
                  #{curr_image.caption}
                  #{curr_image.photographer.blank? ? '' : "<br /><br />Photographer: #{curr_image.photographer}" }
                </p>  } )
        )}
        <span style='position: absolute; bottom: 0'>Dimensions:
          #{curr_image.orig_width} X #{curr_image.orig_height}
        </span>
      </div>
    }
  end

  def thumbs_width
    total = 20
    images.each do | image|
      if image.thumb_width == nil
        total += ((60.to_f / image.height.to_f) *  image.width.to_i).to_i + 6 + 5
      else
        total +=  image.thumb_width.to_i  + 6 + 5
      end
      #debugger
    end
    
    "#{total}px"
#    "#{ images.inject(0) { |sum, image|
#           if image.thumb_width == nil
#
#           sum.to_i  +  image.thumb_width.to_i  + 6 + 5  }}px" || "30px"
  end

  def image_thumbnail image
    %{  <li style='float: left; padding-right: 5px'>
          <img style='border: 3px solid #BBB; cursor: pointer' data-image-id='#{image.id}' src='#{image.thumb_src}'/>
        </li>  }
  end

  def load_images
    join_obj.images.collect { |image| (image.collection = join_obj.images) && image }
  end
end