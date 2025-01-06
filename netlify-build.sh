bundle exec jekyll build

git clone --depth=1 https://github.com/envoyproxy/envoy.git "envoy-source"
git config --global --add safe.directory /envoy 

ls -lart

cd envoy-source/docs
bazel run --//tools/tarball:target=//docs:html //tools/tarball:unpack "$PWD"/generated/docs/

ls -lart

# cd ..

# cp -rf /opt/build/cache/generated/docs/* /opt/build/repo/_site/docs/envoy
