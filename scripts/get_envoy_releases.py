import requests
import yaml
import argparse
import re
import sys
from collections import defaultdict
from datetime import datetime

def log_info(message):
    print(f"\033[1;34m[INFO] [get_envoy_releases.py]\033[0m {message}")

def log_error(message):
    print(f"\033[1;31m[ERROR] [get_envoy_releases.py]\033[0m {message}", file=sys.stderr)

# Argument parsing
parser = argparse.ArgumentParser(description='Generate releases YAML file for a GitHub project')
parser.add_argument('project', help='GitHub project name (e.g., envoy)')
parser.add_argument('--org', default='envoyproxy', help='GitHub organization name (default: envoyproxy)')
parser.add_argument('--output', default='.', help='Output directory for the YAML file (default: current directory)')
args = parser.parse_args()

log_info(f"Fetching releases for project {args.project} from organization {args.org}")

# GitHub API endpoint and headers
url = f"https://api.github.com/repos/{args.org}/{args.project}/releases"
headers = {"Accept": "application/vnd.github+json"}
all_releases = []
page = 1

# Fetch all releases
while True:
    response = requests.get(f"{url}?per_page=100&page={page}", headers=headers)
    if response.status_code != 200:
        log_error(f"Failed to fetch releases: {response.status_code} {response.text}")
        sys.exit(1)
    releases = response.json()
    if not releases:
        break
    all_releases.extend(releases)
    page += 1

log_info(f"Fetched {len(all_releases)} releases")

# Parse version strings
def parse_version(version_str):
    parts = version_str.split('-')
    version_parts = parts[0].split('.')
    rc_part = parts[1].split('.')[1] if len(parts) > 1 else None
    major = int(version_parts[0])
    minor = int(version_parts[1])
    patch = int(version_parts[2])
    rc = int(rc_part) if rc_part else float('inf')
    return (major, minor, patch, rc)

def version_key(version):
    try:
        return parse_version(version)
    except (IndexError, ValueError):
        return (0, 0, 0, -1)

# Extract and sort releases by version, excluding RC versions
release_tags = [
    release["tag_name"].lstrip("v") for release in all_releases
    if release["tag_name"].startswith("v") and
    re.match(r'^v\d+\.\d+\.\d+$', release["tag_name"])
]
release_tags = sorted(release_tags, key=version_key, reverse=True)

log_info(f"Found {len(release_tags)} valid release tags")

# Group releases by major.minor versions
grouped_releases = defaultdict(list)
for tag in release_tags:
    major_minor = ".".join(tag.split(".")[:2])
    grouped_releases[major_minor].append(tag)

# Create a dictionary to store release information
release_info = {
    release["tag_name"].lstrip("v"): {
        "url": release["html_url"],
        "published_at": datetime.strptime(release["published_at"], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d")
    }
    for release in all_releases
    if release["tag_name"].startswith("v")
}

# Determine stable releases for the last four minor versions
stable_versions = set()
for version, patches in sorted(grouped_releases.items(), key=lambda x: [int(part) for part in x[0].split(".")], reverse=True)[:4]:
    stable_patches = [p for p in patches if not p.endswith('-rc.1')]
    if stable_patches:
        latest_patch = max(stable_patches, key=version_key)
        stable_versions.add(latest_patch)

log_info(f"Identified {len(stable_versions)} stable versions")

# Create the new YAML data structure
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

# Save to a YAML file
output_file = f"{args.output}/{args.project}_versions.yml"
with open(output_file, "w") as file:
    yaml.dump(yaml_data, file, sort_keys=False)

log_info(f"YAML file generated: {output_file}")
