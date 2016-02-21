class ChargesController < ApplicationController
  def new
  end

  def create
    # Amount in cents
    @amount = 699

    token = params[:stripeToken]

    customer = Stripe::Customer.create(
      email: params[:stripeEmail],
      card: token
    )

    charge = Stripe::Charge.create(
      customer: customer.id,
      amount: @amount,
      description: 'Twilio customer',
      currency: 'usd'
    )

    save_stripe_customer_id(user, customer.id)

    customer_id = get_stripe_customer_id(user)

    Stripe::Charge.create(
      amount: 1500,
      currency: 'usd',
      customer: customer_id
    )

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_charge_path
  end
end
