FROM ruby:2.6.2-stretch

# Change to the application's directory
WORKDIR /application

# Install gems, nodejs and precompile the assets
RUN apt update \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt install -y nodejs \
    && apt install yarn -y

COPY Gemfile /application
COPY Gemfile.lock /application

# Set Rails environment to production
ENV RAILS_ENV development

# Install gems
RUN bundle install

# Copy rest of the application code
COPY . /application

RUN bin/rails db:migrate RAILS_ENV=development

# Start the application server
ENTRYPOINT ./entrypoint.sh
