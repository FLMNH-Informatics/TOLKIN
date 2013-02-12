  module Templates
    module Catalogs
      class FilterSet < Widget


        attr_reader :filters, :catalog, :text_box_size

        def initialize options
          @catalog       ||= options[:catalog] || fail("catalog required")
          @filters       ||= @catalog.collection.klass.get_filters #.values().sort{|a, b| a['name'] <=> b['name']}
          @text_box_size ||= options[:text_box_size] || 30
          super
        end

        def select_options
          if(filters.nil?)
            return "<option selected='selected'>loading filters...</option>"
          else
            filters_html
          end
        end

        def filter_rows
          # FIXME: needs to be made to work in ruby - moved here from js
#          (context.params[:search] || {}).map do |k,v|
#            k = k.sub(/_like$/, '')
#            filter = filters[k]
#            until filter || k == '_id'
#              k = k.sub(/_?[A-Za-z]+(_id)?$/, '_id')
#              filter = filters[k]
#            end
#            filter_row(filter, v);
#          end.join
          # Not sure what the above code should do - don't think it ever produced anything
          #anyhow, added the code belowe to display default filters that should show on page load
          #all one has to do is add an active => true key,value to the searchable_columns hash in the model.
          #filters_html method belowe also modified to disable select value for active filter
          out = ''
          @filters.each do |key,value|
             out <<
             "<tr>
                <td>
                  <input type=\"button\" class=\"button active\" value=\"x\" id=\"fv_#{value['name']}\">
                </td>
                <td style=\"width:10px\"></td>
                <td><label>#{value['label']}</label></td>
                <td><input type=\"text\" size=\"30\" name=\"search[#{value['name']}]\" value=\"\"></td>
              </tr>"  if defined?(value['active']) && value['active'] == true
          end
          return raw(out)
        end

        def render_to_string
          render partial: 'filters/form'
        end

        private

        def filter_row filter, term = ''
          filter_label = filter['label'] || filter['name'].humanize
          if filter['name'].end_with?("_id")
            str = filter['name'].strip().underscore().gsub(/ /, '_').gsub(/_id/, '')
            str_name = "#{str}_name"
            row = "<tr><td class='close' id='fv_#{filter['name']}' size='3'>x</td><td><label>#{filter_label}</label></td><td><input type='text' size='#{text_box_size}' name='search[#{str_name}]' value='#{term}' /></td></tr>"
          elsif (filter['type'] == "integer")
            str = filter['name'].strip.underscore.gsub(' ', '_')
            str_name = str
              row = "<tr><td class='close' id='fv_#{filter['name']}' size='3'>x</td><td><label for='search_#{str}'>#{filter_label} Range</label></td><td><input type='text' size='#{text_box_size/2}' name='search[#{str_name}_gte]'"
              row = row + "value=''"
              row = row + "id='search_"+ str_name +"_gte'/>-<input type='text' size='#{text_box_size/2}' name='search[#{str_name}_lte]' "
              row = row + "value=''"
              row = row + " id='search_"+ str_name +"_lte'/></td></tr>"
          else
            str = filter['name'].strip.underscore.gsub(' ', '_')
            str_name = str+"_like"
            row = "<tr><td class='close' id='fv_#{filter['name']}' size='3'>x</td><td><label>#{filter_label}</label></td><td><input type='text' size='#{text_box_size}' name='search[#{str_name}]' value='#{term}' /></td></tr>";
          end
          row
        end

        def filters_html
          filters.values.inject("<option value=''>Select Filter</option>") do |out, item|
            out <<
              "<option data-field-type='#{
                item.respond_to?(:type) ? item.type : item['type']
              }' value='#{
              item.respond_to?(:name) ? item.name : item['name']
              }' #{

              (
                @context.params[:search].try(
                  :[],
                  (item.respond_to?(:name) ?
                    item.name :
                    item['name']
                  )+'_like'
                ) || (defined?(item['active']) && item['active'] == true) ?
                  " disabled='disabled'" :
                  '' )}

                   >#{
                ( item.respond_to?(:label) ?
                  item.label :
                  (item.respond_to?(:[]) ? item['label'] : nil) ||
                  (item.respond_to?(:name) ? item.name : item['name']).humanize
                )
              }

              </option>"
          end
        end
      end
    end
  end
