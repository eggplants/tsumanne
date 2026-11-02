FROM --platform=$BUILDPLATFORM ruby:4.0@sha256:dd87233ce44e8362fed00a1fd590c01e3dd8f8eb0001ea4a2c8a071388e9185b AS builder

WORKDIR /src
COPY . .
RUN gem build tsumanne.gemspec --output /tmp/tsumanne.gem

FROM ruby:4.0-slim@sha256:e41d40671d359ccc3431371e0af7c6430bd1b3886b47ac0667443525b7dcec1a

LABEL org.opencontainers.image.title="tsumanne" \
      org.opencontainers.image.description="Unofficial API wrapper and CLI for tsumanne.net" \
      org.opencontainers.image.source="https://github.com/eggplants/tsumanne" \
      org.opencontainers.image.licenses="MIT"

RUN --mount=type=bind,from=builder,source=/tmp/tsumanne.gem,target=/tmp/tsumanne.gem \
    gem install /tmp/tsumanne.gem --no-document

RUN tsumanne --version

RUN useradd --create-home --user-group tsumanne
USER tsumanne
WORKDIR /home/tsumanne

ENTRYPOINT ["tsumanne"]
CMD ["--help"]
