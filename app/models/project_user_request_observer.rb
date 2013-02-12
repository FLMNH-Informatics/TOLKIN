class ProjectUserRequestObserver < ActiveRecord::Observer
  def after_create(project_request)
    project = Project.find(project_request.project_id)
    project.managers.each do |manager|
      ManagerMailer.deliver_new_user_request_notification(project_request.user, manager, project)
    end
  end

  def after_save(project_user_request)
    UserMailer.deliver_project_request_accepted_notification(project_user_request) if(project_user_request.status == ProjectUserRequest.complete)
  end
end
