class ManagerMailer < ActionMailer::Base
  def new_user_request_notification(user, manager, project)
    setup_email(user, manager)
    @subject    += "New user request for your project: #{project.name}."
    @body[:project_name] = project.name
    @body[:new_user] = user
    @body[:url]  = "http://#{SITE_NAME}/users/#{user.id}/granted_roles"
    #project.
  end
  protected
  def setup_email(user, manager)
    @recipients  = "#{manager.email}"
    @from        = ADMINEMAIL
    @subject     = "[#{SITE_NAME}]"#"[YOURSITE] "
    @sent_on     = Time.now
    @body[:user] = manager
  end
end
