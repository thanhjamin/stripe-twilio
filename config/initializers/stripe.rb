Rails.configuration.stripe = {
  stripe_publishable_key: Rails.application.secrets.stripe_publishable_key,
  stripe_secret_key: Rails.application.secrets.stripe_secret_key
}

Stripe.api_key = Rails.application.secrets.stripe_secret_key

