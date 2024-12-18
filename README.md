# Kosmo Ruby Client

A Ruby gem for interacting with the Kosmo Delivery API. This gem provides a simple and intuitive interface for managing delivery orders and quotes through Kosmo's delivery platform in Singapore.

## Features

- **Quote Management**: Get instant delivery quotes based on pickup and dropoff locations
- **Order Management**: Create, retrieve, and list delivery orders
- **Error Handling**: Comprehensive error handling with specific error classes
- **Authentication**: Secure API authentication using API keys
- **Location Support**: Full support for Singapore addresses with geocoding

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kosmo-ruby'
```

And then execute:

    $ bundle install

Or install it directly using:

    $ gem install kosmo-ruby

## Configuration

Set your Kosmo API key as an environment variable:

    export KOSMO_API_KEY=your_api_key_here

Or configure it in your application:

```ruby
client = Kosmo::Client.new(ENV['KOSMO_API_KEY'])
```

## Usage

### Creating a Client

```ruby
require 'kosmo'

client = Kosmo::Client.new(ENV['KOSMO_API_KEY'])
```

### Getting Delivery Quotes

```ruby
quote_params = {
  pickup: {
    location: {
      address: "313 Orchard Road, Singapore 238895",
      latitude: 1.3021,
      longitude: 103.8368,
      country: "SG"
    },
    sender: {
      fullname: "John Tan",
      phone: "+6591234567",
      email: "john.tan@example.com"
    }
  },
  dropoffs: [
    {
      location: {
        address: "18 Marina Gardens Drive, Singapore 018953",
        latitude: 1.2819,
        longitude: 103.8636,
        country: "SG"
      },
      receiver: {
        fullname: "Mary Lim",
        phone: "+6592345678",
        email: "mary.lim@example.com"
      }
    }
  ],
  items: [
    {
      name: "Singapore Sling",
      quantity: 2,
      price: 15.00
    }
  ],
  delivery_type: "ASAP"
}

quotes = client.create_quotes(quote_params)
```

### Creating a Delivery Order

```ruby
order_params = {
  customer: {
    name: "John Tan",
    phone: "+6591234567",
    email: "john.tan@example.com"
  },
  pickup: {
    location: {
      address: "313 Orchard Road, Singapore 238895",
      latitude: 1.3021,
      longitude: 103.8368,
      country: "SG"
    },
    sender: {
      fullname: "John Tan",
      phone: "+6591234567",
      email: "john.tan@example.com"
    }
  },
  dropoffs: [
    {
      location: {
        address: "18 Marina Gardens Drive, Singapore 018953",
        latitude: 1.2819,
        longitude: 103.8636,
        country: "SG"
      },
      receiver: {
        fullname: "Mary Lim",
        phone: "+6592345678",
        email: "mary.lim@example.com"
      }
    }
  ],
  items: [
    {
      name: "Singapore Sling",
      quantity: 2,
      price: 15.00
    }
  ],
  delivery_type: "ASAP"
}

order = client.create_order(order_params)
```

### Retrieving an Order

```ruby
order = client.get_order("order_id")
```

### Listing Orders

```ruby
# List all orders
orders = client.list_orders

# List with filters
orders = client.list_orders(limit: 5, status: "completed")
```

## Error Handling

The gem provides specific error classes for different types of API errors:

- `Kosmo::BadRequestError`: Invalid request parameters (400)
- `Kosmo::UnauthorizedError`: Invalid or missing API key (401)
- `Kosmo::ForbiddenError`: Insufficient permissions (403)
- `Kosmo::NotFoundError`: Resource not found (404)
- `Kosmo::RateLimitError`: API rate limit exceeded (429)
- `Kosmo::ServerError`: Kosmo API server error (500-599)
- `Kosmo::ApiError`: Generic API error

Example error handling:

```ruby
begin
  client.get_order("non_existent_id")
rescue Kosmo::NotFoundError => e
  puts "Order not found: #{e.message}"
rescue Kosmo::UnauthorizedError => e
  puts "Authentication failed: #{e.message}"
rescue Kosmo::ApiError => e
  puts "API error: #{e.message}"
end
```

## API Documentation

For detailed information about the Kosmo API endpoints and parameters, please refer to the [official Kosmo API documentation](https://api.kosmo.delivery/docs).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wafiq/kosmo-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/wafiq/kosmo-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kosmo project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/wafiq/kosmo-ruby/blob/main/CODE_OF_CONDUCT.md).
