import pathlib
from datetime import datetime
from itertools import chain

from packaging import version as _version

import yaml


AUTHOR = "Envoy maintainers <envoy-maintainers@googlegroups.com>"
DEFAULT_LANG = "en"
# EXTRA_PATH_METADATA = {
#     "assets/robots.txt": {"path": "robots.txt"},
#     "assets/favicon.ico": {"path": "favicon.ico"},
#     "assets/404": {"path": "404.html"},
#     "assets/google7933de1bd04e097b": {"path": "google7933de1bd04e097b.html"},
#     "assets/google95e577d28834e13d": {"path": "google95e577d28834e13d.html"},
# }
FILENAME_METADATA = r"(?P<title>.*)"
NOW = datetime.now()
PATH = "content"
PAGE_PATHS = ['pages']
PAGE_URL = 'pages/{slug}/'
PAGE_SAVE_AS = '{slug}/index.html'
PLUGIN_PATHS = ['plugins']
PLUGINS = [
    "pelican.plugins.webassets",
    "pelican.plugins.yaml_metadata",
    "pelican.plugins.jinja2content",
    "load_yaml",
    "envoy_releases",
    ]

# Template settings
TEMPLATE_PATHS = ['theme/templates']
DIRECT_TEMPLATES = ['index']
JINJA2CONTENT_TEMPLATES = "theme/templates"

WEBASSETS_BUNDLES = (
    ('new_css', ['css/scss/main.scss'],
     {'filters': 'pyscss',
      'output': 'css/main.css',
      'debug': True}),
)

WEBASSETS_CONFIG = [
    ("auto_build", True),
    ("clean_output", True),
    ("url_expire", False),
    ("load_paths", ["theme/static/css/scss"]),
    ("debug_info", True),
    ("PYSCSS_LOAD_PATHS", ["theme/static/css/scss"]),
    ("debug_info", True),
]
PYSCSS_LOAD_PATHS = ["theme/static/css/scss"]
    
SITENAME = "Envoy proxy"
SITEURL = "https://www.envoyproxy.io"
RELATIVE_URLS = True
ARTICLE_PATHS = []
THEME = "theme"
TIMEZONE = "Europe/London"

TEMPLATE_PAGES = {
    "community.html": "community/index.html",
}

GITHUB_PROJECTS = [
    "envoy",
    "gateway",
]
GITHUB_ORG = "envoyproxy"
RELEASES_OUTPUT_PATH = "content/releases"


for yaml_file in pathlib.Path("data").glob("*.yaml"):
    locals()[yaml_file.stem.upper()] = yaml.safe_load(yaml_file.read_text())

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None
DEFAULT_PAGINATION = False
