#module requires the functionality of
#mimetype_fu gem .  This is required for setting
#content-type headers from file uploads using swfupload
module SetMimeType
  def set_attachment_type
    if defined?(params[:Filedata].tempfile)
      type = File.mime_type?(params[:Filedata].tempfile)
      params[:Filedata].headers.sub!("Content-Type: application/octet-stream", "Content-Type: #{type}")
      params[:Filedata].content_type = type
    end
  end
end
