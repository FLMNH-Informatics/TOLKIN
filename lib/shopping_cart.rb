class ShoppingCart
  def initialize session
    @session = session
  end

  def push object
    #@session[:project][project_id][:cart][object.id] = { object.class, object.id, object.label }
  end

end