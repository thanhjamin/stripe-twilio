class PhoneNumber < ActiveRecord::Base
  def generate_pin
    self.pin = rand(0000..9999).to_s.rjust(4, "0")
    save
  end

  def twilio_client
    Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
  end

  def send_pin
    twilio_client.messages.create(
      to: phone_number,
      from: ENV['TWILIO_PHONE_NUMBER'],
      body: "Your PIN is #{pin}",
      media_url: "http://www.toyhalloffame.org/sites/www.toyhalloffame.org/files/toys/square/rubber-duck_0.jpg"
    )
  end

  def verify(entered_pin)
    update(verified: true) if self.pin == entered_pin
  end

  def charge(customer_id, card_id)
    # Amount in cents

    Stripe::Charge.create(
      amount: 1500,
      currency: 'usd',
      customer: customer_id,
      card: card_id
    )

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_charge_path
  end
end
