class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Thanks for signing up with Tolkin'
    @body[:url]  = "http://#{SITE_NAME}/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{SITE_NAME}/"
  end
  
   def forgot_password(user)
     setup_email(user)
     @subject    += 'You have requested to change your password'
     @body[:url]  = "http://#{SITE_NAME}/reset_password/#{user.password_reset_code}"
   end
  
   def reset_password(user)
     setup_email(user)
     @subject    += 'Your password has been reset.'
   end

   def project_request_accepted_notification(project_user_request)
     setup_email(project_user_request.user)
     @subject    += "Your request for project #{project_user_request.project.name.capitalize} is accepted."
     @body[:project] = project_user_request.project
     @body[:url]  = "http://#{SITE_NAME}/"
   end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = ADMINEMAIL
      @subject     = "[#{SITE_NAME}]"#"[YOURSITE] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
