# data structure used to store and modify state info for the current
# and past user sessions in the process of performing a workflow
class Sessions::ParameterStack < Array

  def last_location(controller)
    URI.split(controller.url_for(last_parameters))[5] # returns only path fragment of url generated
  end

  def add_to_last(extra_params)
    last_parameters.merge! extra_params
  end

  private

  def last_parameters
    self.last
  end
  
end