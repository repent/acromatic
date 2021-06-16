source 'https://rubygems.org'

ruby '3.0.3'

####################################################################################################
# Rails
####################################################################################################

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# ruby 2.4 combines bignum and fixnum into integer, which breaks lots of stuff in rails <4.2.8
gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
#gem 'mysql2'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# After 2.1.0, sassc requires binaries to be compiled on the server; colin ran out of memory doing
# this
# https://github.com/sass/sassc-ruby/issues/189
# https://github.com/sass/sassc-ruby/issues/204
gem 'sassc', '= 2.1.0'

# New in 6:
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# No longer used in Rails 6.0, may not be necessary:

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', group: :doc

####################################################################################################
# App specific
####################################################################################################

# fuck erb
gem 'haml'

# handle document uploads
gem 'carrierwave'

# markdown
gem 'redcarpet'

# all the document formats
gem 'pandoc-ruby'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

gem 'pry'
gem 'pry-rails'
# gem 'rmagick'

# This is currently required by carrierwave; it might be removable
# gem 'mini_magick'

# User authentication
gem 'devise'

# Use a daemon to delete old documents
# gem 'daemons'

####################################################################################################
# Mixture
####################################################################################################

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background.
  # Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'erb2haml'
  gem 'awesome_print'

  # Adds detail on the database schema to the top of model descriptions
  # Usage: annotate
  gem 'annotate_models'
  #gem 'annotate_rails'

  # Use Capistrano for deployment
  #gem 'capistrano-rails'
  #gem 'capistrano-rbenv'
  #gem 'capistrano-bundler'
  #gem 'capistrano-passenger'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
