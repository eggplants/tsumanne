FROM --platform=$BUILDPLATFORM ruby:4.0@sha256:342dd3092e25f9d16fc2a5c48c5bb2d9a93717d4f900d005d6e088e2c45d3d19 AS builder

WORKDIR /src
COPY . .
RUN gem build tsumanne.gemspec --output /tmp/tsumanne.gem

FROM ruby:4.0-slim@sha256:db9ddd17cc6ac603f2497d98ac5c88e4118908d6f9a45f2422ebee141f91e485

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
