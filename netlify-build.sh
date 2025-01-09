inject_ci_bazelrc () {
    {
        PROC_COUNT="$(nproc)"
        PROCS=$((PROC_COUNT - 1))
        SPHINX_ARGS="-j 12 -v warn"
        echo "build:ci --action_env=SPHINX_RUNNER_ARGS=\"${SPHINX_ARGS}\""
    } > repo.bazelrc
}

build_latest_docs () {
    ls -lart
    echo "Generating docs..."
    # Build docs.

    if [[ -z "${BUILD_DIR}" ]]; then
        echo "BUILD_DIR not set - defaulting to ~/.cache/envoy-bazel" >&2
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
    
    bazel "${BAZEL_STARTUP_OPTIONS[@]}" run \
            "${BAZEL_BUILD_OPTIONS[@]}" \
            --//tools/tarball:target=//docs:html \
            //tools/tarball:unpack \
            "$DOCS_OUTPUT_DIR"

    if [ $? -ne 0 ]; then
        echo "Build failed. Displaying JVM logs:"
        cat /opt/buildhome/.cache/envoy-bazel/bazel_root/base/server/jvm.out
        exit 1
    fi

}

add_latest_docs () {
    REPO_URL="https://github.com/envoyproxy/envoy.git"
    CLONE_DIR="envoy-source"

    # Clone the repository if it doesn't already exist
    if [[ ! -d "$CLONE_DIR/.git" ]]; then
        echo "Cloning repository..."
        git clone --depth=1 "$REPO_URL" "$CLONE_DIR"
        git config --global --add safe.directory "$(realpath "$CLONE_DIR")"
    else
        echo "Repository already cloned. Pulling latest changes..."
        cd "$CLONE_DIR"

        # Check for changes in the docs directory
        git fetch origin
        DOCS_UPDATED=$(git diff --name-only origin/main | grep '^docs/')

        cd ..
    fi

    cd "$CLONE_DIR"
    git pull origin main

    ls -lrt generated/docs/

    
    if [[ ! -d "generated/docs/" || ! "$(ls -A generated/docs/ 2>/dev/null)" ]]; then
        echo "Docs directory does not exist or is empty. Building latest docs..."
        build_latest_docs
    elif [[ -n "$DOCS_UPDATED" ]]; then
        echo "The following changes were detected in the Envoy docs directory:"
        echo "$DOCS_UPDATED"

        echo "Building latest docs..."
        build_latest_docs
    else
        echo "No changes in the docs directory."
    fi

    echo "Create docs directory in _site publish directory..."
    mkdir -p ../_site/docs/envoy/
    # Copy the generated docs to the _site directory to be published
    echo "Copy docs to _site directory..."
    cp -rf generated/docs/ ../_site/docs/envoy/

    cd ..
    
}

#--------------------------------------
# Main Build Script
#--------------------------------------

echo "Build jekyll site, output to _site directory..."

bundle exec jekyll build

echo "Build docs for Latest version from Envoy repository..."

add_latest_docs

echo "Build complete."
