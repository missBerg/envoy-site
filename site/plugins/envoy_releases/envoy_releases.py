from pelican import signals
import requests
import yaml
import os
import re
from collections import defaultdict
from datetime import datetime
from typing import Dict, List, Tuple, Optional, Any

def log_info(message: str) -> None:
    print(f"\033[1;34m[INFO]\033[0m {message}")

def log_error(message: str) -> None:
    print(f"\033[1;31m[ERROR]\033[0m {message}")

class Version:
    def __init__(self, version_str: str):
        self.version_str = version_str
        parts = version_str.split('-')
        version_parts = parts[0].split('.')
        rc_part = parts[1].split('.')[1] if len(parts) > 1 else None
        
        self.major = int(version_parts[0])
        self.minor = int(version_parts[1])
        self.patch = int(version_parts[2])
        self.rc = int(rc_part) if rc_part else float('inf')
    
    def as_tuple(self) -> Tuple[int, int, int, float]:
        return (self.major, self.minor, self.patch, self.rc)

def version_key(version: str) -> Tuple[int, int, int, float]:
    try:
        return Version(version).as_tuple()
    except (IndexError, ValueError):
        return (0, 0, 0, -1)

def fetch_releases(org: str, project: str) -> List[Dict]:
    url = f"https://api.github.com/repos/{org}/{project}/releases"
    token = os.getenv("GITHUB_TOKEN")
    
    if not token:
        log_error("GitHub token not found in environment variables.")
        return []
    
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"token {token}"
    }
    
    all_releases = []
    page = 1
    
    while True:
        try:
            response = requests.get(
                f"{url}?per_page=100&page={page}",
                headers=headers
            )
            if response.status_code != 200:
                log_error(f"Failed to fetch releases for {project}: {response.status_code} {response.text}")
                return []
            
            releases = response.json()
            if not releases:
                break
                
            all_releases.extend(releases)
            page += 1
            
        except Exception as e:
            log_error(f"Error fetching releases for {project}: {str(e)}")
            return []
    
    log_info(f"Fetched {len(all_releases)} releases for project {project}")
    return all_releases

def filter_release_tags(releases: List[Dict]) -> List[str]:
    return [
        release["tag_name"].lstrip("v") 
        for release in releases
        if release["tag_name"].startswith("v") and 
        re.match(r'^v\d+\.\d+\.\d+$', release["tag_name"])
    ]

def group_releases_by_version(release_tags: List[str]) -> Dict[str, List[str]]:
    grouped = defaultdict(list)
    for tag in sorted(release_tags, key=version_key, reverse=True):
        major_minor = ".".join(tag.split(".")[:2])
        grouped[major_minor].append(tag)
    return grouped

def create_release_info(releases: List[Dict]) -> Dict[str, Dict[str, str]]:
    return {
        release["tag_name"].lstrip("v"): {
            "url": release["html_url"],
            "published_at": datetime.strptime(
                release["published_at"], 
                "%Y-%m-%dT%H:%M:%SZ"
            ).strftime("%Y-%m-%d")
        }
        for release in releases
        if release["tag_name"].startswith("v")
    }

def get_stable_versions(grouped_releases: Dict[str, List[str]], num_stable: int = 4) -> set:
    stable = set()
    sorted_versions = sorted(
        grouped_releases.items(), 
        key=lambda x: [int(part) for part in x[0].split(".")], 
        reverse=True
    )
    
    for version, patches in sorted_versions[:num_stable]:
        stable.update(patches)
    return stable

def format_release_data(version: str, releases: List[str], release_info: Dict) -> Dict:
    return {
        "version": "v" + version,
        "releases": [
            {
                "release": release,
                "url": release_info[release]["url"],
                "published_at": release_info[release]["published_at"]
            }
            for release in sorted(releases, key=version_key, reverse=True)
        ]
    }

def process_releases(all_releases: List[Dict]) -> Dict:
    release_tags = filter_release_tags(all_releases)
    grouped_releases = group_releases_by_version(release_tags)
    release_info = create_release_info(all_releases)
    stable_versions = get_stable_versions(grouped_releases)
    
    yaml_data = {
        "stable_releases": [],
        "development_release": [{
            "version": "Development Version",
            "releases": [{
                "release": "latest",
                "url": "https://github.com/envoyproxy/envoy/",
                "published_at": None
            }]
        }],
        "older_releases": []
    }
    
    for version, releases in sorted(
        grouped_releases.items(),
        key=lambda x: [int(part) for part in x[0].split(".")],
        reverse=True
    ):
        release_data = format_release_data(version, releases, release_info)
        if any(release in stable_versions for release in releases):
            yaml_data["stable_releases"].append(release_data)
        else:
            yaml_data["older_releases"].append(release_data)
            
    return yaml_data

def generate_release_data(generator: Any) -> None:
    settings = generator.settings
    projects = settings.get("GITHUB_PROJECTS", [])
    org = settings.get("GITHUB_ORG", "envoyproxy")
    output_path = settings.get("RELEASES_OUTPUT_PATH", "content/releases")
    
    log_info(f"Using settings: projects={projects}, org={org}, output_path={output_path}")
    
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    
    consolidated_file = os.path.join(output_path, "all_projects_releases.yml")
    
    # Check if releases file exists and was updated today
    if os.path.exists(consolidated_file):
        file_mtime = datetime.fromtimestamp(os.path.getmtime(consolidated_file))
        if file_mtime.date() == datetime.now().date():
            with open(consolidated_file, 'r') as file:
                generator.settings['RELEASE_DATA'] = yaml.safe_load(file)
                log_info("Using existing generated release file from today")
                return
    
    log_info("Fetching fresh release data")
    consolidated_data = {}
    
    for project in projects:
        releases = fetch_releases(org, project)
        if not releases:
            log_error(f"Skipping project {project} due to fetch failure.")
            continue
            
        project_data = process_releases(releases)
        consolidated_data[project] = project_data
        
        # Write individual project YAML file
        project_file = os.path.join(output_path, f"{project}_releases.yml")
        with open(project_file, "w") as file:
            yaml.dump(project_data, file, sort_keys=False)
        log_info(f"YAML file generated for project {project}: {project_file}")
    
    # Write consolidated YAML file
    with open(consolidated_file, "w") as file:
        yaml.dump(consolidated_data, file, sort_keys=False)
    log_info(f"Consolidated YAML file generated: {consolidated_file}")
    
    generator.settings['RELEASE_DATA'] = consolidated_data

def add_settings_to_generator(generator: Any, metadata: Dict = None) -> None:
    # Initialize with empty dict if RELEASE_DATA is not yet available
    if 'RELEASE_DATA' not in generator.settings:
        generator.settings['RELEASE_DATA'] = {}
    generator.context['release_data'] = generator.settings['RELEASE_DATA']

def register() -> None:
    # Run the release data generation after initialization
    signals.initialized.connect(generate_release_data)
    # Ensure the context is available during page generation
    signals.page_generator_context.connect(add_settings_to_generator)
