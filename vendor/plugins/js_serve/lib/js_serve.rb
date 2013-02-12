require 'sprockets_application'

module JsServe
  class << self
    def routes(map)
      map.connect 'javascripts/*filenames', :controller => 'javascripts', :action => 'get'
    end

    def source_filenames_hash
      @source_filenames_hash ||= Hash[ *source_filenames_array.map{|filename| [ filename.match(/^.+\/([^\/]+\.js)$/)[1], filename ]}.flatten ]
    end

    def source_filenames_array
      @source_filenames_array ||= SprocketsApplication.send(:secretary).preprocessor.source_files.map{|file| file.pathname.absolute_location }
    end
  end
end