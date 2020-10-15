source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# ruby 2.4 combines bignum and fixnum into integer, which breaks lots of stuff in rails <4.2.8
gem 'rails', '~> 4.2.11.1'
# Dependendency of rails; vulnerability in 2.1.3
#gem 'rack', '~> 2.1.4'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.13'
#gem 'mysql2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# fuck erb
gem 'haml'

# handle document uploads
gem 'carrierwave'

# markdown
gem 'redcarpet'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

gem 'pry'
gem 'pry-rails'
# gem 'rmagick'
gem 'mini_magick'

# User authentication
gem 'devise'

# Use a daemon to delete old documents
gem 'daemons', '~> 1.2.6'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'erb2haml'
  gem 'awesome_print'

  # Adds detail on the database schema to the top of model descriptions
  # Usage: annotate
  #gem 'annotate'
  gem 'annotate_rails'

  # Use Capistrano for deployment
  #gem 'capistrano-rails'
  #gem 'capistrano-rbenv'
  #gem 'capistrano-bundler'
  #gem 'capistrano-passenger'
end
