class PhoneNumbersController < ApplicationController
  skip_before_action :verify_authenticity_token
  def new
    @phone_number = PhoneNumber.new
  end

  def create
    @phone_number = PhoneNumber.create(phone_number: params[:phone_number][:phone_number])
    @phone_number.generate_pin
    @phone_number.send_pin
    respond_to do |format|
      format.js
    end
  end

  def verify
    @phone_number = PhoneNumber.find_by(phone_number: params[:hidden_phone_number])
    @phone_number.verify(params[:pin])
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
end
