bundle exec jekyll build

git clone --depth=1 https://github.com/envoyproxy/envoy.git "envoy-source"
git config --global --add safe.directory /envoy 

ls -lart

cd envoy-source/docs
bazel build //docs:html_release

ls -lart

# cd ..

# cp -rf /opt/build/cache/generated/docs/* /opt/build/repo/_site/docs/envoy
