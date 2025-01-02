clone_or_update_repo() {
    local REPO_DIR=$1
    local REPO_URL=$2

    if [ -d "${REPO_DIR}" ] && [ "$(ls -A ${REPO_DIR})" ]; then
        info "Repository already exists and is not empty." "clone_or_update_repo"
        info "Updating repository..." "clone_or_update_repo"
        git -C "${REPO_DIR}" fetch
        git -C "${REPO_DIR}" pull
    elif [ -d "${REPO_DIR}" ]; then
        warn "Repository directory exists but is empty. Cloning repository..." "clone_or_update_repo"
        git clone --depth=1 "${REPO_URL}" "${REPO_DIR}"
    else
        info "Repository directory does not exist. Cloning repository..." "clone_or_update_repo"
        git clone --depth=1 "${REPO_URL}" "${REPO_DIR}"
    fi
    git -C "${REPO_DIR}" config --global --add safe.directory "${REPO_DIR}"
}

check_docs_changed() {
    local REPO_DIR=$1
    local METADATA_FILE=$2
    local CURRENT_COMMIT=$3
    local DOCS_DIR=$4

    if [ -f "$METADATA_FILE" ]; then
        LAST_COMMIT=$(cat "$METADATA_FILE")
        if git -C "${REPO_DIR}" diff --quiet "$LAST_COMMIT" "$CURRENT_COMMIT" -- "${DOCS_DIR}"; then
            info "No changes in docs directory since last build." "check_docs_changed"
            echo false
        else
            info "Changes detected in docs directory since last build." "check_docs_changed"
            echo true
        fi
    else
        info "No previous commit ID found. Will build docs." "check_docs_changed"
        echo true
    fi
}
