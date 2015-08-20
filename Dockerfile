FROM ruby:2.2.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev qt5-default libqt5webkit5-dev xvfb
RUN mkdir /connect
WORKDIR /connect
RUN gem install bundler -v "~> 1.10.0"
ADD Gemfile /connect/Gemfile
ADD Gemfile.lock /connect/Gemfile.lock
RUN bundle install
ADD . /connect
