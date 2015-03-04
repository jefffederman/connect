source "https://rubygems.org"

ruby "2.1.3"

gem "rails", "4.1.6"
gem "bourbon", "~> 3.2.1"
gem "coffee-rails"
gem "delayed_job_active_record"
gem "email_validator"
gem "flutie"
gem "font-awesome-rails"
gem "high_voltage"
gem "i18n-tasks"
gem "jquery-rails"
gem "namely", github: "namely/ruby-client"
gem "neat", "~> 1.5.1"
gem "netsuite", github: "tabfugnic/netsuite"
gem "normalize-rails", "~> 3.0.0"
gem "pg"
gem "rack-timeout"
gem "recipient_interceptor"
gem "rest_client"
gem "sass-rails", "~> 4.0.3"
gem "simple_form"
gem "title"
gem "uglifier"
gem "unicorn"

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
  gem "rspec-rails", "~> 3.1.0"
end

group :test do
  gem "capybara_discoball", github: "thoughtbot/capybara_discoball"
  gem "capybara-webkit", ">= 1.2.0"
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "rspec_junit_formatter", github: "circleci/rspec_junit_formatter"
  gem "shoulda-matchers", require: false
  gem "timecop"
  gem "webmock"
  gem "vcr"
end

group :staging, :production do
  gem 'rails_12factor'
  gem 'honeybadger'
end
