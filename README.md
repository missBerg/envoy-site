# Envoy Site

This repository contains the source code for the Envoy website, built using [Pelican](https://getpelican.com/), a static site generator written in Python.

## Project Structure

```
.
├── site/                  # Main project directory
│   ├── content/          # Site content (data, articles, pages)
│   ├── theme/           # Site theme and templates
│   ├── plugins/         # Pelican plugins
│   ├── pelicanconf.py   # Pelican configuration
│   ├── publishconf.py   # Production settings
│   └── requirements.txt # Python dependencies
```

## Documentation

Detailed documentation can be found in the following READMEs:

- [Content Structure and Guidelines](site/content/README.md)
- [Data Files Documentation](site/content/data/README.md)
- [Custom Plugins Documentation](site/plugins/README.md)
  - [Load YAML Plugin](site/plugins/load_yaml/README.md)
  - [Envoy Releases Plugin](site/plugins/envoy_releases/README.md)

## Prerequisites

- Python 3.x
- pip (Python package installer)

## Local Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/envoyproxy/envoy-site.git
   cd envoy-site
   ```

2. Create and activate a virtual environment (recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
   ```

3. Install dependencies:
   ```bash
   cd site
   pip install -r requirements.txt
   ```

## Running Locally

You can run the site locally in three ways:

1. Using the provided script:
   ```bash
   cd site
   chmod +x run.sh  # Make the script executable
   ./run.sh
   ```

2. Using Invoke (recommended for development):
   ```bash
   cd site
   invoke devserver
   ```
   This starts a development server with live-reload capability, automatically rebuilding the site when files are modified.

3. Or manually using Pelican:
   ```bash
   cd site
   pelican --autoreload --listen --bind 0.0.0.0
   ```

The site will be available at `http://localhost:8000`. Both the `invoke devserver` and `--autoreload` options enable automatic rebuilding when files are modified.

## Project Components

- **Content**: Located in `site/content/`, includes YAML files for projects, courses, and community information
- **Theme**: Custom theme files in `site/theme/`
- **Plugins**: Additional functionality through Pelican plugins in `site/plugins/`

## Contributing

1. Fork the repository
2. Create a new branch for your changes
3. Make your changes
4. Submit a pull request

## Dependencies

Key dependencies include:
- Pelican (with Markdown support)
- PyYAML
- Jinja2 content plugin
- YAML metadata plugin
- Web assets plugin
- libsass for SASS processing
