FROM --platform=$BUILDPLATFORM ruby:4.0@sha256:c400c1e41e8ad2276c82529ff9fd552cdb339a84e761c9d57d2d7f582122fa6e AS builder

WORKDIR /src
COPY . .
RUN gem build tsumanne.gemspec --output /tmp/tsumanne.gem

FROM ruby:4.0-slim@sha256:607bf92fa7ecebb4a0c6654b62cb44c48d94b36b6f5a754611ddbbe3dc5b6135

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
