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

COPY . /tmp/local-src

RUN if [ "$USE_GIT_CLONE" = "1" ]; then \
      git clone --depth 1 --branch "${GIT_REF}" "${REPO_URL}" /scribble-gt-scala ; \
    else \
      cp -a /tmp/local-src/. /scribble-gt-scala/ ; \
    fi \
 && rm -rf /tmp/local-src


FROM eclipse-temurin:21-jdk-jammy AS build

ARG DEBIAN_FRONTEND=noninteractive
ARG BAZELISK_VERSION=1.28.0

# Enable Ubuntu "universe" (often needed for nsis/elixir on minimal images)
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends software-properties-common ca-certificates \
 && add-apt-repository -y universe \
 && rm -rf /var/lib/apt/lists/*

# Tools
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
      curl gnupg git openssh-client \
      rebar3 make python3 zip graphviz wget \
      elixir erlang-dev erlang-eunit erlang-common-test erlang-dialyzer \
      erlang-debugger erlang-parsetools erlang-runtime-tools erlang-os-mon erlang-ssl \
      nsis tofrodos mandoc bsdmainutils \
 && rm -rf /var/lib/apt/lists/*

# Install sbt from the official repo (matches sbt site instructions)
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" > /etc/apt/sources.list.d/sbt.list \
 && echo "deb https://repo.scala-sbt.org/scalasbt/debian /" > /etc/apt/sources.list.d/sbt_old.list \
 && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" \
      -o /etc/apt/trusted.gpg.d/sbt.asc \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends sbt \
 && rm -rf /var/lib/apt/lists/*
# (Those repo/key lines are straight from the sbt download page.) :contentReference[oaicite:1]{index=1}

# Bazelisk (Bazel docs recommend Bazelisk on Ubuntu) :contentReference[oaicite:2]{index=2}
RUN curl -fsSL -o /usr/local/bin/bazel \
      "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-amd64" \
 && chmod +x /usr/local/bin/bazel
# (Bazelisk versions are published on GitHub releases.) :contentReference[oaicite:3]{index=3}

WORKDIR /scribble-gt-scala

COPY --from=src /scribble-gt-scala /scribble-gt-scala

# Cache sbt deps between builds (huge speed-up)
RUN --mount=type=cache,target=/root/.ivy2 \
    --mount=type=cache,target=/root/.sbt \
    --mount=type=cache,target=/root/.cache/coursier \
    sbt -batch -Dsbt.supershell=false update

RUN --mount=type=cache,target=/root/.ivy2 \
    --mount=type=cache,target=/root/.sbt \
    --mount=type=cache,target=/root/.cache/coursier \
    sbt -batch -Dsbt.supershell=false compile test:compile

RUN --mount=type=cache,target=/root/.ivy2 \
    --mount=type=cache,target=/root/.sbt \
    --mount=type=cache,target=/root/.cache/coursier \
    sbt -batch -Dsbt.supershell=false "show assembly / packagedArtifact" || true


FROM eclipse-temurin:21-jdk-jammy AS runtime

ARG DEBIAN_FRONTEND=noninteractive

# Minimal runtime deps for using generated Erlang demos inside the container
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
      rebar3 make \
      elixir erlang-runtime-tools erlang-os-mon erlang-ssl \
      graphviz \
 && rm -rf /var/lib/apt/lists/*

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

ENTRYPOINT ["/bin/bash"]
