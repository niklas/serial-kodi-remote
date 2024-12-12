FROM elixir:1.17.3-otp-27-alpine
ARG app_name=skr
ARG build_env=prod
ENV MIX_ENV=${build_env} TERM=xterm
WORKDIR /src
RUN apk update \
    && apk --no-cache --update add build-base linux-headers
COPY config config
COPY lib lib
COPY mix.exs mix.exs
COPY mix.lock mix.lock
RUN --mount=type=tmpfs,target=./deps
RUN --mount=type=tmpfs,target=./_build
RUN mix local.rebar --force \
    && mix local.hex --force
RUN mix deps.get
RUN ERL_FLAGS="+JMsingle true" mix compile --all-warnings
RUN mix release ${app_name} \
    && mv _build/${build_env}/rel/${app_name} /opt/release \
    && mv /opt/release/bin/${app_name} /opt/release/bin/server
CMD ["/opt/release/bin/server", "start"]
