source "https://rubygems.org"
ruby "2.2.2"

gem "rails", "~> 4.2.4"
gem "bourbon", "~> 3.2.1"
gem "delayed_job_active_record"
gem "email_validator"
gem "i18n-tasks"
gem "kaminari"
gem "namely", "~> 0.2.1"
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
