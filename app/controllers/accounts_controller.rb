class AccountsController < ApplicationController

  before_filter :requires_logged_in, :only => [:show, :edit, :update]

  #TODO change name of this function to be more descriptive
   # Activate action
   def show
     # Uncomment and change paths to have user logged in after activation - not recommended
     #self.current_user = User.find_and_activate!(params[:id])
   User.find_and_activate!(params[:id])
     flash[:notice] = "Your account has been activated! You can now login."
     redirect_to login_path
   rescue User::ArgumentError
     flash[:notice] = 'Activation code not found. Please try creating a new account.'
     redirect_to new_user_path
   rescue User::ActivationCodeNotFound
     flash[:notice] = 'Activation code not found. Please try creating a new account.'
     redirect_to new_user_path
   rescue User::AlreadyActivated
     flash[:notice] = 'Your account has already been activated. You can log in below.'
     redirect_to login_path
   end

   def edit
     if is_admin? && params[:user_id]
       @user = User.find(params[:user_id])
     else
       @user = current_user
     end
   end

   # Change password action
   def update
  # return unless request.post?

    @user = admin_passkey.unlock(User).find(params[:user_id])
    
    # user authenticates if they have right old login and password, or if they are an admin and are not changing their own password
     if User.authenticate(current_user.username, params[:old_password]) || (is_admin? && params[:user_id] != current_user.id.to_s)
       if ((params[:new_password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
         @user.password_confirmation = params[:password_confirmation]
         @user.unencrypted_password = params[:new_password]
      
         if @user.save(:validate => false)
           flash[:notice] = "Password successfully updated."
           render :action => 'edit'
           #redirect_to root_path #profile_url(current_user.login)
         else
           flash[:error] = "An error occured, your password was not changed."
           render :action => 'edit'
         end
       else
         flash[:error] = "New password does not match the password confirmation."
         @old_password = params[:old_password]
         render :action => 'edit'
       end
     else
       flash[:error] = "Your old password is incorrect."
       render :action => 'edit'
     end
   rescue => e
     debugger
     'hello'
   end
end
