import requests
import yaml
import argparse
import re
from collections import defaultdict
from datetime import datetime

# Add argument parsing
parser = argparse.ArgumentParser(description='Generate releases YAML file for a GitHub project')
parser.add_argument('project', help='GitHub project name (e.g., envoy)')
parser.add_argument('--org', default='envoyproxy', help='GitHub organization name (default: envoyproxy)')
args = parser.parse_args()

# GitHub API endpoint and headers
url = f"https://api.github.com/repos/{args.org}/{args.project}/releases"
headers = {"Accept": "application/vnd.github+json"}
all_releases = []
page = 1

# Fetch all releases
while True:
    response = requests.get(f"{url}?per_page=100&page={page}", headers=headers)
    releases = response.json()
    if not releases:
        break
    all_releases.extend(releases)
    page += 1

def parse_version(version_str):
    # Split version into parts and handle RC versions
    parts = version_str.split('-')
    version_parts = parts[0].split('.')
    rc_part = parts[1].split('.')[1] if len(parts) > 1 else None
    
    # Convert to integers
    major = int(version_parts[0])
    minor = int(version_parts[1])
    patch = int(version_parts[2])
    rc = int(rc_part) if rc_part else float('inf')
    
    return (major, minor, patch, rc)

def version_key(version):
    try:
        return parse_version(version)
    except (IndexError, ValueError):
        return (0, 0, 0, -1)  # Invalid versions sort to beginning

# Extract and sort releases by version, excluding RC versions
release_tags = [
    release["tag_name"].lstrip("v") for release in all_releases
    if release["tag_name"].startswith("v") and 
    re.match(r'^v\d+\.\d+\.\d+$', release["tag_name"])  # Only match standard versions
]
release_tags = sorted(release_tags, key=version_key, reverse=True)

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

# Determine stable releases for the last four minor versions (excluding RC versions)
stable_versions = set()
for version, patches in sorted(grouped_releases.items(), key=lambda x: [int(part) for part in x[0].split(".")], reverse=True)[:4]:
    stable_patches = [p for p in patches if not p.endswith('-rc.1')]
    if stable_patches:
        latest_patch = max(stable_patches, key=version_key)
        stable_versions.add(latest_patch)

# Create the YAML data structure
yaml_data = {"versions": []}
for version, releases in sorted(grouped_releases.items(), key=lambda x: [int(part) for part in x[0].split(".")], reverse=True):
    yaml_data["versions"].append({
        "version": "v" + version,
        "has_stable": any(release in stable_versions for release in releases),
        "is_development": False,
        "releases": [
            {
                "release": release, 
                "stable": release in stable_versions,
                "url": release_info[release]["url"],
                "published_at": release_info[release]["published_at"]
            }
            for release in sorted(releases, key=version_key, reverse=True)
        ]
    })

yaml_data["versions"].append({
    "version": "Development Version",
    "has_stable": False,
    "is_development": True,
    "releases": [
        {
            "release": "latest", 
            "stable": False,
            "url": "https://github.com/envoyproxy/envoy/"
        }
    ]
})

# Save to a YAML file
output_file = f"{args.project}_all_releases.yml"
with open(output_file, "w") as file:
    yaml.dump(yaml_data, file, sort_keys=False)

print(f"YAML file generated: {output_file}")
