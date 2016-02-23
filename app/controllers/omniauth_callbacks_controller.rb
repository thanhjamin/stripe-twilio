class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook 
    user = User.from_omniauth(request.env["omniauth.auth"])   
    if user.persisted?
      flash.notice = "#{user.email}, you are signed in!"
      sign_in_and_redirect user, notice: "#{user.email}, you are signed in!"
    else
      flash.notice = "We're sorry, there was an error signing you in."
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

end