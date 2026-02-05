#!/bin/bash
# run.sh - Local development helper

# Exit on error, affects variables and unmasked errors.
set -euo pipefail

# ==============================================================================
# CONFIGURATION
# ==============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ENV_FILE="${SCRIPT_DIR}/config/.env"
readonly LOG_PREFIX="[RUNNER]"

# ==============================================================================
# LOGGING
# ==============================================================================

log_info() {
    echo "${LOG_PREFIX} ℹ️  $*" >&2
}

log_success() {
    echo "${LOG_PREFIX} ✅ $*" >&2
}

log_warn() {
    echo "${LOG_PREFIX} ⚠️  $*" >&2
}

log_error() {
    echo "${LOG_PREFIX} ❌ $*" >&2
}

fatal_error() {
    log_error "$*"
    exit 1
}

# ==============================================================================
# LOAD SSH KEY FROM FILE
# ==============================================================================

load_ssh_key() {
    if [ -z "${SSH_KEY_PATH:-}" ]; then
        log_warn "SSH_KEY_PATH not set - SSH authentication will not be available"
        return 1
    fi
    
    # Expand tilde (~) to home directory
    local ssh_key_path_expanded="$(eval echo "$SSH_KEY_PATH")"
    
    if [ ! -f "$ssh_key_path_expanded" ]; then
        fatal_error "SSH key not found: $ssh_key_path_expanded"
    fi
    
    if [ ! -r "$ssh_key_path_expanded" ]; then
        fatal_error "SSH key not readable: $ssh_key_path_expanded"
    fi
    
    # Load the SSH key content into environment variable
    export SSH_PRIVATE_KEY="$(cat "$ssh_key_path_expanded")"
    log_info "SSH key loaded from: $SSH_KEY_PATH"
    
    return 0
}

# ==============================================================================
# LOAD ENVIRONMENT FILES
# ==============================================================================

load_env_file() {
    local env_file="$1"
    
    if [ ! -f "$env_file" ]; then
        return 1
    fi
    
    # Export variables
    set -a
    source "$env_file"
    set +a
    
    return 0
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    log_info "Ansible Docker - Local Development Environment"
    echo ""
    
    # Load configuration files
    if load_env_file "$ENV_FILE"; then
        log_info "Configuration loaded from: config/.env"
    else
        log_warn "Configuration file not found: config/.env"
    fi
    
    echo ""
    
    # Load SSH key if configured
    load_ssh_key || true  # Don't fail if SSH key is not needed
    
    echo ""
    log_info "Starting Docker Compose..."
    echo ""
    
    # Execute docker-compose with all arguments passed to this script
    docker-compose run --rm ansible "$@"
}

# ==============================================================================
# EXECUTE
# ==============================================================================

main "$@"