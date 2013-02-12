module WidgetsHelper
  def catalog id, entries, columns, options = {}
      options = { filters: true }.merge!(options)
      limit = options[:limit] || 20
      start = 0
      count = options[:count] || entries.size
      ending = (limit > count) ? count - 1 : limit - 1;
      entries = entries[start, limit]
      entries_html = entries.inject('') do |concat, list_item|
        concat + render(:partial => 'widgets/catalogs/entry', :locals => {
            :entry_class => cycle('even', 'odd'),
            :entry => list_item,
            :pseudo_attr => options[:pseudo_attr] || 'id', #hack to accomodate the matrices branches which have branch id as well as matrix version id required for deletion and show matrix respectively
            :column_data => columns.map {|column|
              
              if column[:attribute] != "color"
                  "<td style='width: #{column[:width]}px'>#{nested_attribute(list_item, column)}</td>"
              else                
                  "<td style='width: #{column[:width]}px;' bgcolor=#{nested_attribute(list_item, column)} class='color_code'></td>"
              end
            }.join('')
          })
      end
      out = #(entries_html == '') ? "<span class='empty'>None</span>" :
        render(:partial => 'widgets/catalog', :locals => {
          :id => id,
          :column_headings => columns.map { |column|
            "<th data-id='#{column[:attribute]}' style='width: #{column[:width]}px'>#{(column[:label] || column[:attribute].gsub(/_/, " ").capitalize)}</th>"
          }.join(''),
          :filters => render(:partial => 'filters/form', :locals => { :parent_id => parent_id }),
          :entries => entries_html,
          :start_index => start + 1,
          :end_index => ending + 1,
          :count => count,
          :nav_style => "width: #{columns.inject(51 + 2*columns.size) { |sum, column| sum + column[:width] }}px",
          :nav_colspan => columns.size + 1,
          :left_inactive => 'inactive',
          :right_inactive => (count > ending + 1) ? '' : 'inactive'
        })
    out
  end
  
  private
  def catalog_filters(parent_id)
    render(:partial => 'filters/form', :locals => { :parent_id => parent_id })
  end
  
  def nested_attribute(object, column)         
        column[:attribute].split('.').each do |attribute|          
          object = object.try(:send, attribute)          
        end        
        column[:map] ? object.map { |o| o.send(column[:map]) }.join(',') : object
     
  end
end
