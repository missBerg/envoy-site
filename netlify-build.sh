bundle exec jekyll build

git clone --depth=1 https://github.com/envoyproxy/envoy.git "envoy"
git config --global --add safe.directory /envoy 

cd envoy/docs
bazel run --//tools/tarball:target=//docs:html //tools/tarball:unpack /generated/docs

cd ..

cp -rf /docs/generated/docs/* _site/docs/envoy
