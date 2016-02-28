class RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token

  respond_to :html, :js

  def update
    # Verify if we need to request current password from user
    successfully_updated = if needs_password?(@user, user_params)
      @user.update_with_password(user_params)
    else
      # Remove the virtual current_password
      # attribute update_without_password
      params[:user].delete(:current_password)
      @user.update_without_password(user_params)
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    elsif @user.phone_number_changed?
      @user.generate_pin
      @user.send_pin
      respond_to do |format|
        format.js
      end
    else
      render "edit"
    end
  end

  def verify
    @user.verify(params[:pin])
    respond_to do |format|
      format.js
    end
  end

  def render_twiml(response)
    render text: response.text, :content_type => "text/xml"
  end

  def process_sms
    @body = params[:Body]

    twiml = Twilio::TwiML::Response.new do |r|
      if @body == "Yes"
        charge = Stripe::Charge.create(
          customer: "cus_7vySlDB3BvnO6C",
          amount: 1999,
          description: 'Text bro customer',
          currency: 'usd',
          card: "card_17g6VqGqUdrxDDBSJ9do2gk3"
        )
        r.Message "Your order has been received :)"
      else
        r.Message "Maybe next time. Have a great day"
      end
    end
    render_twiml(twiml)
  end

  private

  def needs_password?(user, user_params)
    # Verify if email changed
    user.email != params[:user][:email] ||
        # Verify if the password has been informed
        params[:user][:password].present?
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :phone_number, :first_name, :last_name, :image)
  end
end 