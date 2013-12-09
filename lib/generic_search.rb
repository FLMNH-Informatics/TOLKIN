# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'generic_search_helper'
module GenericSearch
  include GenericSearchHelper

  def self.included(klass)
    class << klass

      def get_filters
        searchable_columns.inject({}){|hash, col|
          (
            hash[
              col.respond_to?(:name) ? col.name : col['name']
            ] = col
          ) &&
          hash
        }
      end
      
      def generic_search(search_params, extra_params = {})
#        GenericSearchHelper::Helper.sanitize!(search_params, selected_filters)
        #Collection.searchlogic({:limit => 10}.merge(search_params || {}))
        search_params = search_params || {}
        search = self.searchlogic(search_params.merge(extra_params))
        SyncCollection.new({ type: self, search: search })
      end

      private
      def searchable_columns
        @searchable_columns  ||= (
          columns
            .reject { |col| col.primary || col.name =~ /(_count|_at|_by)$/ || col.name == inheritance_column || col.name =="desc" || col.sql_type == "integer" && col.name[-3..-1] != "_id" || col.sql_type == "date" || col.sql_type == "tsvector"}
        )
        @searchable_columns
        
      end
    end
  end
end
