FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /22_PROKEN
COPY Gemfile /22_PROKEN/Gemfile
COPY Gemfile.lock /22_PROKEN/Gemfile.lock
RUN bundle install
COPY . /22_PROKEN

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
