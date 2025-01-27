# Content Directory

This directory contains all the content for the Envoy website. The content is organized into several key sections, each serving a specific purpose.

## Directory Structure

```
content/
├── data/              # YAML-based structured content
│   ├── adopters/     # Organizations using Envoy
│   ├── community/    # Community projects and companies
│   ├── courses/      # Educational content and tutorials
│   └── projects/     # Envoy-related projects
├── pages/            # Static pages (About, Contact, etc.)
├── releases/         # Release information
└── index.html        # Main landing page
```

## Adding Content

### Data Files (YAML)

Most content is managed through YAML files in the `data/` directory. The site uses a custom `load_yaml` plugin that automatically loads these files and makes them available to templates.

#### Directory-specific Guidelines:

1. **Adopters** (`data/adopters/`)
   - Envoy adopters


2. **Community** (`data/community/`)
   - Organized into subdirectories:
     - `cncf/` - CNCF projects using Envoy
     - `commercial/` - Commercial products and services
     - `oss/` - Open source projects


3. **Courses** (`data/courses/`)
   - Courses to be featured on the sites learning page

4. **Projects** (`data/projects/`)
   - Envoy projects shown on the site
     - Proxy
     - Gateway
     - Mobile
     - AI Gateway


### Static Pages

To add a new static page:

1. Create a new Markdown file in the `pages/` directory
2. Include the required metadata at the top:
   ```markdown
   Title: Page Title
   Slug: url-friendly-name
   Template: page
   ```

### Release Information

Release information is automatically managed by the `envoy_releases` plugin. Manual updates to the `releases/` directory are not required.

## Content Guidelines

1. **YAML Formatting**
   - Use 2-space indentation
   - Quote string values containing special characters
   - Use list format for multiple values

2. **Images and Assets**
   - Store images in the appropriate theme directory
   - Use SVG format for logos when possible
   - Optimize images before committing

3. **Markdown Content**
   - Use standard Markdown syntax
   - Include alt text for images
   - Use relative links for internal references


## Getting Help

- Check the [load_yaml plugin documentation](../plugins/load_yaml/README.md) for YAML file handling
- Review existing content files for examples
- Submit issues for content-related questions

Remember to run the development server and verify your changes locally before submitting a pull request.
