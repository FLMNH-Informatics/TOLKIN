require "yui/compressor"

class JavascriptsController < ApplicationController
  def get
    filename = params['filenames'].first
    filepath = JsServe.source_filenames_hash[filename]
    # in development mode serve js files without compression
    if(@is_development ||= (ENV['RAILS_ENV'] == 'development'))
      render :file => filepath
    else
      # unless there is already a stored compressed file that is more recent than the original,
      # create a new compression
      unless(File.exists?('public/javascripts/lib/local/' + filename) &&
            File.mtime('public/javascripts/lib/local/' + filename) > File.mtime(filepath))
        contents = File.read(filepath)
        @compressor ||= YUI::JavaScriptCompressor.new(:munge => true)
        contents = @compressor.compress(contents)
        # save compressed file for current and future use
        File.open('public/javascripts/lib/local/' + filename, 'w') do |file|
          file.write(contents)
        end
      end
      #serve saved compressed js file to user
      render :file => 'public/javascripts/lib/local/' + filename
    end
  end
end
