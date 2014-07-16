# Rails + Yelp

This is a sample Rails application using the Ruby gem. To check it out in action, visit [http://rails-yelp.herokuapp.com/](http://rails-yelp.herokuapp.com/).

## Usage

The key take away here is that you'll want to place an initializer inside of ``config/initializers`` that sets up the keys for the gem.

```
# inside of config/initializers/yelp.rb

Yelp.client.configure do |config|
  config.consumer_key = YOUR_CONSUMER_KEY
  config.consumer_secret = YOUR_CONSUMER_SECRET
  config.token = YOUR_TOKEN
  config.token_secret = YOUR_TOKEN_SECRET
end

```

Now you can use the a pre-initialized client anywhere in the app:

```
# inside of HomeController
# app/controllers/home_controller.rb

class HomeController < ApplicationController
  # ...

  def search
    parameters = { term: params[:term], limit: 16 }
    render json: Yelp.client.search('San Francisco', parameters)
  end
end

```

The client is a singleton so that it's only initialized the first time you call it. The same client is used for every subsequent request made throughout the application.

## Using this example application

This Rails application was made as an example to show an integration with the Yelp gem/API. For the most part it's ready to go to deploy on Heroku but a few things have been changed.

### API Keys

API keys are set and used from environment variables.

#### Yelp

You'll need to register an account and get API keys from the [developer site](http://www.yelp.com/developers/getting_started/api_access).

#### Google Maps

You can get a Google Maps key from the [Google Developer Console](https://console.developers.google.com/). Enable the Geocoding API and Google Maps Javascript API v3 to get the map working.

### ``config/database.yml``

The database file is fairly empty and is set to work with a clean/default PostgreSQL installation. If you're looking to configure it to your system or use a different adapter we recommend looking at the [Ruby on Rails guide to configuring the database](http://edgeguides.rubyonrails.org/configuring.html#configuring-a-database) for more information.

### ``config/secrets.yml``

Every rails application employs a secret key to verify signed cookies. To keep people from using the same secret keys we've removed them here. You should generate new ones with ``rake secret`` before starting development.
