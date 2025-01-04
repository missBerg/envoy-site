#!/bin/bash

set -e  # Exit on error
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#--------------------------------------
# Source Functions
#--------------------------------------

source ./scripts/functions/logging.sh
source ./scripts/functions/build_proxy_docs_latest.sh
source ./scripts/functions/ruby_setup.sh
source ./scripts/functions/jekyll.sh
source ./scripts/functions/get_proxy_docs_archive.sh

#--------------------------------------


#--------------------------------------
# Main Script
#--------------------------------------

# Output Environment Information
log_function_start "${BLUE}" "main"

# rsync -av --no-perms --no-owner --no-group --delete --exclude='docs' --exclude='_site' --exclude='.git' /home/builder/envoy-site/ /home/builder/app/

info "Change directory to /home/builder/app" "main"
cd /home/builder/app

export PATH="$HOME/tools:$PATH"
echo "Path: $PATH"
ls -lart

# Setup Ruby
ruby_setup

# Install Ruby Gems
gem_install

# Build Envoy Proxy Docs
if [ "$BUILD_DOCS" = "true" ]; then
    build_proxy_docs_latest &
    get_proxy_docs_archive &
else
    info "Skipping Envoy Proxy Docs build." "main"
fi

# Start Jekyll Server
jekyll_start

#--------------------------------------
