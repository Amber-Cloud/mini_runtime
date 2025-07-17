# Use the official Elixir image
FROM elixir:1.15-otp-26

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get

# Copy the source code
COPY . .

# Compile the project
RUN mix compile

# Expose port
EXPOSE 4000

# Default command
CMD ["mix", "phx.server"]