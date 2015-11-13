source "https://rubygems.org"
ruby "2.2.2"

gem "rails", "~> 4.2.4"
gem "bourbon", "~> 3.2.1"
gem "email_validator"
gem "i18n-tasks"
gem "kaminari"
gem "namely", github: 'namely/ruby-client'
gem "neat", "~> 1.5.1"
gem "normalize-rails", "~> 3.0.0"
gem "pg"
gem "raygun4ruby"
gem "recipient_interceptor"
gem "rest-client"
gem "sass-rails", "~> 4.0.3"
gem "simple_form"
gem "title"
gem "unicorn"
gem "font-awesome-rails"
gem 'mailgun_rails', '~> 0.6.6'
gem 'jquery-rails'

gem 'sidekiq', '4.0.0.pre2'
gem 'global_phone', :git => 'https://github.com/sstephenson/global_phone.git', :ref => 'dd0894061f58479884e6cfa2d00382542dc77d5a'

group :development do
  gem "spring"
  gem "spring-commands-rspec"
end

group :development, :test do
  gem "awesome_print"
  gem "byebug"
  gem "dotenv-rails"
  gem "factory_girl_rails"
  gem "pry-rails"
  gem "rspec-rails", "~> 3.3"
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'better_errors', '~> 2.1.1'
end

group :test do
  gem "capybara-email"
  gem "capybara_discoball", github: "thoughtbot/capybara_discoball"
  gem "capybara-webkit", ">= 1.2.0"
  gem "climate_control"
  gem "database_cleaner"
  gem "formulaic"
  gem "headless"
  gem "launchy"
  gem "shoulda-matchers", require: false
  gem "timecop"
  gem "webmock"
  gem 'rspec_junit_formatter', github: 'circleci/rspec_junit_formatter'
end

group :staging, :production do
  gem "rails_12factor"
  gem "rack-timeout"
end
