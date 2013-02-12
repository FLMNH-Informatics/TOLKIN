require 'yui/compressor'

module SprocketsApplication
  mattr_accessor :use_page_caching
  self.use_page_caching = true
  
  class << self
    def routes(map)
      map.resource(:sprockets)
    end
    
    def source
      if @is_development ||= (ENV['RAILS_ENV'] == 'development')
        concatenation.to_s
      else
        @compressor ||= YUI::JavaScriptCompressor.new(:munge => true)
        begin
        @compressor.compress(concatenation.to_s.force_encoding('utf-8'))
        rescue => e
          e
        end
      end
      
    end
    
    def install_script
      #concatenation.save_to(asset_path)
    end
    
    def install_assets
      secretary.install_assets
    end

    protected
      def secretary
        @secretary ||= Sprockets::Secretary.new(configuration.merge(:root => Rails.root))
      end
    
      def configuration
        YAML.load(IO.read(Rails.root.join("config", "sprockets.yml"))) || {}
      end

      def concatenation
        secretary.reset! unless source_is_unchanged?
        secretary.concatenation
      end

      def asset_path
        File.join(Rails.public_path, "sprockets.js")
      end

      def source_is_unchanged?
        previous_source_last_modified, @source_last_modified = 
          @source_last_modified, secretary.source_last_modified
          
        previous_source_last_modified == @source_last_modified
      end
  end
end
