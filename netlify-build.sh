log_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

inject_ci_bazelrc () {
    PROC_COUNT="$(nproc)"
    PROCS=$((PROC_COUNT - 1))
    SPHINX_ARGS="-j 12 -v warn"
    echo "build:ci --action_env=SPHINX_RUNNER_ARGS=\"${SPHINX_ARGS}\"" > repo.bazelrc
    log_info "Injected CI Bazel configuration."
}

build_latest_docs () {
    log_info "Starting to generate docs..."
    
    if [[ -z "${BUILD_DIR}" ]]; then
        log_warn "BUILD_DIR not set - defaulting to ~/.cache/envoy-bazel"
        BUILD_DIR="${HOME}/.cache/envoy-bazel"
    fi

    BAZEL_STARTUP_OPTIONS=(
        "--output_user_root=${BUILD_DIR}/bazel_root"
        "--output_base=${BUILD_DIR}/bazel_root/base"
    )

    DOCS_OUTPUT_DIR="generated/docs"
    rm -rf "${DOCS_OUTPUT_DIR}"
    mkdir -p "${DOCS_OUTPUT_DIR}"
    export SPHINX_RUNNER_ARGS="-j 12"
    DOCS_OUTPUT_DIR="$(realpath "$DOCS_OUTPUT_DIR")"
    PROC_COUNT="$(nproc)"=$((PROC_COUNT - 1))
    BAZEL_BUILD_OPTIONS+=(--config=ci)
    inject_ci_bazelrc
    
    log_info "Running Bazel to build docs..."
    bazel "${BAZEL_STARTUP_OPTIONS[@]}" run \
        "${BAZEL_BUILD_OPTIONS[@]}" \
        --//tools/tarball:target=//docs:html \
        //tools/tarball:unpack \
        "$DOCS_OUTPUT_DIR"

    if [ $? -ne 0 ]; then
        log_error "Build failed. Displaying JVM logs:"
        cat /opt/buildhome/.cache/envoy-bazel/bazel_root/base/server/jvm.out
        exit 1
    fi

    log_info "Docs generation completed successfully."
}

add_latest_docs () {
    REPO_URL="https://github.com/envoyproxy/envoy.git"
    CLONE_DIR="envoy-source"

    if [[ ! -d "$CLONE_DIR/.git" ]]; then
        log_info "Envoy Proxy Repository not present. Cloning repository..."
        git clone --depth=1 "$REPO_URL" "$CLONE_DIR"
        git config --global --add safe.directory "$(realpath "$CLONE_DIR")"
    else
        log_info "Envoy Proxy Repository already cloned. Pulling latest changes..."
        cd "$CLONE_DIR"
        git fetch origin
        DOCS_UPDATED=$(git diff --name-only origin/main | grep '^docs/')
        cd ..
    fi

    cd "$CLONE_DIR"
    git pull origin main

    log_info "Checking for changes in the docs directory..."
    ls -lrt generated/docs/

    if [[ ! -d "generated/docs/" || ! "$(ls -A generated/docs/ 2>/dev/null)" ]]; then
        log_info "Docs directory does not exist or is empty. Building latest docs..."
        build_latest_docs
    elif [[ -n "$DOCS_UPDATED" ]]; then
        log_info "The following changes were detected in the Envoy docs directory:"
        echo "$DOCS_UPDATED"
        log_info "Building latest docs..."
        build_latest_docs
    else
        log_info "No changes in the docs directory."
    fi

    log_info "Creating docs directory in _site publish directory..."
    mkdir -p ../_site/docs/envoy/
    log_info "Copying docs to _site directory..."
    cp -rf generated/docs/ ../_site/docs/envoy/
    cd ..
}

# Main Build Script
log_info "Generating Envoy releases YAML file..."
python3 scripts/get_envoy_releases.py envoy --output _data
log_info "Envoy releases YAML file generated."

log_info "Starting Jekyll site build, output to _site directory..."
bundle exec jekyll build
log_info "Jekyll site build completed."

log_info "Building docs for Latest version from Envoy repository..."
add_latest_docs
log_info "Docs build and copy completed."

log_info "Build process complete."
