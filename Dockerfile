FROM elixir:alpine
ARG app_name=skr
ARG build_env=prod
ENV MIX_ENV=${build_env} TERM=xterm
WORKDIR /src
RUN apk update \
    && apk --no-cache --update add build-base linux-headers \
    && mix local.rebar --force \
    && mix local.hex --force
COPY . .
RUN --mount=type=tmpfs,target=./_build
RUN mix do deps.get, compile
RUN mix release ${app_name} \
    && mv _build/${build_env}/rel/${app_name} /opt/release \
    && mv /opt/release/bin/${app_name} /opt/release/bin/start_server
CMD /opt/release/bin/start_server
