from pelican import signals
import requests
import yaml
import os
import re
from collections import defaultdict
from datetime import datetime

def log_info(message):
    print(f"\033[1;34m[INFO]\033[0m {message}")

def log_error(message):
    print(f"\033[1;31m[ERROR]\033[0m {message}")

# Function to parse version strings
def parse_version(version_str):
    parts = version_str.split('-')
    version_parts = parts[0].split('.')
    rc_part = parts[1].split('.')[1] if len(parts) > 1 else None
    major = int(version_parts[0])
    minor = int(version_parts[1])
    patch = int(version_parts[2])
    rc = int(rc_part) if rc_part else float('inf')
    return (major, minor, patch, rc)

# Function to generate a sortable key for versions
def version_key(version):
    try:
        return parse_version(version)
    except (IndexError, ValueError):
        return (0, 0, 0, -1)

# Function to fetch releases from GitHub
def fetch_releases(org, project):
    url = f"https://api.github.com/repos/{org}/{project}/releases"
    token = os.getenv("GITHUB_TOKEN")
    if not token:
        log_error("GitHub token not found in environment variables.")
        return []
    headers = {"Accept": "application/vnd.github+json", "Authorization": f"token {token}"}
    all_releases = []
    page = 1

    while True:
        response = requests.get(f"{url}?per_page=100&page={page}", headers=headers)
        if response.status_code != 200:
            log_error(f"Failed to fetch releases for {project}: {response.status_code} {response.text}")
            return []
        releases = response.json()
        if not releases:
            break
        all_releases.extend(releases)
        page += 1

    log_info(f"Fetched {len(all_releases)} releases for project {project}")
    return all_releases

# Function to process releases into the required structure
def process_releases(all_releases):
    release_tags = [
        release["tag_name"].lstrip("v") for release in all_releases
        if release["tag_name"].startswith("v") and
        re.match(r'^v\d+\.\d+\.\d+$', release["tag_name"])
    ]
    release_tags = sorted(release_tags, key=version_key, reverse=True)

    grouped_releases = defaultdict(list)
    for tag in release_tags:
        major_minor = ".".join(tag.split(".")[:2])
        grouped_releases[major_minor].append(tag)

    release_info = {
        release["tag_name"].lstrip("v"): {
            "url": release["html_url"],
            "published_at": datetime.strptime(release["published_at"], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d")
        }
        for release in all_releases
        if release["tag_name"].startswith("v")
    }

    stable_versions = set()
    for version, patches in sorted(grouped_releases.items(), key=lambda x: [int(part) for part in x[0].split(".")], reverse=True)[:4]:
        stable_patches = [p for p in patches if not p.endswith('-rc.1')]
        if stable_patches:
            latest_patch = max(stable_patches, key=version_key)
            stable_versions.add(latest_patch)

    yaml_data = {
        "stable_releases": [],
        "development_release": {
            "version": "Development Version",
            "releases": [
                {
                    "release": "latest",
                    "url": "https://github.com/envoyproxy/envoy/",
                    "published_at": None
                }
            ]
        },
        "older_releases": []
    }

    for version, releases in sorted(grouped_releases.items(), key=lambda x: [int(part) for part in x[0].split(".")], reverse=True):
        stable_patches = [p for p in releases if p in stable_versions]
        if stable_patches:
            yaml_data["stable_releases"].append({
                "version": "v" + version,
                "releases": [
                    {
                        "release": release,
                        "url": release_info[release]["url"],
                        "published_at": release_info[release]["published_at"]
                    }
                    for release in sorted(stable_patches, key=version_key, reverse=True)
                ]
            })
        else:
            yaml_data["older_releases"].append({
                "version": "v" + version,
                "releases": [
                    {
                        "release": release,
                        "url": release_info[release]["url"],
                        "published_at": release_info[release]["published_at"]
                    }
                    for release in sorted(releases, key=version_key, reverse=True)
                ]
            })
    return yaml_data

# Main function to generate release data
def generate_release_data(generator):
    settings = generator.settings
    projects = settings.get("GITHUB_PROJECTS", [])
    org = settings.get("GITHUB_ORG", "envoyproxy")
    output_path = settings.get("RELEASES_OUTPUT_PATH", "content/releases")

    if not os.path.exists(output_path):
        os.makedirs(output_path)

    consolidated_data = {}
    for project in projects:
        all_releases = fetch_releases(org, project)
        if not all_releases:
            log_error(f"Skipping project {project} due to fetch failure.")
            continue

        project_data = process_releases(all_releases)
        consolidated_data[project] = project_data

        # Write individual project YAML file
        project_file = os.path.join(output_path, f"{project}_releases.yml")
        with open(project_file, "w") as file:
            yaml.dump(project_data, file, sort_keys=False)
        log_info(f"YAML file generated for project {project}: {project_file}")

    # Write consolidated YAML file
    consolidated_file = os.path.join(output_path, "all_projects_releases.yml")
    with open(consolidated_file, "w") as file:
        yaml.dump(consolidated_data, file, sort_keys=False)
    log_info(f"Consolidated YAML file generated: {consolidated_file}")

    consolidated_data
    generator.settings['RELEASE_DATA'] = consolidated_data

def add_settings_to_generator(generator, metadata):
    # Add specific settings to the global Jinja2 context
    generator.context['release_data'] = generator.settings.get('RELEASE_DATA', {})

# Register the plugin
def register():
    signals.initialized.connect(generate_release_data)
    signals.page_generator_context.connect(add_settings_to_generator)
