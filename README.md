## Jekyll


### Build
```
bundle exec jekyll build
```

### Serve

```
bundle exec jekyll serve
```

## Docker

### Build
```
docker buildx build --platform linux/amd64 --no-cache -t jekyll-envoy-docs 
```


### Run
```
docker run --platform linux/amd64 --rm -e BUILD_DOCS=false -p 4000:4000 -v /Users/erica/repos/envoy:/home/builder/app/envoy-source jekyll-envoy-docs 
```
