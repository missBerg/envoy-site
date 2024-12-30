ruby_setup (){

    log_function_start "${RED}" "ruby_setup"
    info "Create bundle cache location if it doesn't already exist..." "ruby_setup"

    if [ ! -d "/home/builder/tools/.bundle" ]; then
        mkdir /home/builder/tools/.bundle
    fi

    if [ ! -d "/home/builder/tools/.bundle/gems" ]; then
        mkdir /home/builder/tools/.bundle/gems
    fi

    ls -lrt /home/builder/tools/.bundle
    bundle config set cache_path /home/builder/tools/.bundle/cache

    info "Remove Gemfile.lock..." "ruby_setup"
    rm -f Gemfile.lock
}

gem_install (){
    log_function_start "${RED}" "gem_install"
    
    info "Gem Bundle install..." "gem_install"

    bundle config set path '/home/builder/tools/.bundle/gems'
        # Run the command and process its output
    bundle install 2>&1 | while IFS= read -r line; do
        log "$level" "$line" "gem_install - bundle install"
    done
}
