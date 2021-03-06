source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.3'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
group :production do
  gem 'mysql2'
  gem 'daemons'
  gem 'exception_notification'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

######## CUSTOM ######
gem 'devise'
gem 'whenever', :require => false
gem 'slim-rails'
gem 'simple_form'
gem 'crypt_keeper'
gem 'mail'
gem 'jquery-datatables'
gem 'carrierwave'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'crono'
gem 'regressor'
gem 'pundit'
gem 'font-awesome-rails'
gem 'sprockets-rails'
gem 'bootstrap','~> 4.0.0.beta2.1'
gem 'bootstrap-will_paginate'
gem 'popper_js'
gem 'ransack'
gem 'ledermann-rails-settings'
gem 'will_paginate'

# logging
gem 'lograge'
gem 'logstash-event'
gem 'logstash-logger'

#chrono UI
gem 'haml'
gem 'sinatra', require: nil

group :development, :test do
  gem "database_cleaner"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem 'squasher'
end
group :test do
  gem 'shoulda-matchers'
  gem "capybara"
  gem "selenium-webdriver"
end