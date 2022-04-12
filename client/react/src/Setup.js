import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Elements } from '@stripe/react-stripe-js';

import SetupForm from './SetupForm';

function Setup(props) {
  const {
    stripePromise,
    product,
    clientSecret,
    customer,
    setTransactionResult
  } = props;

  let navigate = useNavigate();

  if (!clientSecret || clientSecret.trim() === '') {
    navigate('/');
    return null;
  }

  return (
    <div className="sr-payment-form card">
      <div className="sr-form-row">
        You are about to buy "{product.title}" subscription for {product.subscriptionTerms}.
      </div>

      <div className="sr-form-row">
        <label>
          Payment details
        </label>
        {clientSecret && stripePromise && (
          <Elements
            stripe={stripePromise}
            options={{ clientSecret }}
          >
            <SetupForm
              clientSecret={clientSecret}
              customer={customer}
              product={product}
              setTransactionResult={setTransactionResult}
            />
          </Elements>
        )}
      </div>
    </div>
  );
}

export default Setup;
