require 'stripe'
require 'sinatra'
require 'dotenv'
require 'json'

require_relative './config_helper'
require_relative './lib'
require_relative './test_data'

Dotenv.load
ConfigHelper.check_env!
# For sample support and debugging, not required for production:
Stripe.set_app_info(
  'stripe',
  version: '0.0.1',
  url: 'https://github.com/???/???'
)
Stripe.api_version = '2020-08-27'
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

set :static, true
set :port, 4242

# # For React build
# set :public_folder, File.join(File.dirname(__FILE__), ENV['STATIC_DIR'])

# get '/' do
#   content_type 'text/html'
#   send_file File.join(settings.public_folder, 'index.html')
# end

get '/public-key' do
  content_type 'application/json'

  {
    publicKey: ENV['STRIPE_PUBLISHABLE_KEY']
  }.to_json
end

get '/product' do
  content_type 'application/json'

  test_product.to_json
end

post '/create-payment-intent' do
  payload = JSON.parse request.body.read

  payment_method = payload['payment_method']

  customer = payload['customer']
  product = payload['product']

  if !payment_method || payment_method.strip.empty?
    raise '... ERROR: payment_method must not be blank'
  end

  raise '... ERROR: product must not be blank' if !product

  raise '... ERROR: customer must not be blank' if !customer

  # Create a PaymentIntent with the amount, currency, and a payment method type.
  #
  # See the documentation [0] for the full list of supported parameters.
  #
  # [0] https://stripe.com/docs/api/payment_intents/create
  begin
    payment_intent = Stripe::PaymentIntent.create({
      payment_method:,
      amount: product['price'],
      currency: product['currency'],
      confirm: true,
      automatic_payment_methods: { enabled: true }, # Configure payment methods in the dashboard.
      return_url: 'http://localhost:3000', # ""You must provide a `return_url` when confirming using automatic_payment_methods[enabled]=true." # rubocop:disable Layout/LineLength

      # "The `payment_method` parameter supplied pm_1KndeVCRXSf6mceMIOTXpFtO belongs to the
      #  Customer cus_LUWSHqUKpE0ymu. Please include the Customer in the `customer` parameter
      #  on the PaymentIntent.""
      customer: customer['id'],

      metadata: {
        email: customer['email']
      },
      receipt_email: customer['email']
    })
  rescue Stripe::StripeError => e
    halt(
      400,
      { 'Content-Type' => 'application/json' },
      { error: { message: e.error.message } }.to_json
    )
  rescue => e
    halt(
      500,
      { 'Content-Type' => 'application/json' },
      { error: { message: e.error.message } }.to_json
    )
  end

  # # This API endpoint renders back JSON with the client_secret for the payment
  # # intent so that the payment can be confirmed on the front end. Once payment
  # # is successful, fulfillment is done in the /webhook handler below.
  # {
  #   clientSecret: payment_intent.client_secret,
  # }.to_json

  { payment_intent: }.to_json
end

post '/create-setup-intent' do
  content_type 'application/json'

  payload = JSON.parse request.body.read

  email = payload['email']

  raise '... ERROR: email must not be blank' if !email || email.strip.empty?

  customer_obj = find_customer_by_email email

  if customer_obj.nil?
    customer_obj = Stripe::Customer.create(payload)

    wait_until_present do
      find_customer_by_email email
    end
  end

  setup_intent = Stripe::SetupIntent.create(
    customer: customer_obj['id']
  )

  {
    setup_intent:,
    customer: customer_obj
  }.to_json
end

post '/webhook' do
  # You can use webhooks to receive information about asynchronous payment events.
  # For more about our webhook events check out https://stripe.com/docs/webhooks.
  webhook_secret = ENV['STRIPE_WEBHOOK_SECRET']
  payload = request.body.read
  if !webhook_secret.empty?
    # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, webhook_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      puts '⚠️  Webhook signature verification failed.'
      status 400
      return
    end
  else
    data = JSON.parse(payload, symbolize_names: true)
    event = Stripe::Event.construct_from(data)
  end
  # Get the type of webhook event sent - used to check the status of SetupIntents.
  event_type = event['type']
  data = event['data']
  data_object = data['object']

  if event_type == 'setup_intent.created'
    puts '🔔 A new SetupIntent was created.'
  end

  if event_type == 'setup_intent.setup_failed'
    puts '🔔  A SetupIntent has failed the attempt to set up a PaymentMethod.'
  end

  if event_type == 'setup_intent.succeeded'
    puts '🔔 A SetupIntent has successfully set up a PaymentMethod for future use.'
  end

  if event_type == 'payment_method.attached'
    puts '🔔 A PaymentMethod has successfully been saved to a Customer.'

    # At this point, associate the ID of the Customer object with your
    # own internal representation of a customer, if you have one.

    # Optional: update the Customer billing information with billing details from the PaymentMethod
    customer = Stripe::Customer.update(
      data_object['customer'],
      email: data_object['billing_details']['email']
    )

    puts "🔔 Customer #{customer['id']} successfully updated."

    # You can also attach a PaymentMethod to an existing Customer
    # https://stripe.com/docs/api/payment_methods/attach
  end

  content_type 'application/json'
  {
    status: 'success'
  }.to_json
end
