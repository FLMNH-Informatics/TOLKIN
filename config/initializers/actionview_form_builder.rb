class ActionView::Helpers::FormBuilder
  
  def date_field(method, options = {})
    @template.date_field(@object, method, { form_builder: self })#objectify_options(options));
  end
  
  def text_field(method, options = {})
    if(@template.interact_mode == 'browse') #options[:interact_mode] &&
       "<span style='color:#333;'>#{@object.send(method)}</span>"
    else
      @template.send(
        "text_field",
        @object_name,
        method,
        objectify_options(options)
      )
    end
  end

  def auto_complete_field(method, options = {})
    @template.auto_complete_field(@object, method, options)
  end

  def file_field(method, options = {})
    params = @template.controller.env['action_dispatch.request.parameters']
    if(@template.interact_mode == 'browse' && !(params['action'] == 'show' && params['controller'] == 'morphology/characters')) #options[:interact_mode] &&
      ""
    else
      @template.send(
        "file_field",
        @object_name,
        method,
        objectify_options(options)
      )
    end
  end

  def form_submit_button(options = {})
    if(@template.interact_mode == 'browse')
      ""
    else
      val = options[:value] || 'Save'
      "<input type='button' value='#{val}' />"
    end
  end
  
end

#module ActionView::Helpers::FormHelper
#  def date_field(object_name, method, options = {})
#    object_name.send(method).to_s =~ /(\d{4})\-(\d{2})\-(\d{2})/
#    split_date = { Y: $1, mm: $2, dd: $3}
#    def split_date.Y
#      return self[:Y]
#    end
#
#    def split_date.mm
#      return self[:mm]
#    end
#
#    def split_date.dd
#      return self[:dd]
#    end
#
#    object_name = ActionController::RecordIdentifier.singular_class_name(object_name)
#    temp=object_name.split('_')
#    temp.slice!(0)
#    object=""
#    n=temp.length-1
#    for i in 0..n
#      object+=temp.slice!(0)
#      if(i!=n)
#        object+="_"
#      end
#    end
#    render :partial => 'forms/date_field', :locals => {
#      :object_name => object,
#      :attribute_name => method,
#      :date => split_date
#    }
#  end
#end