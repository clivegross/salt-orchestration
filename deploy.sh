#!/bin/bash
# Salt Configuration Deployment Script
# Copies local salt and pillar directories to Salt master

set -e  # Exit on any error

# Configuration variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SALT_DIR="${SCRIPT_DIR}/salt"
LOCAL_PILLAR_DIR="${SCRIPT_DIR}/pillar"
TARGET_SALT_DIR="/srv/salt"
TARGET_PILLAR_DIR="/srv/pillar"
BACKUP_DIR="/srv/backups/salt-$(date +%Y%m%d_%H%M%S)"
SALT_CONFIG_DIR="/etc/salt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_directories() {
    if [ ! -d "$LOCAL_SALT_DIR" ]; then
        log_error "Local salt directory not found: $LOCAL_SALT_DIR"
        exit 1
    fi
    
    if [ ! -d "$LOCAL_PILLAR_DIR" ]; then
        log_error "Local pillar directory not found: $LOCAL_PILLAR_DIR"
        exit 1
    fi
    
    log_info "Found local directories:"
    log_info "  Salt: $LOCAL_SALT_DIR"
    log_info "  Pillar: $LOCAL_PILLAR_DIR"
}

backup_existing() {
    log_info "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$TARGET_SALT_DIR" ]; then
        log_info "Backing up existing salt directory..."
        cp -r "$TARGET_SALT_DIR" "$BACKUP_DIR/salt"
        log_success "Salt directory backed up"
    fi
    
    if [ -d "$TARGET_PILLAR_DIR" ]; then
        log_info "Backing up existing pillar directory..."
        cp -r "$TARGET_PILLAR_DIR" "$BACKUP_DIR/pillar"
        log_success "Pillar directory backed up"
    fi
    
    if [ -f "$SALT_CONFIG_DIR/master" ]; then
        log_info "Backing up master configuration..."
        cp "$SALT_CONFIG_DIR/master" "$BACKUP_DIR/master.conf"
        log_success "Master config backed up"
    fi
}

