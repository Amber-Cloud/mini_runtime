# Use the official Elixir image
FROM elixir:1.18-otp-26

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
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

# Default command - this is a utility service, not a long-running server
CMD ["mix", "compile"]