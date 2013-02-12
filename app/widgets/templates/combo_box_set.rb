class Templates::ComboBoxSet < Widget
  attr_reader :attribute_name,
              :combo_boxes,
              :combo_box_class,
              :context,
              :model_object

  def initialize options
    @model_object    = options[:model_object]
    @combo_box_class = options[:combo_box_class]
    @attribute_name  = options[:attribute_name]
    super
    @combo_boxes     = init_combo_boxes
  end

  def init_combo_boxes
    index = 0; out = []
    attrib_values = model_object.send(attribute_name)
    while(index < (attrib_values.size() + 1))
      out.push(combo_box_class.new({
        parent: self,
        context: context,
        model_object: model_object,
        id_number: index
      }))
      index += 1;
    end
    out
  end

  def render_to_string
    %{<div id='#{id}' class='widget'>
        #{combo_boxes.inject('') { |out, combo_box| out << combo_box_row(combo_box) } }
      </div>
    }
  end

  private

  def combo_box_row combo_box
    (combo_box.value || combo_box.id_number == 0 || context.interact_mode.to_s == 'edit') ? # dont show empty rows in browse mode beyond first row
      %{<table class='combo_box_row'><tr>
          <td>#{combo_box.render_to_string}</td>
          #{(context.interact_mode.to_s == 'browse' || combo_box.id_number == 0) ?
            '' : "<td class='remove_button'>X</td>"
          }
        </tr></table>
      }
      :
      ""
  end
end