deploy_salt() {
    log_info "Deploying Salt states..."
    
    # Create target directory if it doesn't exist
    mkdir -p "$TARGET_SALT_DIR"
    
    # Copy salt files
    cp -r "$LOCAL_SALT_DIR"/* "$TARGET_SALT_DIR/"
    
    # Set ownership and permissions
    chown -R root:root "$TARGET_SALT_DIR"
    chmod -R 755 "$TARGET_SALT_DIR"
    
    log_success "Salt states deployed to $TARGET_SALT_DIR"
}

deploy_pillar() {
    log_info "Deploying Pillar data..."
    
    # Create target directory if it doesn't exist
    mkdir -p "$TARGET_PILLAR_DIR"
    
    # Copy pillar files
    cp -r "$LOCAL_PILLAR_DIR"/* "$TARGET_PILLAR_DIR/"
    
    # Set ownership and permissions (more restrictive for pillar)
    chown -R root:root "$TARGET_PILLAR_DIR"
    chmod -R 750 "$TARGET_PILLAR_DIR"
    find "$TARGET_PILLAR_DIR" -type f -exec chmod 640 {} \;
    
    log_success "Pillar data deployed to $TARGET_PILLAR_DIR"
}

deploy_master_d_configs() {
    local SRC_DIR="${SCRIPT_DIR}/config/master.d"
    local DEST_DIR="${SALT_CONFIG_DIR}/master.d"

    if [ -d "$SRC_DIR" ]; then
        log_info "Deploying master.d configurations from $SRC_DIR to $DEST_DIR..."
        mkdir -p "$DEST_DIR"
        cp -r "$SRC_DIR"/* "$DEST_DIR/"
        chown -R root:root "$DEST_DIR"
        chmod -R 755 "$DEST_DIR"
        log_success "master.d configurations deployed"
    else
        log_warning "No config/master.d directory found, skipping master.d config deployment"
    fi
}

update_master_config() {
    local master_config="$SALT_CONFIG_DIR/master"
    
    if [ -f "${SCRIPT_DIR}/config/master.conf" ]; then
        log_info "Updating master configuration..."
        cp "${SCRIPT_DIR}/config/master.conf" "$master_config"
        chown root:root "$master_config"
        chmod 644 "$master_config"
        log_success "Master configuration updated"
    else
        log_warning "No master.conf found in config directory, skipping..."
        
        # Ensure basic configuration exists
        if [ ! -f "$master_config" ]; then
            log_info "Creating basic master configuration..."
            cat > "$master_config" << EOF
# Basic Salt Master Configuration
interface: 0.0.0.0
publish_port: 4505
ret_port: 4506

file_roots:
  base:
    - $TARGET_SALT_DIR

pillar_roots:
  base:
    - $TARGET_PILLAR_DIR

auto_accept: False
pki_dir: $SALT_CONFIG_DIR/pki/master

log_file: /var/log/salt/master
log_level_logfile: info

worker_threads: 5
timeout: 5
gather_job_timeout: 10
EOF
            chown root:root "$master_config"
            chmod 644 "$master_config"
            log_success "Basic master configuration created"
        fi
    fi
}

validate_deployment() {
    log_info "Validating deployment..."
    
    # Check if top.sls exists
    if [ -f "$TARGET_SALT_DIR/top.sls" ]; then
        log_success "Salt top.sls found"
    else
        log_warning "No top.sls found in salt directory"
    fi
    
    if [ -f "$TARGET_PILLAR_DIR/top.sls" ]; then
        log_success "Pillar top.sls found"
    else
        log_warning "No top.sls found in pillar directory"
    fi
    
    # Test salt master configuration
    if command -v salt >/dev/null 2>&1; then
        log_info "Testing Salt master configuration..."
        if salt-call --local test.ping >/dev/null 2>&1; then
            log_success "Salt configuration test passed"
        else
            log_warning "Salt configuration test failed"
        fi
    else
        log_warning "Salt not installed, skipping configuration test"
    fi
}

restart_services() {
    if systemctl is-active --quiet salt-master; then
        log_info "Restarting Salt master service..."
        systemctl restart salt-master
        
        # Wait a moment and check status
        sleep 2
        if systemctl is-active --quiet salt-master; then
            log_success "Salt master restarted successfully"
        else
            log_error "Salt master failed to restart"
            log_info "Check logs: journalctl -u salt-master -f"
            return 1
        fi
    else
        log_warning "Salt master service not running, attempting to start..."
        if systemctl start salt-master; then
            log_success "Salt master started"
        else
            log_error "Failed to start Salt master"
            return 1
        fi
    fi
}

show_summary() {
    log_info "Deployment Summary:"
    echo "  Salt states deployed to: $TARGET_SALT_DIR"
    echo "  Pillar data deployed to: $TARGET_PILLAR_DIR"
    echo "  Backup created at: $BACKUP_DIR"
    echo ""
    log_info "Next steps:"
    echo "  1. Accept minion keys: salt-key -A"
    echo "  2. Test connectivity: salt '*' test.ping"
    echo "  3. Apply states: salt '*' state.apply"
    echo ""
    log_info "Useful commands:"
    echo "  - Check master status: systemctl status salt-master"
    echo "  - View master logs: journalctl -u salt-master -f"
    echo "  - Test state compilation: salt '*' state.show_top"
}

# Main execution
main() {
    log_info "Starting Salt configuration deployment..."
    
    check_root
    check_directories
    backup_existing
    deploy_salt
    deploy_pillar
    update_master_config
    deploy_master_d_configs
    validate_deployment
    restart_services
    show_summary
    
    log_success "Salt configuration deployment completed!"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --dry-run      Show what would be done without making changes"
        echo "  --no-backup    Skip backup creation"
        echo "  --no-restart   Skip service restart"
        echo ""
        echo "This script copies local salt and pillar directories to the Salt master."
        echo "Run from the directory containing your salt/ and pillar/ folders."
        exit 0
        ;;
    --dry-run)
        log_info "DRY RUN MODE - No changes will be made"
        echo "Would copy:"
        echo "  $LOCAL_SALT_DIR -> $TARGET_SALT_DIR"
        echo "  $LOCAL_PILLAR_DIR -> $TARGET_PILLAR_DIR"
        echo "Would create backup at: $BACKUP_DIR"
        exit 0
        ;;
    --no-backup)
        backup_existing() { log_info "Skipping backup as requested"; }
        main
        ;;
    --no-restart)
        restart_services() { log_info "Skipping service restart as requested"; }
        main
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac