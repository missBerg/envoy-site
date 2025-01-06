bundle exec jekyll build

git clone --depth=1 https://github.com/envoyproxy/envoy.git "envoy"
git config --global --add safe.directory /envoy 

ls -lart

curl -o $BAZELISK_HOME https://github.com/bazelbuild/bazelisk/releases/download/v1.17.0/bazelisk-linux-amd64
chmod +x $BAZELISK_HOME \
ln -s .$BAZELISK_HOME /opt/build/cache/bazel

# echo $PWD

# export PATH="$PWD/tools:$PATH"

# cd envoy/docs
# bazel run --//tools/tarball:target=//docs:html //tools/tarball:unpack /opt/build/cache/generated/docs

# cd ..

# cp -rf /opt/build/cache/generated/docs/* /opt/build/repo/_site/docs/envoy
