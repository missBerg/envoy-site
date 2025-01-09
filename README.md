# Envoy Site Repository

This repository contains the source code and scripts for the Envoy Project site.

## Running Locally

### Using Jekyll

#### Prerequisites
- Ruby 3.3.5
- Bundler

#### Steps

1. **Install Jekyll**: Follow the [Jekyll installation guide](https://jekyllrb.com/docs/installation/).

2. **Install Dependencies**:
    ```sh
    bundle install
    ```

3. **Build the Site**:
    ```sh
    bundle exec jekyll build
    ```

4. **Serve the Site**:
    ```sh
    bundle exec jekyll serve
    ```

### Using Docker

#### Prerequisites

- Docker
- Docker Compose

#### Steps

1. **Build the Docker Image**:
    ```sh
    docker compose build
    ```

2. **Run the Docker Container**:
    ```sh
    docker compose up --watch --remove-orphans
    ```

3. **Stop the Docker Container**:
    ```sh
    docker compose down
    ```

## Deployment

The site is automatically deployed on Netlify. The `build/netlify-build.sh` script is used to build the site and generate the necessary documentation.

See README in `build/` directory for more information about the build process.
