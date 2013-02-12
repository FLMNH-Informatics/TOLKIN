module ProjectsHelper
  def zero_projects_message
    if @projects.size.zero?
      out_str = raw "<tr><td colspan ='3'>No projects are available for public view at this time.</td></tr>"
    else
      out_str = ""
    end
    out_str
  end
  # open modeable form field maker
  def input_field(obj,attr, tag, val=nil, options={})
    out=''

    if session['projects'][params[:id].to_i][:interact_mode] == 'edit'
      op = options.map{|k,v| "#{k}=\"#{v}\""}.join(' ')  || ''

      #val = val == nil ? 'None' : val
      case tag
        when 'text'
          out = '<input id="'+ obj + '_' + attr + '" type="text" value="' + val + '" name="' + obj +"["+ attr +"]\" #{op} />"

        when 'textarea'
          out = '<textarea id="'+ obj + '_' + attr +'" name="' + obj +"["+ attr +"]\" #{op}>"  + val + '</textarea>'
      end
    else
      val = val.blank? ? 'none' : val
      out = "<p><em>#{val}</em></p>"
    end
    raw out
  end

  def nilify obj
    obj.nil? ? '' : obj
  end

end
