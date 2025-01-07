inject_ci_bazelrc () {
    {
        PROC_COUNT="$(nproc)"
        PROCS=$((PROC_COUNT - 1))
        SPHINX_ARGS="-j 12 -v warn"
        echo "build:ci --action_env=SPHINX_RUNNER_ARGS=\"${SPHINX_ARGS}\""
    } > repo.bazelrc
}

build_docs () {
    ls -lart
    echo "generating docs..."
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

    cd ..

}

latest_docs () {
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

    if [[ -n "$DOCS_UPDATED" ]]; then
        echo "The following changes were detected in the Envoy docs directory:"
        echo "$DOCS_UPDATED"

        echo "Building docs..."
        build_docs
    elif [[ ! -d "generated/docs" || ! "$(ls -A generated/docs 2>/dev/null)" ]]; then
        echo "Docs directory does not exist or is empty. Building docs..."
        build_docs
    else
        echo "No changes in the docs directory."
    fi

    cp -rf generated/docs/ _site/docs/envoy/

    cd ..

    # Copy the generated docs to the _site directory
    
}

docs_archive () {
    REPO_URL="https://github.com/envoyproxy/archive.git"
    CLONE_DIR="envoy-archive"

    # Clone the repository if it doesn't already exist
    if [[ ! -d "$CLONE_DIR/.git" ]]; then
        echo "Cloning archive repository..."
        git clone --depth=1 "$REPO_URL" "$CLONE_DIR"
        git config --global --add safe.directory "$(realpath "$CLONE_DIR")"
    fi

    cd "$CLONE_DIR"
    git pull origin main

    if [[ -n "$DOCS_UPDATED" ]]; then
        git pull origin main
        echo "The following changes were detected in the Envoy docs directory:"
        echo "$DOCS_UPDATED"

    else
        echo "No new changes in the archive docs directory."
    fi

    echo "Copying docs to _site..."

    ls -lrt docs/envoy/

    for dir in $CLONE_DIR/docs/envoy/*/; do

        DOCS_OUTPUT_DIR=../_site/docs/envoy/

        cp -rf $dir $DOCS_OUTPUT_DIR/"$(basename "$dir")"
        
    done

    cd ..
    
}

bundle exec jekyll build

latest_docs

docs_archive

ls -lart


# cd ..

# cp -rf /opt/build/cache/generated/docs/* /opt/build/repo/_site/docs/envoy
