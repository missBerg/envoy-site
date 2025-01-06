bundle exec jekyll build

git clone --depth=1 https://github.com/envoyproxy/envoy.git "envoy"
git config --global --add safe.directory /envoy 

ks -lart

curl -L -o $BAZELISK_HOME https://github.com/bazelbuild/bazelisk/releases/download/v1.17.0/bazelisk-linux-amd64 \
    && chmod +x $BAZELISK_HOME \
    && ln -s $BAZELISK_HOME /tools/bazel

echo $PWD

export PATH="$BAZELISK_HOME:$PATH"

cd envoy/docs
bazel run --//tools/tarball:target=//docs:html //tools/tarball:unpack ./generated/docs

cd ..

cp -rf ./docs/generated/docs/* ./_site/docs/envoy
