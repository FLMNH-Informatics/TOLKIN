require 'templates/catalog'
require 'taxa/catalogs/action_panel'
module Taxa
  class Catalog < Templates::Catalog

      def initialize options = {}
        options = {
          width: '100%',
          columns: [
              { :attribute => "name",                                             :width => 250, css_class: :css_class },
              { :attribute => "author",                                           :width => 150, css_class: :css_class },
              { :attribute => "publication",      :label => 'Publication Title',  :width => 200, css_class: :css_class },
              { :attribute => "volume_num",       :label => 'Volume',             :width => 50,  css_class: :css_class },
              { :attribute => "pages",                                            :width => 50,  css_class: :css_class },
              { :attribute => "publication_date", :label => 'Pub. Date',          :width => 50,  css_class: :css_class }
          ],
        }.merge!(options)
        widgets({
          action_panel: { init: ->{Taxa::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
        })
        super
      end
  end
end
