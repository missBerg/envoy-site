bundle exec jekyll build

git clone --depth=1 https://github.com/envoyproxy/envoy.git "envoy"
git config --global --add safe.directory /envoy 

mkdir -p /tools

curl -L -o /tools/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v1.17.0/bazelisk-linux-amd64 \
    && chmod +x /tools/bazelisk \
    && ln -s /tools/bazelisk /tools/bazel

echo $pwd

export PATH="$PWD/tools:$PATH"

cd envoy/docs
bazel run --//tools/tarball:target=//docs:html //tools/tarball:unpack /generated/docs

cd ..

cp -rf /docs/generated/docs/* _site/docs/envoy
