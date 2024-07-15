# ./Dockerfile

# Extend from the official Elixir image.
FROM elixir:1.14-otp-25

RUN mkdir -p /app
WORKDIR /app
COPY . /paygate/

# Install Hex package manager.
# By using `--force`, we don’t need to type “Y” to confirm the installation.
# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force


# Install mix dependencies
RUN mix deps.get
RUN mix deps.compile

# Copy the rest of the application code
COPY . .

RUN mix deps.compile


# Expose port
EXPOSE 4000

CMD ["/app/entrypoint.sh"]
