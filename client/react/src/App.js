import React, {useEffect, useState} from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { loadStripe } from '@stripe/stripe-js';
import humps from 'humps';

import './css/normalize.css';
import './css/global.css';
// import './App.css';

import Product from './Product';
import AccountDetails from './AccountDetails';
import Setup from './Setup';
import Completion from './Completion';

function App() {
  const [stripePromise, setStripePromise] = useState(null);
  const [product, setProduct] = useState();

  const defaultClientSecret = ''
  const [clientSecret, setClientSecret] = useState(defaultClientSecret);

  const [customer, setCustomer] = useState();

  const [transactionResult, setTransactionResult] = useState();

  useEffect(() => {
    fetch('/public-key').then(async (response) => {
      const { publicKey } = await response.json();
      setStripePromise(loadStripe(publicKey));
    });
  }, []);

  useEffect(() => {
    fetch('/product').then(async (response) => {
      setProduct(humps.camelizeKeys(await response.json()));
    });
  }, [setProduct]);

  return (
    <main className="sr-main">
      <BrowserRouter>
        <Routes>
          <Route
            path="/"
            element={<Product product={product} setProduct={setProduct} />}
          />

          <Route
            path="/account"
            element={<AccountDetails setClientSecret={setClientSecret} setCustomer={setCustomer} />}
          />

          <Route
            path="/setup"
            element={
              <Setup
                stripePromise={stripePromise}
                clientSecret={clientSecret}
                customer={customer}
                product={product}
                setTransactionResult={setTransactionResult}
              />
            }
          />

          <Route
            path="/completion"
            element={
              <Completion
                stripePromise={stripePromise}
                transactionResult={transactionResult}
              />
            }
          />
        </Routes>
      </BrowserRouter>
    </main>
  );
}

export default App;
