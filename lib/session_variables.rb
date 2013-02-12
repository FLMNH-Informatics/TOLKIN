class SessionVariables

  class << self
    def for_session_and_project session, project
      self.new(session, project)
    end
  end

  def cart
    @session_vars[:project][@project.id][:cart]
  end

  def current_selection
    @session_vars[:project][@project.id][:current_selection]
  end

  protected

  def initialize session, project
    fail "project necessary" unless project
    @session_vars = session["project_#{project.id}"]
  end

end
