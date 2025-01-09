build_proxy_docs_latest () {

    log_function_start "${BLUE}" "build_proxy_docs_latest"

    ENVOY_SOURCE_DIR="/home/builder/envoy"
    DOCS_OUTPUT="/home/builder/envoy/docs/generated/docs"
    ENVOY_DOCS_LOCATION="/home/builder/app/docs/envoy/latest"
    METADATA_FILE="/home/builder/metadata/commit_id.txt"

    # Clone or update Envoy repository
    clone_or_update_repo "${ENVOY_SOURCE_DIR}" "https://github.com/envoyproxy/envoy.git"

    # Get current commit ID
    CURRENT_COMMIT=$(git -C "${ENVOY_SOURCE_DIR}" rev-parse HEAD)

    # Check if docs have changed
    DOCS_CHANGED=$(check_docs_changed "${ENVOY_SOURCE_DIR}" "${METADATA_FILE}" "${CURRENT_COMMIT}" "docs/")

    if [ "$DOCS_CHANGED" = true ]; then
        # Build the docs with Bazel
        info "Building docs with Bazel" "build_proxy_docs_latest"
        cd "${ENVOY_SOURCE_DIR}/docs"

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
    echo "${CURRENT_COMMIT}" > "${METADATA_FILE}"
}
