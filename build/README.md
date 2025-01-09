# Netlify Build Script

This directory contains the `netlify-build.sh` script, which is used to build and deploy the Envoy documentation site on Netlify.

## Overview

The `netlify-build.sh` script performs the following tasks:
1. Generates the Envoy releases YAML file.
2. Builds the Jekyll site.
3. Builds the latest Envoy documentation.
4. Copies the generated documentation to the `_site` directory.

The netlify build & deploy process also depends on config in:
- **requirements.txt** - this is the python dependencies
- **package.json** - this defines the bazel dependency via npm
- **_redirects** - set up redirect for archive docs, and latest docs

Config for Netlify Build & Deploy:

**Base directory:** `/`
**Build command:** `./build/netlify-build.sh`
**Publish directory:** `_site`

## Script Details

### `netlify-build.sh`

This is the main build script for Netlify build. It performs the following tasks:

- **Generate Envoy Releases YAML File**:
    The script calls `get_envoy_releases.py` to fetch the releases from the Envoy GitHub repository and generate a YAML file with the release information.


- **Build the Jekyll Site**:
    The script builds the Jekyll site and outputs it to the `_site` directory.


- **Build Latest Envoy Documentation**:
    The script builds the latest version of the Envoy documentation using Bazel.

- **Copy Documentation to `_site` Directory**:
    The script copies the generated documentation to the `_site` directory to be published by Netlify.

## Logging

The script includes logging functions to provide informative messages during the build process:

- `log_info`: Logs informational messages.
- `log_warn`: Logs warning messages.
- `log_error`: Logs error messages.
