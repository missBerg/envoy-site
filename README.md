# Envoy Site Repository

This repository contains the source code and scripts for the Envoy Project site.

This is a **Jekyll** project deployed on **Netlify**, with some additional helper scripts.
To build the latest docs for Envoy Proxy, there are steps in the `build/netlify-build.sh` script that checkouts the Envoy respostory and builds the latest docs using Bazel.

## Overview

- **Directories**
    - **_data/** - Data files used in the site
    - **_includes/** - Reusable HTML components included in pages
    - **_layouts/** - Jekyll Page layouts that are used by site pages
    - **_sass/** - Partials that are used from the style.scss in the css/ directory
    - **.netlify/** - Configurations for the Netlify deployment
    - **assets/** - Common assets like scripts and images for the site
    - **collections/** - Collections of data for the site used in pages
    - **css/** - The main style.scss file
    - **deploy/** - Deployment script for Netlify deployment
    - **local/** - Resources to run the site locally while developing
    - **logos/** - Logos for community and adopters of Envoy Project
    - **pages/** - The site pages
    - **scripts/** - Shared scripts for the site
- **Files**
    - **_config.yml** - the Jekyll configuration
    - **_redirects** - Netlify redirects
    - **.ruby-version** - The ruby version
    - **package.json** - NPM package dependencies for Netlify deploy
    - **requirements.txt** - Python dependencies for Netlify deploy

## Running Locally

### Using Jekyll

Use Jekyll on host machine for developing for the website, without docs.

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

With Docker you can serve the site locally with docs, both latest and archive.

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


## Add Adopter Logo

Create a markdown file in the collection `collections/_adopters`
Under projects, list all Envoy projects your company is adopting.

**Projects:**
- envoy-proxy
- envoy-gateway
- envoy-ai-gateway
- envoy-mobile

```
---
name: "Company"
logo: "logo.svg"
url: "https://mycompany.com"
projects:
    - envoy-proxy
    - envoy-gateway
---

```

Add logo to `logos` directory.
