LOG_FILE="/home/builder/metadata/build_docs_$(date +'%Y-%m-%d %H:%M:%S').log"
LOG_LEVEL=INFO
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    local level=$1
    local message=$2
    local function=$3
    local levels=("DEBUG" "INFO" "WARN" "ERROR")
    [[ ! " ${levels[@]} " =~ " ${level} " ]] && return
    [[ " ${levels[@]} " =~ " ${LOG_LEVEL} " && "${levels[*]/*$LOG_LEVEL*}" =~ "$level" ]] && return
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$level] [$function] $message" | tee -a "$LOG_FILE"
}

info() { log "INFO" "$1" "$2"; }
warn() { log "WARN" "$1" "$2"; }
error() { log "ERROR" "$1" "$2"; }
debug() { log "DEBUG" "$1" "$2"; }


log_function_start () {
    local color=$1
    local function_name=$2
    echo -e "${color}======================================${NC}\n${color}STARTING: ${function_name}${NC}\n${color}--------------------------------------${NC}\n${color}Current Directory: $(pwd)${NC}\n${color}Active User: $(whoami)${NC}\n${color}--------------------------------------${NC}"
}
