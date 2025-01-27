# Load YAML Plugin for Pelican

A Pelican plugin that loads YAML files from a data directory and makes them available in the site's templates.

## Description

This plugin recursively loads YAML files from a `data` directory in your Pelican site and makes their contents available in your templates through a global `yaml_data` variable. The data is organized in a nested dictionary structure that mirrors your directory hierarchy.

## Features

- Recursively loads YAML files from nested directories
- Maintains directory structure in the resulting data object
- Safely handles invalid YAML files and missing directories
- Provides detailed logging for debugging
- Supports both `.yaml` and `.yml` file extensions

## Installation

1. Place the plugin in your Pelican project's plugins directory
2. Add 'load_yaml' to your `PLUGINS` setting in your Pelican configuration:

```python
PLUGINS = [
    # ... other plugins ...
    'load_yaml',
]
```

## Usage

1. Create a `data` directory in your Pelican content folder
2. Add YAML files in any nested directory structure
3. Access the data in your templates using the `yaml_data` variable

### Example Directory Structure

```
content/
└── data/
    ├── projects/
    │   └── proxy.yaml
    └── community/
        ├── cncf/
        │   └── istio.yaml
        └── commercial/
            └── company.yaml
```

### Accessing Data in Templates

The YAML data will be available in your Jinja2 templates through the `yaml_data` variable, maintaining the directory structure:

```jinja
{{ yaml_data.projects.proxy.title }}
{{ yaml_data.community.cncf.istio.description }}
{{ yaml_data.community.commercial.company.name }}
```

## Error Handling

The plugin includes robust error handling:
- Empty YAML files are logged with warnings
- Invalid YAML syntax is caught and logged
- Missing data directory results in an empty data structure
- Processing errors for individual files won't crash the build

## Logging

The plugin provides detailed logging for debugging purposes. Logs include:
- File processing status
- Parse errors
- Directory processing information
- Data loading confirmations

## Requirements

- PyYAML
- Pelican

## License

This plugin is part of the Envoy website project. See the project's main license for details.
