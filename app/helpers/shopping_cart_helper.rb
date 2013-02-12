module ShoppingCartHelper  

  def id_for_shopping_cart
    case "#{request[:controller]}##{request[:action]}"      
      when /^\/taxa/                   then 'viewport_taxa_user_panel_shopping_cart'
      when /^\/otus/                         then 'viewport_otus_user_panel_shopping_cart'
      else 'shopping_cart'
    end
  end

  def mycart_content    
    session.try(:[], :projects).try(:[], @current_project.id).try(:[], :cart) || {}    
  end  

  def display_expander type
    @cart_type_size_array = mycart_content[type].try(:compact) || []
    if  @cart_type_size_array.try(:length) > 0
      "+"
    end
  end  

  def display_header type
    @cart_type_size_array = mycart_content[type].try(:compact)  || []
      if @cart_type_size_array.length > 0
        "<span id='"+type.downcase+"_header'>"+type.capitalize+"("+@cart_type_size_array.length.to_s+")</span>"
      else
        "<span id='"+type.downcase+"_header'></span>"
      end      
  end

  def shopping_cart_lists
    "<span class='empty'>Empty</span>"
  end
  
end
