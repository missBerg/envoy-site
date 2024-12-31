build_proxy_docs_latest () {

        log_function_start "${BLUE}" "build_proxy_docs_latest"

        cd ../envoy

        ENVOY_SOURCE_DIR="/home/builder/envoy"
        DOCS_OUTPUT="/home/builder/envoy/docs/generated/docs"
        ENVOY_DOCS_LOCATION="/home/builder/app/docs/envoy/latest"

        # Clone Envoy repository if necessary

        if [ -d "${ENVOY_SOURCE_DIR}" ] && [ "$(ls -A ${ENVOY_SOURCE_DIR})" ]; then
            info "Envoy repository already exists and is not empty." "build_proxy_docs_latest"
            info "Updating Envoy repository..." "build_proxy_docs_latest"
            git fetch
            git pull
        elif [ -d "${ENVOY_SOURCE_DIR}" ]; then
            warn "Envoy directory exists but is empty. Cloning repository..." "build_proxy_docs_latest"
            git clone --depth=1 https://github.com/envoyproxy/envoy.git "${ENVOY_SOURCE_DIR}"
        else
            info "Envoy directory does not exist. Cloning repository..." "build_proxy_docs_latest"
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
                info "No changes in docs directory since last build." "build_proxy_docs_latest"
                DOCS_CHANGED=false
            else
                info "Changes detected in docs directory since last build." "build_proxy_docs_latest"
                DOCS_CHANGED=true
            fi
        else
            info "No previous commit ID found. Will build docs." "build_proxy_docs_latest"
            DOCS_CHANGED=true
        fi

        if [ "$DOCS_CHANGED" = true ]; then
            # Build the docs with Bazel
            info "Building docs with Bazel" "build_proxy_docs_latest"
            cd docs

            # Clear the target directory if it exists
            if [ -d "${DOCS_OUTPUT}" ]; then
                info "Clearing existing generated docs directory" "build_proxy_docs_latest"
                rm -rf "${DOCS_OUTPUT}"
            fi
            
            bazel run --//tools/tarball:target=//docs:html //tools/tarball:unpack $DOCS_OUTPUT

            # Store current commit ID
            mkdir -p "$(dirname "$METADATA_FILE")"
            echo "$CURRENT_COMMIT" > "$METADATA_FILE"
        fi

        # Copy docs into target location
        info "Copying generated docs to Jekyll site directory" "build_proxy_docs_latest"
        cd /home/builder/app/
        mkdir -p "${ENVOY_DOCS_LOCATION}"
        cp -rf "${DOCS_OUTPUT}"/* "${ENVOY_DOCS_LOCATION}/"

        # Capture the git commit ID
        info "Capturing the git commit ID" "build_proxy_docs_latest"
        cd "${ENVOY_SOURCE_DIR}"
        GIT_COMMIT_ID=$(git rev-parse HEAD)
        echo "${GIT_COMMIT_ID}" > "${METADATA_FILE}"
}
