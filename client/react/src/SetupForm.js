// customer@example.com
// 3782 822463 10005

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { CardElement } from '@stripe/react-stripe-js';
import { useStripe, useElements } from '@stripe/react-stripe-js';
import humps from 'humps';

export default function SetupForm(props) {
  const { clientSecret, customer, product, setTransactionResult } = props;
  let navigate = useNavigate();

  const stripe = useStripe();
  const elements = useElements();
  const [message, setMessage] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (evt) => {
    evt.preventDefault();

    if (!stripe || !elements) {
      // Stripe.js has not yet loaded.
      // Make sure to disable form submission until Stripe.js has loaded.
      return;
    }

    setIsLoading(true);

    // Get a reference to a mounted CardElement. Elements knows how
    // to find your CardElement because there can only ever be one of
    // each type of element.
    const card = elements.getElement(CardElement);

    if (card == null) {
      return;
    }

    const { email } = customer;
    stripe
      .confirmCardSetup(clientSecret, {
        payment_method: {
          card: card,
          billing_details: { email }
        }
      })
      .then(function(result) {
        if (result.error) {
          setMessage(result.error.message);
          console.error(result.error.message, result.error);
          throw Error('...');
        } else {
          const { setupIntent } = result;

          fetch('/create-payment-intent', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              payment_method: setupIntent.payment_method,
              product,
              customer
            })
          })
            .then((res) => res.json())
            .then((data) => {
              const { paymentIntent } = humps.camelizeKeys(data);
              setTransactionResult({
                paymentIntentClientSecret: paymentIntent.clientSecret
              });
              navigate('/completion');
            })
        }
      });

    setIsLoading(false);
  };

  return (
    <>
      <CardElement
        className="sr-input sr-element sr-card-element"
        id="payment-element"
        options={{
          style: {
            base: {
              fontSize: '16px',
              color: '#424770',
              '::placeholder': {
                color: '#aab7c4',
              },
            },
            invalid: {
              color: '#9e2146',
            },
          },
        }}
      />
      <button disabled={isLoading || !stripe || !elements} id="submit" onClick={handleSubmit}>
        <span id="button-text">
          {isLoading ? <div className="spinner" id="spinner"></div> : "Please enter your payment information"}
        </span>
      </button>
      {/* Show any error or success messages */}
      {message && <div id="payment-message">{message}</div>}
    </>
  );
}
