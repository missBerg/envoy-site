# Envoy Releases Plugin

A Pelican plugin that fetches and processes release information from GitHub repositories, specifically designed for tracking Envoy Proxy and related project releases.

## Overview

This plugin automatically fetches release information from configured GitHub repositories, processes the data, and makes it available to your Pelican site. It handles version sorting, categorization of releases (stable vs. older), and generates structured YAML data that can be used in your templates.

## Features

- Fetches release data from GitHub repositories using the GitHub API
- Categorizes releases into stable, development, and older releases
- Supports multiple projects tracking
- Caches release data to avoid unnecessary API calls
- Provides both individual project and consolidated release data files
- Intelligent version sorting and grouping

## Configuration

Add the following settings to your Pelican configuration file:

```python
# Required Settings
GITHUB_TOKEN = 'your_github_token'  # Set as environment variable
GITHUB_ORG = 'envoyproxy'          # GitHub organization name
GITHUB_PROJECTS = ['envoy']        # List of repository names to track

# Optional Settings
RELEASES_OUTPUT_PATH = 'content/releases'  # Output directory for YAML files
```

## Output

The plugin generates two types of YAML files:

1. Individual project files: `{project}_releases.yml`
2. Consolidated file: `all_projects_releases.yml`

The release data is structured as:

```yaml
stable_releases:
  - version: "v1.xx.0"
    releases:
      - release: "1.xx.0"
        url: "https://github.com/..."
        published_at: "YYYY-MM-DD"

development_release:
  - version: "Development Version"
    releases:
      - release: "latest"
        url: "https://github.com/envoyproxy/envoy/"
        published_at: "Built off main branch"

older_releases:
  - version: "v1.yy.0"
    releases:
      - release: "1.yy.0"
        url: "https://github.com/..."
        published_at: "YYYY-MM-DD"
```

## Usage in Templates

The release data is available in your templates through the `release_data` context variable:

```html
{% for release in release_data['envoy']['stable_releases'] %}
    <h2>{{ release.version }}</h2>
    {% for r in release.releases %}
        <a href="{{ r.url }}">{{ r.release }}</a> ({{ r.published_at }})
    {% endfor %}
{% endfor %}
```

## Requirements

- Python 3.6+
- `requests` library
- `PyYAML` library
- GitHub Personal Access Token with `repo` scope

## Note

The plugin caches release data on a daily basis to avoid hitting GitHub API rate limits. New release data will be fetched once per day when generating the site.
