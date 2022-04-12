import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import humps from 'humps';
import testCustomer from './testData';

function isInvalidEmail(email) {
  if (!email || email.trim() === '') {
    return true
  }

  if (email.indexOf('@') === -1) {
    return true
  }

  const userAndDomain = email.split('@');
  if (userAndDomain[0].trim() === '' || userAndDomain[1].trim() === '') {
    return true
  }

  return false;
}

export default function AccountDetails(props) {
  const { setClientSecret, setCustomer } = props;

  let navigate = useNavigate();
  const [email, setEmail] = useState('');

  const [inputError, setInputError] = useState();

  const handleChangeEmail = (evt) => {
    setInputError();
    setEmail(evt.target.value);
  };

  const handleSubmitEmail = (evt) => {
    evt.preventDefault();

    if (isInvalidEmail(email)) {
      setInputError('Please enter valid email.');
      return;
    }

    fetch('/create-setup-intent', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...testCustomer,
        email
      })
    })
      .then((res) => res.json())
      .then((data) => {
        const { setupIntent, customer } = humps.camelizeKeys(data);

        // TODO: validate
        setClientSecret(setupIntent.clientSecret);
        setCustomer(customer);

        navigate('/setup');
      })
  };

  const isLoading = false;

  return (
    <div className="sr-payment-form card">
      <div className="sr-form-row">
        <label>
          Please enter account details
        </label>
        <input
          value={email}
          onChange={handleChangeEmail}
          id="email"
          type="text"
          placeholder="Email address"
        />
      </div>

      <button disabled={isLoading} id="submit" onClick={handleSubmitEmail}>
        <span id="button-text">
          {isLoading ? <div className="spinner" id="spinner"></div> : 'OK'}
        </span>
      </button>

      {
        inputError && <div className="error">ERROR: {inputError}</div>
      }
    </div>
  );
}
