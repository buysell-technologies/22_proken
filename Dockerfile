FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /22_proken
COPY Gemfile /22_proken/Gemfile
COPY Gemfile.lock /22_proken/Gemfile.lock
RUN bundle install
COPY . /22_proken
RUN mkdir -p tmp/sockets


# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
