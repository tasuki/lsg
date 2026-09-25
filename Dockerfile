FROM ruby:3.3-slim

# Install build essentials for native extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Expose the default Jekyll port and LiveReload port
EXPOSE 4000 35729

# Run Jekyll serve by default, allowing external connections
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--force_polling", "--livereload", "--livereload-port", "35729"]
