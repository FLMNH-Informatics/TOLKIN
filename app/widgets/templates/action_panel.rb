module Templates
  class ActionPanel < Widget

    attr_reader :buttons

    def initialize options
      @buttons ||= options[:buttons] || fail('no buttons provided')
      super
    end

    def count_num
    end

    def to_s
      buttons_html = buttons.inject('') do |out, button_obj|
        if !button_obj[:imode] || [*button_obj[:imode]].include?(interact_mode)
#          button instead of tables&spans
          button_tag = %{<input type="button" value="#{button_obj[:label]}" #{button_obj[:img] ? %{ class="button_img" style="background-image: url(#{button_obj[:img][:src]});"} : ''} />}
          "#{out}#{button_tag}"
#          button_tag = %{
#            <table><tr>
#              <td>
#                #{(button_obj[:img] ? "<img style='height: 14px; width: 14px;' src='#{button_obj[:img][:src]}' />" : '')}
#              </td>
#              <td>
#                <span class='label'>#{button_obj[:label]}</span>
#              </td>
#            </tr></table>
#          }
#          "#{out}<div class='button'>#{button_tag}</div>"
        else
          out
        end
      end
      %{<div id='#{id}' class='widget action_panel bar' #{ buttons_html.blank? ? "style='display:none'": ''}>
          #{buttons_html}
          <span id="selected_tools" class="selected_tools"></span>
          <span class="selected_count"></span>
        </div>  }
      end
    end
  end