require 'templates/catalogs/filter_set'
require 'templates/null'

  module Templates
    class Catalog < Widget

      attr_reader :page, :limit, :columns, :collection

      def initialize options
        @can_publify ||= options[:can_publify].nil? ? true : options[:can_publify]
        @empty_msg   ||= options[:empty_msg] || 'No results found.'
        @columns    ||= options[:columns] || fail('columns required')
        @collection ||= options[:collection] || fail("collection required")
        @page       ||= options[:page]  || 1
        @limit      ||= options[:limit] || (@collection.respond_to?(:limit_value) && @collection.limit_value) || nil
        @data_id    ||= options[:data_id] || :id
        @has_contents_form = options[:has_contents_form] unless options[:has_contents_form] === nil
        @has_contents_form = (@has_contents_form === false) ? false : true
        @has_filter_set = options[:has_filter_set] unless options[:has_filter_set] === nil
        @has_filter_set = (@has_filter_set === false) ? false : true
        widgets({
          action_panel: { init: ->{ Templates::Null.new({ parent: self, context: context }) }},
          filter_set:   { init: ->{ @has_filter_set ?
            Templates::Catalogs::FilterSet.new({ parent: self, context: context, catalog: self })
            : Templates::Null.new({parent: self , context: context})}}})
        super options do
          yield if block_given?
        end
      end

      def action_panel
        widgets[:action_panel] ? widgets[:action_panel].to_s : ''
      end

      def checkbox_cell item
        "<div class='checkbox_cell'><input type='checkbox' name='data[]' value='#{item.send(@data_id)}'#{checked} /></div>"
      end

      def checked
        ''
      end

    #  def css_class
    #
    #  end


      def filters
        @has_filter_set ? "<tr><td>#{widgets[:filter_set].render_to_string}</td></tr>" : ''
      end

      def column_headings
        columns.map do |column|
          "<th class='attribute_name'><div style='width: #{column[:width]}px'>#{column[:label] || column[:attribute].to_s.gsub(/_/, " ").capitalize}</div></th>"
        end.join('')
      end

      def contents
        out = %{<table style="height: #{[(@limit||@collection.to_a.size)*23, 23].max}px">#{entries}#{filler}</table>}
        out = "<form id='list_items_form'><input id='selected_conditions' type='hidden' value='#{@conditions.to_s}' name='conditions'/>#{out}</form>" if(@has_contents_form)
        out
      end

      def count_num
        ''
      end

      def counter_nav
        count = nil; start = nil; finish = nil
        count = @limit.nil? ? collection.length : collection.count #count returns the total before eliminating nonpublic records, we need length for public record
        if count
          start = count > 0 ? (collection.scoped.offset_value || 0) + 1 : 0
          finish = (!collection.scoped.limit_value || ((start + collection.scoped.limit_value - 1) > count)) ? count : start + collection.scoped.limit_value - 1
        end
        if ((count || count ===0) && (start || start ===0) && (finish || finish ===0))
          left_active = start > 1
          right_active = finish < count

          %{<span class='control#{left_active ? '' : ' inactive'}'>|&lt;</span>
            <span class='control#{left_active ? '' : ' inactive'}'>&lt;&lt;</span>
            #{start} - #{finish} of <span id="collection_count">#{count}</span>
            <span class='control#{right_active ? '' : ' inactive'}'>&gt;&gt;</span>
            <span class='control#{right_active ? '' : ' inactive'}'>&gt;|</span>
          }
        else
          %{<span class='control inactive'>|&lt;</span>
            <span class='control inactive'>&lt;&lt;</span>
            <span class='control inactive'>&gt;&gt;</span>
            <span class='control inactive'>&gt;|</span>
          }
        end
      end

      def can_publify
        model = params[:controller].camelize.singularize.constantize
        model.public_model?.to_s
      end

      def publifier_container
        %(<td id="publifier_container" style="width:33%" data-can-publify="#{can_publify}">
            #{publifier_control}
          </td>)
      end

      def publifier_control
        actions = ["Make Selected Public", "Make All Public","Make Selected Private","Make All Private"]
        model = params[:controller].camelize.singularize.constantize
        output =  select_tag("publifier_select", options_for_select(actions)) + raw("<input class=\"publifier\" type=\"button\" id=\"publifierButton\" value=\"Go\"/>")
        output if current_user.is_updater_for?(current_project) && model.public_model? && @can_publify && interact_mode == "edit"
      end

      def render_to_string
        render partial: 'widgets/catalog'
      end

      private

      def column_value(item, column)
        if(column[:move_controls])
          ((item == collection.first) ?
            image_tag('uu_gray.png', class: 'button moveTop inactive')+
            image_tag('u_gray.png',  class: 'button moveUp inactive')
          : image_tag('uu.png',      class: 'button moveTop active')+
            image_tag('u.png',       class: 'button moveUp active')
          )+
          ((item == collection.last) ?
            image_tag('d_gray.png',  class: 'button moveDown inactive')+
            image_tag('dd_gray.png', class: 'button moveBottom inactive')
          : image_tag('d.png',       class: 'button moveDown active')+
            image_tag('dd.png',      class: 'button moveBottom active')
          )
        else
          nested_attribute(item, column[:attribute])
        end
      end

      def nested_attribute(object, attribute_path)
        attribute_path && attribute_path.to_s.split('.').inject(object) do |acc, attribute|
          acc && acc.send(attribute)
        end
      end

      def entries
        begin
          if collection
            collection.to_a.inject('') do |acc, item|
              acc << render(partial: 'widgets/catalogs/entry', locals: {
                entry_class: "sortable row #{cycle('even', 'odd')}",
                entry: item,
                data_id: item.send(@data_id),
                checkbox_cell: checkbox_cell(item),
                column_data:
                  columns.map do |column|
                    #FIXME: term color seems too general
                    bg_color = column[:attribute] == 'color' ? "background-color: #{column_value(item, column) || ''};" : '';
                    contents = column[:attribute] == 'color' ? '' : column_value(item, column) || '';
                    css_class = [
                      nested_attribute(item, column[:css_class]),
                      column[:move_controls] ? 'move_controls' : nil
                    ].compact.join(' ')
                    "<td style='#{bg_color}'><div class='#{css_class}' title='#{contents.to_s.tooltipify}' style='width: #{column[:width]-8}px'>#{contents}</div></td>"
      #              if column[:attribute] != "color"
      #                  "<td><div class='#{nested_attribute(item,column[:css_class])||''}' style='width: #{column[:width]-8}px'>#{column_value(item, column).to_s || ''}</div></td>" #truncate(, length: (column[:width]-4) / 6)
      #               else
      #                  "<td bgcolor=#{column_value(item, column).to_s || ''}><div class='#{nested_attribute(item,column[:css_class])||''}' style='width: #{column[:width]}px;' ></div></td>"
      #               end
                  end.join('')
              })
            end
          else
            ''
          end
        rescue => e
#          "hello"
        end
      end

      def filler
        if(collection.empty?)
          filler_text = @empty_msg;
        else
          filler_text = '';
        end

#        num_of_displayed = (collection && collection.to_a.size) || 0
#        filler_height =
#          (limit && (limit - num_of_displayed) > 0) ?
#            (limit - num_of_displayed) * 23 + 3
#          : num_of_displayed == 0 ?
#            20 # need room to display 'No results found.' text
#          : 0
        "<tr><td class='filler' colspan='#{columns.size+1}' style='height: 100%; text-align: center;vertical-align: middle'>#{filler_text}</td></tr>"
      end
    end
  end

