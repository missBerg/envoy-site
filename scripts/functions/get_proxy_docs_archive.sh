get_proxy_docs_archive() {
    log_function_start "${BLUE}" "get_proxy_docs_archive"

    cd ../envoy

    ENVOY_SOURCE_DIR="/home/builder/envoy-archive"
    DOCS_OUTPUT="/home/builder/envoy-archive/docs/envoy"
    ENVOY_DOCS_LOCATION="/home/builder/app/docs/envoy"

    # Clone Envoy Archive repository if necessary

    if [ -d "${ENVOY_SOURCE_DIR}" ] && [ "$(ls -A ${ENVOY_SOURCE_DIR})" ]; then
        info "Envoy Archive repository already exists and is not empty." "get_proxy_docs_archive"
        info "Updating Envoy Archive repository..." "get_proxy_docs_archive"
        git fetch
        git pull
    elif [ -d "${ENVOY_SOURCE_DIR}" ]; then
        warn "Envoy Archive directory exists but is empty. Cloning repository..." "get_proxy_docs_archive"
        git clone --depth=1 https://github.com/envoyproxy/archive.git "${ENVOY_SOURCE_DIR}"
    else
        info "Envoy Archive directory does not exist. Cloning repository..." "get_proxy_docs_archive"
        git clone --depth=1 https://github.com/envoyproxy/archive.git "${ENVOY_SOURCE_DIR}"
    fi
    # Mark the directory as safe for Git
    git config --global --add safe.directory /home/builder/envoy-archive 

    # Get current commit ID
    CURRENT_COMMIT=$(git rev-parse HEAD)
    METADATA_FILE="/home/builder/metadata/archive_commit_id.txt"
    DOCS_CHANGED=false

        # Check if metadata file exists and compare commits
        if [ -f "$METADATA_FILE" ]; then
            LAST_COMMIT=$(cat "$METADATA_FILE")
            # Check if docs directory has changed between commits
            if git diff --quiet "$LAST_COMMIT" "$CURRENT_COMMIT" -- docs/envoy/; then
                info "No changes in docs directory since last build." "get_proxy_docs_archive"
                DOCS_CHANGED=false
            else
                info "Changes detected in docs directory since last build." "get_proxy_docs_archive"
                DOCS_CHANGED=true
            fi
        else
            info "No previous commit ID found. Will build docs." "get_proxy_docs_archive"
            DOCS_CHANGED=true
        fi

        # Copy docs into target location
        info "Copying archive docs to Jekyll site directory" "get_proxy_docs_archive"
        cd /home/builder/app/
        mkdir -p "${ENVOY_DOCS_LOCATION}"
        cp -rf "${DOCS_OUTPUT}"/* "${ENVOY_DOCS_LOCATION}/"

        # Capture the git commit ID
        info "Capturing the git commit ID" "get_proxy_docs_archive"
        cd "${ENVOY_SOURCE_DIR}"
        GIT_COMMIT_ID=$(git rev-parse HEAD)
        echo "${GIT_COMMIT_ID}" > "${METADATA_FILE}"
}
