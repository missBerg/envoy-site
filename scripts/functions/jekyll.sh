
jekyll_start (){
    log_function_start "${GREEN}" "jekyll_start"
    # bundle exec jekyll build --trace
    info "Starting Jekyll Server..." "jekyll_start"
    
    bundle exec jekyll serve --host 0.0.0.0 --port 4000 2>&1 | while IFS= read -r line; do
        info "$line" "jekyll_start - jekyll serve"
    done
}
