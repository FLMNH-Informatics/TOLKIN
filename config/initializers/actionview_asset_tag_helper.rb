module ActionView
  module Helpers
    module AssetTagHelper
      def javascript_include_tag(*sources)
        options = sources.extract_options!.stringify_keys
        concat  = options.delete("concat")
        cache   = concat || options.delete("cache")
        recursive = options.delete("recursive")

        if concat || (config.perform_caching && cache)
          joined_javascript_name = (cache == true ? "all" : cache) + ".js"
          joined_javascript_path = File.join(joined_javascript_name[/^#{File::SEPARATOR}/] ? config.assets_dir : config.javascripts_dir, joined_javascript_name)

          unless config.perform_caching && File.exists?(joined_javascript_path)
            write_asset_file_contents(joined_javascript_path, compute_javascript_paths(sources, recursive))
          end
          javascript_src_tag(joined_javascript_name, options)
        else
          sources = expand_javascript_sources(sources, recursive)
#          ensure_javascript_sources!(sources) if cache  ### CHANGED
          sources.collect { |source| javascript_src_tag(source, options) }.join("\n").html_safe
        end
      end
    end
  end
end
