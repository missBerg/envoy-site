function build_docs {

    if [[ -z "${BUILD_DIR}" ]]; then
        echo "BUILD_DIR not set - defaulting to ~/.cache/envoy-bazel" >&2
        BUILD_DIR="${HOME}/.cache/envoy-bazel"
    fi

    BAZEL_STARTUP_OPTIONS=(
    "--output_user_root=${BUILD_DIR}/bazel_root"
    "--output_base=${BUILD_DIR}/bazel_root/base"
    )

    echo "generating docs..."
    # Build docs.

    DOCS_OUTPUT_DIR=generated/docs
    rm -rf "${DOCS_OUTPUT_DIR}"
    mkdir -p "${DOCS_OUTPUT_DIR}"
    # SPHINX_ARGS="-j 12 -v warn"
    export SPHINX_RUNNER_ARGS="-v warn"
    BAZEL_BUILD_OPTIONS+=("--action_env=SPHINX_RUNNER_ARGS=\"${SPHINX_RUNNER_ARGS}\" --host_jvm_args=-Xmx2g --host_jvm_args=-Xms1g")

    # if [[ -n "${DOCS_BUILD_RST}" ]]; then
    #     bazel "${BAZEL_STARTUP_OPTIONS[@]}" build "${BAZEL_BUILD_OPTIONS[@]}" //docs:rst
    #     cp bazel-bin/docs/rst.tar.gz "$DOCS_OUTPUT_DIR"/envoy-docs-rst.tar.gz
    # fi

    DOCS_OUTPUT_DIR="$(realpath "$DOCS_OUTPUT_DIR")"

    PROC_COUNT="$(nproc)"=$((PROC_COUNT - 1))
    
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

bundle exec jekyll build

git clone --depth=1 https://github.com/envoyproxy/envoy.git "envoy-source"
git config --global --add safe.directory /envoy 

ls -lart

# cd envoy-source/docs
# bazel build -j 12 --local_ram_resources=HOST_RAM*.8 //docs:html_release

cd envoy-source

ls -lart

build_docs

ls -lart

# cd ..

# cp -rf /opt/build/cache/generated/docs/* /opt/build/repo/_site/docs/envoy
