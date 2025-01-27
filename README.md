# Envoy Site Repository

This repository contains the source code and scripts for the Envoy Project site.

This is a **Pelican** project deployed on **Netlify**, with some additional helper scripts.
To build the latest docs for Envoy Proxy, there are steps in the `build/netlify-build.sh` script that checkouts the Envoy repository and builds the latest docs using Bazel, the docs are only regenerated when a change has happened in the docs directory of Envoy.

The archived docs are accessed via proxying requests to a separate **Netlify** deployment of the archived docs sites. This ensures we are not rebuilding and deploying archive for each site change.

## Overview

- **Directories**
    - **content/** - Content files (markdown, rst) used in the site
    - **theme/** - The Pelican theme containing templates and static files
    - **output/** - The generated static site (not tracked in git)
    - **.netlify/** - Configurations for the Netlify deployment
    - **assets/** - Common assets like scripts and images for the site
    - **collections/** - Collections of data for the site used in pages
    - **deploy/** - Deployment script for Netlify deployment
    - **local/** - Resources to run the site locally while developing
    - **logos/** - Logos for community and adopters of Envoy Project
    - **scripts/** - Shared scripts for the site
- **Files**
    - **pelicanconf.py** - The Pelican configuration
    - **_redirects** - Netlify redirects
    - **requirements.txt** - Python dependencies for the project
    - **package.json** - NPM package dependencies for Netlify deploy

## Running Locally

### Using Python

Use Python on host machine for developing the website, without docs.

#### Prerequisites
- Python 3.8+
- pip

#### Steps

1. **Create and activate a virtual environment**:
    ```sh
    python -m venv venv
    source venv/bin/activate  # On Windows use: venv\Scripts\activate
    ```

2. **Install Dependencies**:
    ```sh
    pip install -r requirements.txt
    ```

3. **Build the Site**:
    ```sh
    pelican content
    ```

4. **Serve the Site**:
    ```sh
    pelican --listen
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

Create a markdown file in the `content/adopters` directory.
Under projects, list all Envoy projects your company is adopting.

**Projects:**
- proxy
- gateway
- ai-gateway
- mobile

```yaml
Title: Company Name
Logo: logo.svg
URL: https://mycompany.com
Projects:
    - proxy
    - gateway
```

Add logo to `theme/static/images/logos` directory.
