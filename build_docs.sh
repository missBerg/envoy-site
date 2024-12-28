#!/bin/bash

set -e  # Exit on error
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#--------------------------------------
# Script Functions
#--------------------------------------

LOG_FILE="/home/builder/metadata/build_docs_$(date +'%Y-%m-%d %H:%M:%S').log"
LOG_LEVEL=INFO

log() {
    local level=$1
    local message=$2
    local function=$3
    local levels=("DEBUG" "INFO" "WARN" "ERROR")
    [[ ! " ${levels[@]} " =~ " ${level} " ]] && return
    [[ " ${levels[@]} " =~ " ${LOG_LEVEL} " && "${levels[*]/*$LOG_LEVEL*}" =~ "$level" ]] && return
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$level] [$function] $message" | tee -a "$LOG_FILE"
}

info() { log "INFO" "$1" "$2"; }
warn() { log "WARN" "$1" "$2"; }
error() { log "ERROR" "$1" "$2"; }
debug() { log "DEBUG" "$1" "$2"; }


log_function_start () {
    local color=$1
    local function_name=$2
    echo -e "${color}======================================${NC}\n${color}STARTING: ${function_name}${NC}\n${color}--------------------------------------${NC}\n${color}Current Directory: $(pwd)${NC}\n${color}Active User: $(whoami)${NC}\n${color}--------------------------------------${NC}"
}

build_proxy_docs () {

    if [ "$BUILD_DOCS" = "true" ]; then
        log_function_start "${BLUE}" "build_proxy_docs"

        cd ../envoy

        ENVOY_SOURCE_DIR="/home/builder/envoy"
        DOCS_OUTPUT="/home/builder/envoy/docs/generated/docs"
        ENVOY_DOCS_LOCATION="/home/builder/app/envoy/docs"

        # Clone Envoy repository if necessary

        if [ -d "${ENVOY_SOURCE_DIR}" ] && [ "$(ls -A ${ENVOY_SOURCE_DIR})" ]; then
            info "Envoy repository already exists and is not empty." "build_proxy_docs"
            info "Updating Envoy repository..." "build_proxy_docs"
            git fetch
            git pull
        elif [ -d "${ENVOY_SOURCE_DIR}" ]; then
            warn "Envoy directory exists but is empty. Cloning repository..." "build_proxy_docs"
            git clone --depth=1 https://github.com/envoyproxy/envoy.git "${ENVOY_SOURCE_DIR}"
        else
            info "Envoy directory does not exist. Cloning repository..." "build_proxy_docs"
            git clone --depth=1 https://github.com/envoyproxy/envoy.git "${ENVOY_SOURCE_DIR}"
        fi
        # Mark the directory as safe for Git
        git config --global --add safe.directory /home/builder/envoy 

        # Get current commit ID
        CURRENT_COMMIT=$(git rev-parse HEAD)
        METADATA_FILE="/home/builder/metadata/commit_id.txt"
        DOCS_CHANGED=false

        # Check if metadata file exists and compare commits
        if [ -f "$METADATA_FILE" ]; then
            LAST_COMMIT=$(cat "$METADATA_FILE")
            # Check if docs directory has changed between commits
            if git diff --quiet "$LAST_COMMIT" "$CURRENT_COMMIT" -- docs/; then
                info "No changes in docs directory since last build." "build_proxy_docs"
                DOCS_CHANGED=false
            else
                info "Changes detected in docs directory since last build." "build_proxy_docs"
                DOCS_CHANGED=true
            fi
        else
            info "No previous commit ID found. Will build docs." "build_proxy_docs"
            DOCS_CHANGED=true
        fi

        if [ "$DOCS_CHANGED" = true ]; then
            # Build the docs with Bazel
            info "Building docs with Bazel" "build_proxy_docs"
            cd docs

            # Clear the target directory if it exists
            if [ -d "${DOCS_OUTPUT}" ]; then
                info "Clearing existing generated docs directory" "build_proxy_docs"
                rm -rf "${DOCS_OUTPUT}"
            fi
            
            bazel run --//tools/tarball:target=//docs:html //tools/tarball:unpack $DOCS_OUTPUT

            # Store current commit ID
            mkdir -p "$(dirname "$METADATA_FILE")"
            echo "$CURRENT_COMMIT" > "$METADATA_FILE"
        fi

        # Copy docs into target location
        info "Copying generated docs to Jekyll site directory" "build_proxy_docs"
        cd /home/builder/app/
        mkdir -p "${ENVOY_DOCS_LOCATION}"
        cp -rf "${DOCS_OUTPUT}"/* "${ENVOY_DOCS_LOCATION}/"

        # cp -rf /home/builder/envoy/docs/generated/docs/* /home/builder/app/_site/envoy/docs/

        # Capture the git commit ID
        info "Capturing the git commit ID" "build_proxy_docs"
        cd "${ENVOY_SOURCE_DIR}"
        GIT_COMMIT_ID=$(git rev-parse HEAD)
        echo "${GIT_COMMIT_ID}" > "${METADATA_FILE}"
    else
        echo "Skipping docs build."
    fi
}

ruby_setup (){

    log_function_start "${RED}" "ruby_setup"
    info "Create bundle cache location if it doesn't already exist..." "ruby_setup"

    if [ ! -d "/home/builder/tools/.bundle" ]; then
        mkdir /home/builder/tools/.bundle
    fi

    if [ ! -d "/home/builder/tools/.bundle/gems" ]; then
        mkdir /home/builder/tools/.bundle/gems
    fi

    ls -lrt /home/builder/tools/.bundle
    bundle config set cache_path /home/builder/tools/.bundle/cache

    info "Remove Gemfile.lock..." "ruby_setup"
    rm -f Gemfile.lock
}

gem_install (){
    log_function_start "${RED}" "gem_install"
    
    info "Gem Bundle install..." "gem_install"

    bundle config set path '/home/builder/tools/.bundle/gems'
        # Run the command and process its output
    bundle install 2>&1 | while IFS= read -r line; do
        log "$level" "$line" "gem_install - bundle install"
    done
}

jekyll_start (){
    log_function_start "${GREEN}" "jekyll_start"
    # bundle exec jekyll build --trace
    info "Starting Jekyll Server..." "jekyll_start"
    
    bundle exec jekyll serve --host 0.0.0.0 --port 4000 2>&1 | while IFS= read -r line; do
        info "$line" "jekyll_start - jekyll serve"
    done
}

#--------------------------------------


#--------------------------------------
# Main Script
#--------------------------------------

# Output Environment Information
log_function_start "${BLUE}" "main"

info "Change directory to /home/builder/app" "main"
cd /home/builder/app

export PATH="$HOME/tools:$PATH"
echo $PATH
ls -lrt

# Setup Ruby
ruby_setup

# Install Ruby Gems
gem_install

# Build Envoy Proxy Docs
build_proxy_docs &

# Start Jekyll Server
jekyll_start

#--------------------------------------
