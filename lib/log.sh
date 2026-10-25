LOG_FILE="${LOG_FILE:-$BASE_DIR/logs/backup.log}"

catat() {
    level=$1
    shift
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $*" >> "$LOG_FILE"
    echo "[$level] $*"
}