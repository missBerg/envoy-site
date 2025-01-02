source /home/builder/envoy-site/scripts/functions/logging.sh
apk add --no-cache inotify-tools rsync &&

info "Syncing site contents..." "jekyll_start"
while true; do
    inotifywait -r -e modify,create,delete,move /home/builder/envoy-site &&
    rsync -ah --info=progress2 --no-perms --no-owner --no-group --delete --exclude='docs' --exclude='_site' --exclude='.git' /home/builder/app/
done
