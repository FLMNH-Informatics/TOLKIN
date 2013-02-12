module AutoComplete      
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  #
  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     auto_complete_for :post, :title
  #   end
  #
  #   # View
  #   <%= text_field_with_auto_complete :post, title %>
  #
  # By default, auto_complete_for limits the results to 10 entries,
  # and sorts by the given field.
  # 
  # auto_complete_for takes a third parameter, an options hash to
  # the find method used to search for the records:
  #
  #   auto_complete_for :post, :title, :limit => 15, :order => 'created_at DESC'
  #
  # For help on defining text input fields with autocompletion, 
  # see ActionView::Helpers::JavaScriptHelper.
  #
  # For more examples, see script.aculo.us:
  # * http://script.aculo.us/demos/ajax/autocompleter
  # * http://script.aculo.us/demos/ajax/autocompleter_customized
  module ClassMethods
    def auto_complete_for(object, method, options = {})
      simple_object = object.to_s.demodulize.underscore

      const_set("AUTOCOMPLETE_OPTIONS_FOR_#{simple_object.upcase}_#{method.to_s.upcase}", options)

      define_method("auto_complete_for_#{simple_object}_#{method}") do
        original_options = eval("self.class::AUTOCOMPLETE_OPTIONS_FOR_#{simple_object.upcase}_#{method.to_s.upcase}")
        extra_find_options = original_options.clone
        extra_find_options.delete(:project_scope)
        extra_find_options.delete(:active_scope)
        conditions = "LOWER(#{method}) LIKE '#{params[:value].downcase}%' "
        #conditions = "LOWER(#{method}) LIKE '#{params[simple_object][method].downcase}%' "
        

        obj = object.to_s.camelize.constantize
        obj = obj.active if original_options[:active_scope]

        if(obj.attr?(:project_id))
          conditions << "AND project_id=#{current_project.id}" if original_options[:project_scope] == true
        elsif(obj.attr?(:owner_graph_rtid))
          conditions << "AND owner_graph_rtid=#{current_project.rtid}" if original_options[:project_scope] == true
        else fail "unknown project attr name for table"
        end
        
        
        find_options = {
          conditions: conditions,
          select: "#{method}, max(#{obj.primary_key})",
          group:  "#{method}",
          limit:  10,
          order: 'name DESC'
        }.merge!(extra_find_options)

        
        @items = obj.find(:all, find_options)

        render inline: "<%= auto_complete_result @items, '#{method}' %>"
      end
    end
  end
  
end
