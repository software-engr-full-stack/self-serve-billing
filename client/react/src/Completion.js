import {useEffect, useState} from 'react';
import { useNavigate } from 'react-router-dom';

function Completion(props) {
  const { stripePromise, transactionResult } = props;
  let navigate = useNavigate();
  const [ messageBody, setMessageBody ] = useState('');

  useEffect(() => {
    if (!stripePromise || !transactionResult) return;

    const { paymentIntentClientSecret } = transactionResult;

    stripePromise.then(async (stripe) => {
      const { error, paymentIntent } = await stripe.retrievePaymentIntent(paymentIntentClientSecret);

      setMessageBody(error ? `> ${error.message}` : (
        <>&gt; Payment {paymentIntent.status}: <a href={`https://dashboard.stripe.com/test/payments/${paymentIntent.id}`} target="_blank" rel="noreferrer">{paymentIntent.id}</a></>
      ));
    });
  }, [transactionResult, stripePromise]);

  if (!stripePromise || !transactionResult) {
    navigate('/');
    return null;
  }

  return (
    <>
      <h1>Thank you!</h1>
      <a href="/">home</a>
      <div id="messages" role="alert" style={messageBody ? {display: 'block'} : {}}>{messageBody}</div>
    </>
  );
}

export default Completion;
