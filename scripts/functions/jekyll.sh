jekyll_start (){
    log_function_start "${GREEN}" "jekyll_start"

    
    CONFIG="--config _config.yml"

    if [ "$BUILD_DOCS" = "true" ]; then
        CONFIG="--config _config.yml,local/_config.docs.yml"
    fi

    info "Build Docs: $BUILD_DOCS" "jekyll_start"
    info "Config: $CONFIG" "jekyll_start"
    info "Starting Jekyll Server..." "jekyll_start"
    bundle exec jekyll serve $CONFIG --host 0.0.0.0 --port 4000 -s /home/builder/app -d /home/builder/output 2>&1 | while IFS= read -r line; do
        info "$line" "jekyll_start"
    done
}
