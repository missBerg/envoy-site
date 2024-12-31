# Stage 1: Prepare Envoy repository
FROM ubuntu:24.04 AS envoy_builder

WORKDIR /envoy-source
COPY /../envoy /home/builder/app/envoy-source

# Use a base image with Ubuntu
FROM ubuntu:24.04

# Set environment variables
ENV BAZEL_VERSION=6.5.0
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/builder/tools:$PATH"

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
    && apt-get clean

# Create a non-root user
RUN useradd -ms /bin/bash builder

# Chnage user to Builder
USER builder
WORKDIR /home/builder

# Download Bazelisk locally in the user's home directory
RUN mkdir -p tools \
    && curl -L -o tools/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v1.17.0/bazelisk-linux-amd64 \
    && chmod +x tools/bazelisk \
    && ln -s /home/builder/tools/bazelisk /home/builder/tools/bazel

# Create a directory for the Envoy repository, later used for volume to persist data
RUN mkdir -p envoy && chown builder:builder envoy


# Create a directory for the Envoy Docs Archive repository, later used for volume to persist data
RUN mkdir -p envoy-archive && chown builder:builder envoy-archive

# Create a metadata directory
RUN mkdir -p metadata && chown builder:builder metadata

# Create a app directory
RUN mkdir -p app && chown builder:builder app

# Copy the repo Jekyll project into the container
# COPY --chown=builder:builder .build_docs.sh /home/builder/tools/build_docs.sh

# Set bundle config to use a local cache
RUN bundle config set cache_path /home/builder/tools/.bundle/cache

# Switch to the project directory
WORKDIR /home/builder/app

# Make the build script executable
# RUN chmod +x build_docs.sh

# Run the build script
CMD ["./build_docs.sh"]
