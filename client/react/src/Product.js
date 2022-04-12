import React from 'react';
import { useNavigate } from 'react-router-dom';

export default function Product(props) {
  const { product } = props;
  let navigate = useNavigate();

  if (!product) return <div>Loading...</div>;

  const handleBuy = (evt) => {
    evt.preventDefault();
    navigate('/account');
  };

  const isLoading = false;

  return (
    <>
      <h2>{product.title}</h2>
      <h4>{product.description}</h4>
      Starts at<h2>{product.subscriptionTerms}</h2>

      <button id="submit" onClick={handleBuy}>
        <span id="button-text">
          {isLoading ? <div className="spinner" id="spinner"></div> : 'Buy'}
        </span>
      </button>
    </>
  );
}
