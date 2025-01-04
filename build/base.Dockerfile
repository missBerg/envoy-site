# Use a base image with Ubuntu
FROM ubuntu:24.04

# Set environment variables
ENV BAZEL_VERSION=6.5.0
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/builder/tools:$PATH"
ENV BUILDER_HOME="/home/builder"

# Install system dependencies (as root)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    zip \
    build-essential \
    openjdk-11-jdk \
    ruby-full \
    bundler \
    python3 \
    python3-pip \
    python3-requests \
    python3-yaml \
    parallel \
    rsync \
    inotify-tools \
    && apt-get clean

# Create a non-root user
RUN useradd -ms /bin/bash builder

WORKDIR /home/builder

# Create necessary directories and set ownership
RUN for dir in \ 
        envoy \ 
        envoy-site \
        envoy-archive \
        output \
        metadata \
        app; do \
    mkdir -p $BUILDER_HOME/$dir && chown builder:builder $BUILDER_HOME/$dir; \
    done

RUN mkdir -p $BUILDER_HOME/app/docs && chown builder:builder $BUILDER_HOME/app/docs

RUN mkdir -p $BUILDER_HOME/app/docs/envoy && chown builder:builder $BUILDER_HOME/app/docs/envoy

RUN mkdir -p $BUILDER_HOME/tools && chown builder:builder $BUILDER_HOME/tools

# Set bundle config to use a local cache
RUN bundle config set cache_path /home/builder/tools/.bundle/cache

# Change user to Builder
USER builder

# Download Bazelisk locally in the user's home directory
RUN curl -L -o $BUILDER_HOME/tools/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v1.17.0/bazelisk-linux-amd64 \
    && chmod +x $BUILDER_HOME/tools/bazelisk \
    && ln -s $BUILDER_HOME/tools/bazelisk $BUILDER_HOME/tools/bazel
