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

    if [ "$DOCS_CHANGED" = true ]; then
        # Copy docs into target location
        info "There have been changes to the archive since last deployment" "get_proxy_docs_archive"
        # cd /home/builder/app/
        # mkdir -p "${ENVOY_DOCS_LOCATION}"
        # rsync -av --delete "${DOCS_OUTPUT}/" "${ENVOY_DOCS_LOCATION}/"
    fi

    # # Create a symlink to the latest docs /home/builder/envoy/docs/generated/docs
    # info "Creating a symlink to the latest docs" "get_proxy_docs_archive"
    # if [ -L "${ENVOY_DOCS_LOCATION}/latest" ]; then
    #     rm "${ENVOY_DOCS_LOCATION}/latest"
    # fi
    # ln -s "/home/builder/envoy/docs/generated/docs" "${DOCS_OUTPUT}/latest"

    # info "Syncing archive docs to Jekyll site directory" "get_proxy_docs_archive"
    rsync -ah --info=progress2 --delete \
     --exclude="latest" \
    "${DOCS_OUTPUT}/" "${ENVOY_DOCS_LOCATION}/"

    # create symlink from ${ENVOY_DOCS_LOCATION}/ to ${DOCS_OUTPUT}/
    # ln -s "${DOCS_OUTPUT}/" "${ENVOY_DOCS_LOCATION}/"

    # Capture the git commit ID
    info "Capturing the git commit ID" "get_proxy_docs_archive"
    echo "${CURRENT_COMMIT}" > "${METADATA_FILE}"
}
