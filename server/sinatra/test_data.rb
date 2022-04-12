def test_product
  price = 99
  currency_symbol = '$'
  {
    currency_symbol:,
    currency: 'USD',
    price: price * 100,
    title: 'Professional',
    description: 'Advanced features to drive conversions',
    subscription_terms: "#{currency_symbol} #{price}/Month"
  }
end
