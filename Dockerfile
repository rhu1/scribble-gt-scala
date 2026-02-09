# syntax=docker/dockerfile:1.7
FROM eclipse-temurin:21-jdk-jammy AS src

ARG DEBIAN_FRONTEND=noninteractive

# Default: build from upstream (override USE_GIT_CLONE=0 to use local build context)
ARG REPO_URL=https://github.com/rhu1/scribble-gt-scala.git
ARG GIT_REF=gen
ARG USE_GIT_CLONE=1

RUN apt-get update -y \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Stage local build context (used only when USE_GIT_CLONE=0)
COPY . /tmp/local-src

# Populate /scribble-gt-scala either by cloning or copying local context.
RUN set -eux; \
    cd /; \
    rm -rf /scribble-gt-scala; \
    mkdir -p /scribble-gt-scala; \
    if [ "$USE_GIT_CLONE" = "1" ]; then \
      if git clone --depth 1 --branch "${GIT_REF}" "${REPO_URL}" /scribble-gt-scala; then \
        : ; \
      else \
        git clone "${REPO_URL}" /scribble-gt-scala; \
        cd /scribble-gt-scala; \
        git checkout "${GIT_REF}"; \
      fi; \
      cd /scribble-gt-scala; \
      git submodule update --init --recursive; \
    else \
      cp -a /tmp/local-src/. /scribble-gt-scala/; \
    fi; \
    rm -rf /tmp/local-src

WORKDIR /scribble-gt-scala


FROM eclipse-temurin:21-jdk-jammy AS build

ARG DEBIAN_FRONTEND=noninteractive
ARG BAZELISK_VERSION=1.28.0
ARG REBAR3_VSN=3.24.0
ARG OTP_VERSION=27.2.1
ARG ELIXIR_VERSION=v1.18.2
ARG TARGETARCH

# Tools (include Erlang/OTP build from source tarball + Python3)
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
      curl ca-certificates \
      git openssh-client \
      make python3 zip graphviz wget \
      nsis tofrodos mandoc bsdmainutils \
      software-properties-common \
      build-essential autoconf perl xsltproc \
      bison flex \
      libncurses5 \
      libncurses-dev \
      libtinfo-dev \
      libssl-dev \
      libwxgtk3.0-gtk3-dev \
      libgl1-mesa-dev \
      libglu1-mesa-dev \
      unixodbc-dev \
      libxml2-utils \
      fop \
      openjdk-21-jdk-headless \
      unzip \
 && rm -rf /var/lib/apt/lists/* \
 && if ! command -v gmake >/dev/null 2>&1; then ln -s "$(command -v make)" /usr/local/bin/gmake; fi

# Install Erlang/OTP from official source tarball (avoid Erlang Solutions repo flakiness)
RUN set -eux; \
    curl -fL --retry 5 --retry-delay 2 \
      "https://github.com/erlang/otp/releases/download/OTP-${OTP_VERSION}/otp_src_${OTP_VERSION}.tar.gz" \
      -o /tmp/otp.tar.gz; \
    mkdir -p /opt/otp-src; \
    tar -xzf /tmp/otp.tar.gz -C /opt/otp-src --strip-components=1; \
    rm -f /tmp/otp.tar.gz; \
    cd /opt/otp-src; \
    ./configure --prefix=/opt/erlang --with-ssl --enable-smp-support --enable-threads --enable-kernel-poll; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /opt/otp-src

ENV PATH="/opt/erlang/bin:${PATH}"


RUN set -eux; \
    curl -fL --retry 5 --retry-delay 2 \
      "https://github.com/elixir-lang/elixir/archive/refs/tags/${ELIXIR_VERSION}.tar.gz" \
      -o /tmp/elixir-src.tar.gz; \
    mkdir -p /opt/elixir-src; \
    tar -xzf /tmp/elixir-src.tar.gz -C /opt/elixir-src --strip-components=1; \
    rm -f /tmp/elixir-src.tar.gz; \
    cd /opt/elixir-src; \
    make -j"$(nproc)"; \
    make install PREFIX=/opt/elixir; \
    rm -rf /opt/elixir-src

ENV PATH="/opt/elixir/bin:${PATH}"

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

# Bazelisk (arch-aware)
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64)  BZ="bazelisk-linux-amd64" ;; \
      arm64)  BZ="bazelisk-linux-arm64" ;; \
      *)      echo "Unsupported TARGETARCH=${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/bazel \
      "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/${BZ}" \
 && chmod +x /usr/local/bin/bazel

WORKDIR /scribble-gt-scala
COPY --from=src /scribble-gt-scala /scribble-gt-scala

# Cache sbt deps between builds
RUN --mount=type=cache,target=/root/.ivy2 \
    --mount=type=cache,target=/root/.sbt \
    --mount=type=cache,target=/root/.cache/coursier \
    sbt -batch -Dsbt.supershell=false update


FROM eclipse-temurin:21-jdk-jammy AS runtime

ARG DEBIAN_FRONTEND=noninteractive
ARG REBAR3_VSN=3.23.0
ARG OTP_VERSION=27.2.1
ARG ELIXIR_VERSION=v1.18.2

# Runtime deps + build deps for RabbitMQ example builds
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
      curl ca-certificates \
      git \
      make bash nano less vim-tiny \
      python3 \
      build-essential autoconf perl xsltproc \
      bison flex \
      graphviz \
      libncurses5 \
      libncurses-dev \
      libtinfo-dev \
      libssl-dev \
      xz-utils unzip \
 && rm -rf /var/lib/apt/lists/* \
 && if ! command -v gmake >/dev/null 2>&1; then ln -s "$(command -v make)" /usr/local/bin/gmake; fi

# Reuse Erlang/OTP built in the build stage (avoid compiling twice)
COPY --from=build /opt/erlang /opt/erlang
ENV PATH="/opt/erlang/bin:${PATH}"

# Reuse pinned Elixir from build stage
COPY --from=build /opt/elixir /opt/elixir
ENV PATH="/opt/elixir/bin:${PATH}"

# rebar3 in PATH
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

# Create an unprivileged user and make workspace writable
RUN useradd -m -u 1000 artifact \
 && chown -R artifact:artifact /scribble-gt-scala

ENV HOME=/scribble-gt-scala \
    XDG_CACHE_HOME=/scribble-gt-scala/.cache \
    XDG_CONFIG_HOME=/scribble-gt-scala/.config \
    MIX_HOME=/scribble-gt-scala/.mix \
    HEX_HOME=/scribble-gt-scala/.hex \
    REBAR_CACHE_DIR=/scribble-gt-scala/.cache/rebar3

# Pre-create tool dirs so unprivileged builds don't touch /root/*
RUN mkdir -p /scribble-gt-scala/.cache /scribble-gt-scala/.config /scribble-gt-scala/.mix /scribble-gt-scala/.hex \
 && chown -R artifact:artifact /scribble-gt-scala/.cache /scribble-gt-scala/.config /scribble-gt-scala/.mix /scribble-gt-scala/.hex

USER artifact

ENTRYPOINT ["/bin/bash"]
