# Stripe integration demo

Server: Ruby Sinatra

Client: React

### Usage

1. Clone this repo

2. `cd` into clone repo

3. Create a file called `server/sinatra/.env`. The contents look like this. Replace the keys, secrets, etc. with your own values for those fields:
  ```
    STRIPE_PUBLISHABLE_KEY=REPLACE-WITH-YOUR-STRIPE-PUBLISHABLE-KEY
    STRIPE_SECRET_KEY=REPLACE-WITH-YOUR-STRIPE-PUBLISHABLE-KEY

    # See https://stripe.com/docs/webhooks
    STRIPE_WEBHOOK_SECRET=REPLACE-WITH-WEBHOOK-SECRET

    STRIPE_API_VERSION=2020-08-27
  ```

4. Run the server. This will run in the foreground.

    `( cd server/sinatra && ruby server.rb )`

5. Run the client. This will run in the foreground.

    `( cd client/react && npm start )`

    If you don't want the React dev env to open a browser:
    `( cd client/react && BROWSER=none npm start )`

6. Optional: Run the webhook. You need to install the `stripe` CLI.

    `stripe listen --forward-to localhost:4242/webhook`

7. Open your browser to `http://localhost:3000/` then click "Buy" and follow the rest of the instructions shown.

### Customer creation

In the "Please enter account details" page, when you enter an email address and press "OK", it will create a Stripe customer if the customer with the entered email does not exist yet on your Stripe account. Please wait for about 20 seconds before proceeding. It takes about this duration for Stripe to create a customer. (More specifically, it takes about this duration for the Stripe customer search interface to find the customer that you just created.) If you repeatedly hit "OK", Stripe will create multiple customers with the same email.

### Test data for convenience

customer@example.com

Test credit card number

3782 822463 10005

More test credit card numbers here: https://stripe.com/docs/testing?numbers-or-method-or-token=card-numbers#visa
