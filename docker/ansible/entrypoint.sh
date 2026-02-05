#!/bin/bash
# entrypoint.sh - Secrets management with local dev fallback

# Exit on error, affects variables and unmasked errors.
set -euo pipefail

# ==============================================================================
# CONFIGURATION
# ==============================================================================

readonly SSH_KEY_PATH="/root/.ssh/id_rsa"
readonly SSH_DIR="/root/.ssh"
readonly LOG_PREFIX="[ENTRYPOINT]"

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
# KNOWN HOSTS SETUP
# ==============================================================================

setup_known_hosts() {
    local known_hosts=""
    local source="unknown"
    
    # Priority 1: Environment Variable (CI/CD or Local Dev)
    if [ -n "${SSH_KNOWN_HOSTS:-}" ]; then
        known_hosts="${SSH_KNOWN_HOSTS}"
        source="Environment Variable"
    fi
    
    if [ -n "${known_hosts}" ]; then
        log_info "Installing known hosts from: ${source}"
        echo "${known_hosts}" > "${SSH_DIR}/known_hosts"
        chmod 600 "${SSH_DIR}/known_hosts"
        log_success "Known hosts installed successfully from: ${source}"
    else
        # Disable strict host key checking if no known_hosts provided
        log_warn "No known hosts provided - disabling strict host key checking"
        export ANSIBLE_HOST_KEY_CHECKING=False
    fi
}

# ==============================================================================
# SSH KEY SETUP
# ==============================================================================

setup_ssh_key() {
    local ssh_key=""
    local source="unknown"

    # Priority 1: Environment Variable (CI/CD or Local Dev)
    if [ -z "${ssh_key}" ] && [ -n "${SSH_PRIVATE_KEY:-}" ]; then
        ssh_key="${SSH_PRIVATE_KEY}"
        source="Environment Variable"
    fi
    
    # Validate and install SSH key
    if [ -n "${ssh_key}" ]; then
        log_info "Installing SSH key from: ${source}"
        
        # Create SSH directory with correct permissions
        mkdir -p "${SSH_DIR}"
        chmod 700 "${SSH_DIR}"
        
        # Write SSH key
        echo "${ssh_key}" > "${SSH_KEY_PATH}"
        chmod 600 "${SSH_KEY_PATH}"
        
        # Validate SSH key format
        if ! ssh-keygen -l -f "${SSH_KEY_PATH}" >/dev/null 2>&1; then
            fatal_error "Invalid SSH key format from ${source}"
        fi
        
        log_success "SSH key installed successfully from ${source}"
        return 0
    else
        log_warn "No SSH key provided - SSH authentication will not be available"
        return 1
    fi
}

# ==============================================================================
# HEALTHCHECK & VALIDATION
# ==============================================================================

validate_environment() {
    log_info "Validating environment..."
    
    # Check Ansible installation
    if ! command -v ansible-playbook >/dev/null 2>&1; then
        fatal_error "ansible-playbook not found in PATH"
    fi
    
    # Check working directory
    if [ ! -d "/ansible" ]; then
        log_warn "Working directory /ansible not found"
    fi
    
    log_success "Environment validation passed"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    log_info "Starting Ansible container entrypoint..."
    log_info "Environment: ${ENVIRONMENT:-development}"
    
    # Validate environment
    validate_environment
    
    # Setup SSH authentication
    setup_ssh_key || true  # Don't fail if no SSH key (might not be needed)
    
    # Setup known hosts
    setup_known_hosts
    
    log_success "Initialization complete"
    log_info "Executing: $*"
    
    # Execute the command in argument
    exec "$@"
}

# ==============================================================================
# EXECUTE
# ==============================================================================

main "$@"