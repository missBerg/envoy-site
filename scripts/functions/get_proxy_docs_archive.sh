source ./scripts/functions/git_docs.sh

get_proxy_docs_archive() {
    log_function_start "${BLUE}" "get_proxy_docs_archive"

    # cd ../envoy

    local ENVOY_SOURCE_DIR="/home/builder/envoy-archive"
    local DOCS_OUTPUT="/home/builder/envoy-archive/docs/envoy"
    local ENVOY_DOCS_LOCATION="/home/builder/app/docs/envoy"
    local REPO_URL="https://github.com/envoyproxy/archive.git"
    local METADATA_FILE="/home/builder/metadata/archive_commit_id.txt"

    clone_or_update_repo "${ENVOY_SOURCE_DIR}" "${REPO_URL}"

    # Get current commit ID
    CURRENT_COMMIT=$(git -C "${ENVOY_SOURCE_DIR}" rev-parse HEAD)
    DOCS_CHANGED=$(check_docs_changed "${ENVOY_SOURCE_DIR}" "${METADATA_FILE}" "${CURRENT_COMMIT}" "docs/envoy/")

    info "Docs changed: ${DOCS_CHANGED}" "get_proxy_docs_archive"

    # Capture the git commit ID
    info "Capturing the git commit ID" "get_proxy_docs_archive"
    echo "${CURRENT_COMMIT}" > "${METADATA_FILE}"

    for dir in $ENVOY_SOURCE_DIR/docs/envoy/*/; do
        symlink_path=$ENVOY_DOCS_LOCATION/"$(basename "$dir")"

        if [ ! -e "$symlink_path" ]; then
            ln -s "$dir" "$symlink_path"
            info "Creating symlink: ln -s $dir $ENVOY_DOCS_LOCATION/$(basename $dir)" "get_proxy_docs_archive" 
        else
            info "Symlink or file already exists: $symlink_path" "get_proxy_docs_archive" 
        fi
    done

}
