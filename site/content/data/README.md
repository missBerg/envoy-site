# Site Data Directory

This directory contains YAML data files that are used to generate content for the Envoy Project site. The data here is structured and organized by category to make it easy to maintain and update the site's content.

## Directory Structure

- **adopters/** - YAML files for organizations using Envoy projects
- **features/** - Feature descriptions and metadata for different Envoy projects
- **releases/** - Release information and changelogs
- **team/** - Team member information and roles

## Adding New Data

### Adopter Data
Create a new YAML file in `adopters/` directory with the following structure:
```yaml
name: "Company Name" # name of the company  
logo: "company-logo.svg" # logo of the company
url: "https://company.com" # URL to learn more about the company
projects: # list of Envoy projects used by the company, delete as appropriate
    - proxy
    - gateway
    - mobile
    - ai-gateway
```

### Community Data

The community data is stored in the `community/` directory.

There are three types of community directories:
- CNCF Projects
- Commercial Projects
- Open Source Solutions (OSS) Projects

Valid types are:
- `cncf`
- `commercial`
- `oss`

Each of these directories contains YAML files with the following structure:
```yaml
name: "Solution Name" # name of the solution
logo: "logos/logo.svg" # logo of the solution
learn_more: "URL" # URL to learn more about the solution
type: "cncf" # type of the solution (cncf, commercial, oss)
# source_code: "githuborg/githubrepo" # optional, used for OSS and CNCF projects
description: |
  Description of the solution
``` 

### Courses Data

The course data is stored in the `courses/` directory.

Each course is a YAML file with the following structure:
```yaml
name: "Course Name" # name of the course
provider: "Provider Name" # name of the provider
logo: "logos/logo.svg" # logo of the course
learn_more: "URL" # URL to learn more about the course
cta: "CTA Text" # text of the CTA button
project: "proxy" # project the course is about
description: |
  Description of the course
```

### Projects Data

The project data is stored in the `projects/` directory.
This is a list of projects that are part of the Envoy project.

Each project is a YAML file with the following structure:
```yaml
id: "proxy" # id of the project
name: "Envoy Proxy" # name of the project
link: "/envoy" # site link to the project
docs: /envoy/docs/ # site link to the project docs
github: envoy # github repo of the project in the Envoyproxy GitHub org
image: /theme/images/envoy-proxy.svg # image of the project
show_stars: true # show stars on the project page
description: |
  Description of the project
capabilities: # list of capabilities of the project
  - title: "Capability Name"
    icon: "icon-name" # material icon name
    description: |
      Description of the capability
quotes:
  - content: |
      Quote from adopters of the project
    author_name: "Author Name"
    author_title: "Author Title"
``` 

## Data Usage

The data files in this directory are processed by the site's build system and used to generate various pages and components. The data is accessed through Pelican's data loading mechanism and can be referenced in templates and content files.

## File Naming Conventions

- Use lowercase letters and hyphens for file names
- Use descriptive names that reflect the content
- Always use the `.yaml` extension
- Example: `company-name.yaml`, `feature-security.yaml`

## Validation

All YAML files should be valid YAML format. You can validate your YAML files using tools like:
- `yamllint` command line tool
- Online YAML validators
- Your IDE's built-in YAML validation 
