require 'stripe'

def find_customer_by_email(email)
  result = Stripe::Customer.search({
    query: "email:'#{email}'"
  })

  data = result['data']

  raise "... ERROR: email '#{email}' not unique, '#{data.count}' found" if data.count > 1

  return data.first if data.count == 1

  return
end

def wait_until_present(max_loop: 20, delay: 2, delay_after_presence: 0)
  raise '... ERROR: must provide block' if !block_given?

  current = 0
  puts
  loop do
    presence = yield
    if presence
      sleep(delay_after_presence * delay)
      return presence
    end

    current += 1
    raise '... ERROR: max loop reached' if current > max_loop

    print '.'

    sleep delay
  end
  puts
end
