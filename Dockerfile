# syntax=docker/dockerfile:1.7
FROM eclipse-temurin:21-jdk-jammy AS src

ARG DEBIAN_FRONTEND=noninteractive

# If set, the image will `git clone` the repo instead of using the local build context.
ARG REPO_URL=https://github.com/rhu1/scribble-gt-scala.git
ARG GIT_REF=gen
ARG USE_GIT_CLONE=0

WORKDIR /scribble-gt-scala

RUN apt-get update -y \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Stage local context somewhere we can copy from (when USE_GIT_CLONE=0).
COPY . /tmp/local-src

# Populate /scribble-gt-scala either by cloning or by copying the local build context.
RUN if [ "$USE_GIT_CLONE" = "1" ]; then \
      rm -rf /scribble-gt-scala/* && \
      git clone --depth 1 --branch "${GIT_REF}" "${REPO_URL}" /scribble-gt-scala ; \
    else \
      cp -a /tmp/local-src/. /scribble-gt-scala/ ; \
    fi \
 && rm -rf /tmp/local-src


FROM eclipse-temurin:21-jdk-jammy AS build

ARG DEBIAN_FRONTEND=noninteractive
ARG BAZELISK_VERSION=1.28.0
ARG REBAR3_VSN=3.24.0

# Tools (include Erlang/OTP 27 + Python3)
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
      curl gnupg ca-certificates \
      git openssh-client \
      make python3 zip graphviz wget \
      erlang rebar3 \
      elixir \
      nsis tofrodos mandoc bsdmainutils \
      software-properties-common \
 && rm -rf /var/lib/apt/lists/*

# Pin rebar3 (overwrite OS package version)
RUN curl -fsSL -o /usr/local/bin/rebar3 \
      "https://github.com/erlang/rebar3/releases/download/${REBAR3_VSN}/rebar3" \
 && chmod +x /usr/local/bin/rebar3

# Install sbt from the official repo
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" > /etc/apt/sources.list.d/sbt.list \
 && echo "deb https://repo.scala-sbt.org/scalasbt/debian /" > /etc/apt/sources.list.d/sbt_old.list \
 && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" \
      -o /etc/apt/trusted.gpg.d/sbt.asc \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends sbt \
 && rm -rf /var/lib/apt/lists/*

# Bazelisk
RUN curl -fsSL -o /usr/local/bin/bazel \
      "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-amd64" \
 && chmod +x /usr/local/bin/bazel

WORKDIR /scribble-gt-scala

COPY --from=src /scribble-gt-scala /scribble-gt-scala

# Cache sbt deps between builds (huge speed-up)
RUN --mount=type=cache,target=/root/.ivy2 \
    --mount=type=cache,target=/root/.sbt \
    --mount=type=cache,target=/root/.cache/coursier \
    sbt -batch -Dsbt.supershell=false update

# NOTE: we do not run `sbt compile` during docker build.



FROM eclipse-temurin:21-jdk-jammy AS runtime

ARG DEBIAN_FRONTEND=noninteractive
ARG REBAR3_VSN=3.23.0

# Minimal runtime deps for using generated Erlang demos inside the container
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
      erlang rebar3 \
      make bash nano less vim-tiny \
      python3 \
      graphviz \
      curl ca-certificates \
      elixir \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /usr/local/bin/rebar3 \
      "https://github.com/erlang/rebar3/releases/download/${REBAR3_VSN}/rebar3" \
 && chmod +x /usr/local/bin/rebar3

# sbt is needed at runtime because mMST.sh calls `sbt runMain ...`
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" > /etc/apt/sources.list.d/sbt.list \
 && echo "deb https://repo.scala-sbt.org/scalasbt/debian /" > /etc/apt/sources.list.d/sbt_old.list \
 && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" \
      -o /etc/apt/trusted.gpg.d/sbt.asc \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends sbt \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /scribble-gt-scala
COPY --from=build /scribble-gt-scala /scribble-gt-scala

# Create an unprivileged user for artifact evaluation and ensure the workspace is writable.
RUN useradd -m -u 1000 artifact \
 && chown -R artifact:artifact /scribble-gt-scala

USER artifact

ENTRYPOINT ["/bin/bash"]
