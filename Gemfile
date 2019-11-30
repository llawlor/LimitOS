source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.0'
gem 'mysql2'
# redis can probably be updated in the future as long as it is compatible with ActionCable
# this is the current version that is compatible, even though redis 4.x has been released
gem 'redis', '~> 3.3'
gem "devise", ">= 4.7.0"
gem 'twitter-bootstrap-rails'
gem 'devise-bootstrap-views'
gem 'sass'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# fix websocket error, see https://github.com/faye/websocket-driver-ruby/issues/58
gem 'websocket-driver', git: 'https://github.com/faye/websocket-driver-ruby', ref: 'ee39af83d03ae3059c775583e4c4b291641257b8'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# for scheduled tasks
gem 'whenever'

# enable string calculations
gem 'dentaku'

# to send exception notifications
gem 'exception_notification'

# remove whitespaces from attributes
gem 'strip_attributes'

# for admin system
gem 'administrate'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :test do
  gem 'rspec-rails', '~> 3.5'
  gem 'guard-rspec'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'action-cable-testing'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano', '~> 3.8'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
end
