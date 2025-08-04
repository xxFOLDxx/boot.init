#!/bin/bash
set -euo pipefail

# Linux Boot Automation Setup Script
# Interactive setup for various boot automation methods

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
USER_HOME="$HOME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
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

print_header() {
    echo -e "${BLUE}"
    echo "========================================="
    echo "  Linux Boot Automation Setup"
    echo "========================================="
    echo -e "${NC}"
    echo "This script helps you set up automatic startup"
    echo "programs and tasks for your Linux machine."
    echo ""
}

print_menu() {
    echo "Available setup options:"
    echo ""
    echo "1. Systemd Services    - Modern service management"
    echo "2. Desktop Autostart   - GUI application startup"
    echo "3. Shell Scripts       - Terminal environment setup"
    echo "4. Cron Jobs          - Scheduled and boot tasks"
    echo "5. Init Scripts       - Legacy system services"
    echo "6. Full Setup         - Install everything"
    echo "7. Custom Setup       - Choose specific components"
    echo "8. Uninstall          - Remove installed components"
    echo "9. Status Check       - Check current setup"
    echo "0. Exit"
    echo ""
}

check_requirements() {
    local missing_tools=()
    
    # Check for required tools
    if ! command -v systemctl >/dev/null 2>&1; then
        missing_tools+=("systemd")
    fi
    
    if ! command -v crontab >/dev/null 2>&1; then
        missing_tools+=("cron")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_warning "Missing tools: ${missing_tools[*]}"
        echo "Some features may not be available."
        echo ""
    fi
}

setup_systemd_services() {
    log_info "Setting up systemd services..."
    
    if [ ! -d "$SCRIPT_DIR/systemd-services" ]; then
        log_error "Systemd services directory not found"
        return 1
    fi
    
    cd "$SCRIPT_DIR/systemd-services"
    
    if [ -f "manage-services.sh" ]; then
        chmod +x manage-services.sh
        
        echo "Available systemd services:"
        ./manage-services.sh list
        echo ""
        
        read -p "Install all services? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for service in *.service; do
                if [ -f "$service" ]; then
                    echo "Installing $service..."
                    ./manage-services.sh install "$service" || log_warning "Failed to install $service"
                fi
            done
            log_success "Systemd services setup complete"
        else
            echo "You can install services manually using:"
            echo "  cd $SCRIPT_DIR/systemd-services"
            echo "  ./manage-services.sh install <service-name>"
        fi
    else
        log_error "Service management script not found"
        return 1
    fi
}

setup_desktop_autostart() {
    log_info "Setting up desktop autostart..."
    
    if [ ! -d "$SCRIPT_DIR/desktop-autostart" ]; then
        log_error "Desktop autostart directory not found"
        return 1
    fi
    
    # Check if running in a graphical environment
    if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
        log_warning "No graphical environment detected"
        echo "Desktop autostart requires a graphical desktop environment."
        read -p "Continue anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    cd "$SCRIPT_DIR/desktop-autostart"
    
    if [ -f "install-autostart.sh" ]; then
        chmod +x install-autostart.sh
        
        echo "Available desktop applications:"
        ./install-autostart.sh list
        echo ""
        
        read -p "Install all autostart entries? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ./install-autostart.sh install
            log_success "Desktop autostart setup complete"
        else
            echo "You can install entries manually using:"
            echo "  cd $SCRIPT_DIR/desktop-autostart"
            echo "  ./install-autostart.sh enable <app-name>"
        fi
    else
        log_error "Autostart installation script not found"
        return 1
    fi
}

setup_shell_scripts() {
    log_info "Setting up shell scripts..."
    
    if [ ! -d "$SCRIPT_DIR/shell-scripts" ]; then
        log_error "Shell scripts directory not found"
        return 1
    fi
    
    # Detect current shell
    local current_shell="$(basename "$SHELL")"
    log_info "Detected shell: $current_shell"
    
    local fish_config_dir="$USER_HOME/.config/fish"
    local fish_config_file="$fish_config_dir/config.fish"
    local fish_conf_dir="$fish_config_dir/conf.d"
    
    case "$current_shell" in
        fish)
            echo "Setting up Fish shell configuration..."
            
            # Create Fish config directories
            mkdir -p "$fish_config_dir" "$fish_conf_dir"
            
            # Install main Fish config
            if [ -f "$SCRIPT_DIR/shell-scripts/fish-config.fish" ]; then
                read -p "Install Fish shell configuration? (y/N): " -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    if [ -f "$fish_config_file" ]; then
                        cp "$fish_config_file" "$fish_config_file.backup.$(date +%Y%m%d_%H%M%S)"
                        log_info "Backed up existing config.fish"
                    fi
                    
                    cp "$SCRIPT_DIR/shell-scripts/fish-config.fish" "$fish_config_file"
                    log_success "Fish configuration installed"
                fi
            fi
            
            # Install development aliases
            if [ -f "$SCRIPT_DIR/shell-scripts/dev-aliases.fish" ]; then
                read -p "Install development aliases? (y/N): " -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    cp "$SCRIPT_DIR/shell-scripts/dev-aliases.fish" "$fish_conf_dir/"
                    log_success "Development aliases installed"
                fi
            fi
            ;;
        
        bash)
            echo "Setting up Bash configuration..."
            
            if [ -f "$SCRIPT_DIR/shell-scripts/bashrc-example" ]; then
                read -p "Install Bash configuration? (y/N): " -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    if [ -f "$USER_HOME/.bashrc" ]; then
                        cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
                        log_info "Backed up existing .bashrc"
                    fi
                    
                    cp "$SCRIPT_DIR/shell-scripts/bashrc-example" "$USER_HOME/.bashrc"
                    log_success "Bash configuration installed"
                fi
            fi
            ;;
        
        *)
            log_warning "Unsupported shell: $current_shell"
            echo "You can manually copy configuration files from:"
            echo "  $SCRIPT_DIR/shell-scripts/"
            ;;
    esac
    
    echo ""
    echo "Shell configuration installed. Changes will take effect in new terminal sessions."
    echo "To apply immediately, run: source ~/.config/fish/config.fish (Fish) or source ~/.bashrc (Bash)"
}

setup_cron_jobs() {
    log_info "Setting up cron jobs..."
    
    if [ ! -d "$SCRIPT_DIR/cron-jobs" ]; then
        log_error "Cron jobs directory not found"
        return 1
    fi
    
    # Check if cron is available
    if ! command -v crontab >/dev/null 2>&1; then
        log_error "Cron is not installed or not available"
        return 1
    fi
    
    echo "Available cron job examples:"
    ls -1 "$SCRIPT_DIR/cron-jobs"/*.cron 2>/dev/null | while read -r cronfile; do
        echo "  $(basename "$cronfile")"
    done
    echo ""
    
    log_warning "Cron job installation requires manual review and customization."
    echo "Please review the example files in $SCRIPT_DIR/cron-jobs/"
    echo "and add the entries you want to your crontab using: crontab -e"
    echo ""
    
    read -p "Open cron examples directory? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$SCRIPT_DIR/cron-jobs"
        else
            echo "Directory: $SCRIPT_DIR/cron-jobs"
        fi
    fi
}

setup_init_scripts() {
    log_info "Setting up init scripts..."
    
    if [ ! -d "$SCRIPT_DIR/init-scripts" ]; then
        log_error "Init scripts directory not found"
        return 1
    fi
    
    # Check if this is a systemd system
    if command -v systemctl >/dev/null 2>&1; then
        log_warning "This system uses systemd."
        echo "Init scripts are legacy and not recommended for systemd systems."
        echo "Consider using systemd services instead."
        echo ""
        
        read -p "Continue with init scripts anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    echo "Available init scripts:"
    ls -1 "$SCRIPT_DIR/init-scripts" | grep -v README.md || echo "  No init scripts found"
    echo ""
    
    log_warning "Init script installation requires root privileges and manual configuration."
    echo "Please review the scripts in $SCRIPT_DIR/init-scripts/"
    echo "and install them manually if needed."
}

check_status() {
    log_info "Checking boot automation status..."
    echo ""
    
    # Check systemd services
    echo "Systemd Services:"
    if command -v systemctl >/dev/null 2>&1; then
        local services_found=false
        for service in web-server backup-service development-env monitoring network-mount; do
            if systemctl list-unit-files "$service.service" >/dev/null 2>&1; then
                local status="$(systemctl is-enabled "$service.service" 2>/dev/null || echo "disabled")"
                echo "  $service.service: $status"
                services_found=true
            fi
        done
        if [ "$services_found" = false ]; then
            echo "  No custom services found"
        fi
    else
        echo "  Systemd not available"
    fi
    echo ""
    
    # Check desktop autostart
    echo "Desktop Autostart:"
    local autostart_dir="$USER_HOME/.config/autostart"
    if [ -d "$autostart_dir" ]; then
        local count="$(find "$autostart_dir" -name "*.desktop" | wc -l)"
        echo "  $count desktop entries found in $autostart_dir"
        if [ "$count" -gt 0 ]; then
            find "$autostart_dir" -name "*.desktop" -exec basename {} \; | sed 's/^/    /'
        fi
    else
        echo "  No autostart directory found"
    fi
    echo ""
    
    # Check cron jobs
    echo "Cron Jobs:"
    if command -v crontab >/dev/null 2>&1; then
        local cron_count="$(crontab -l 2>/dev/null | grep -v '^#' | grep -c '@reboot' || echo "0")"
        echo "  $cron_count @reboot entries found"
        if [ "$cron_count" -gt 0 ]; then
            echo "  Use 'crontab -l' to view all entries"
        fi
    else
        echo "  Cron not available"
    fi
    echo ""
    
    # Check shell configuration
    echo "Shell Configuration:"
    local current_shell="$(basename "$SHELL")"
    echo "  Current shell: $current_shell"
    
    case "$current_shell" in
        fish)
            if [ -f "$USER_HOME/.config/fish/config.fish" ]; then
                echo "  Fish configuration: found"
            else
                echo "  Fish configuration: not found"
            fi
            ;;
        bash)
            if [ -f "$USER_HOME/.bashrc" ]; then
                echo "  Bash configuration: found"
            else
                echo "  Bash configuration: not found"
            fi
            ;;
        *)
            echo "  Configuration: unknown shell"
            ;;
    esac
}

uninstall_components() {
    log_warning "Uninstalling boot automation components..."
    echo ""
    echo "This will remove installed components. Proceed carefully."
    echo ""
    
    read -p "Remove systemd services? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "$SCRIPT_DIR/systemd-services/manage-services.sh" ]; then
            cd "$SCRIPT_DIR/systemd-services"
            for service in *.service; do
                if [ -f "$service" ]; then
                    ./manage-services.sh remove "$service" 2>/dev/null || true
                fi
            done
            log_success "Systemd services removed"
        fi
    fi
    
    read -p "Remove desktop autostart entries? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "$SCRIPT_DIR/desktop-autostart/install-autostart.sh" ]; then
            cd "$SCRIPT_DIR/desktop-autostart"
            ./install-autostart.sh remove
            log_success "Desktop autostart entries removed"
        fi
    fi
    
    read -p "Remove shell configurations? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_warning "This will remove your shell configuration files!"
        read -p "Are you sure? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Restore backups if they exist
            local current_shell="$(basename "$SHELL")"
            case "$current_shell" in
                fish)
                    local backup="$(find "$USER_HOME/.config/fish" -name "config.fish.backup.*" | sort | tail -1)"
                    if [ -n "$backup" ]; then
                        mv "$backup" "$USER_HOME/.config/fish/config.fish"
                        log_success "Fish configuration restored from backup"
                    else
                        rm -f "$USER_HOME/.config/fish/config.fish"
                        log_success "Fish configuration removed"
                    fi
                    rm -f "$USER_HOME/.config/fish/conf.d/dev-aliases.fish"
                    ;;
                bash)
                    local backup="$(find "$USER_HOME" -name ".bashrc.backup.*" | sort | tail -1)"
                    if [ -n "$backup" ]; then
                        mv "$backup" "$USER_HOME/.bashrc"
                        log_success "Bash configuration restored from backup"
                    else
                        log_warning "No backup found, keeping current .bashrc"
                    fi
                    ;;
            esac
        fi
    fi
    
    echo ""
    log_info "Uninstallation complete"
    echo "Note: Cron jobs and init scripts require manual removal"
}

custom_setup() {
    log_info "Custom setup - choose components to install..."
    echo ""
    
    local choices=()
    
    echo "Select components to install (space-separated numbers):"
    echo "1. Systemd Services"
    echo "2. Desktop Autostart"
    echo "3. Shell Scripts"
    echo "4. Cron Jobs"
    echo "5. Init Scripts"
    echo ""
    
    read -p "Enter choices (e.g., 1 3 4): " -r choices_input
    read -ra choices <<< "$choices_input"
    
    for choice in "${choices[@]}"; do
        case $choice in
            1) setup_systemd_services ;;
            2) setup_desktop_autostart ;;
            3) setup_shell_scripts ;;
            4) setup_cron_jobs ;;
            5) setup_init_scripts ;;
            *) log_warning "Invalid choice: $choice" ;;
        esac
        echo ""
    done
    
    log_success "Custom setup complete"
}

full_setup() {
    log_info "Full setup - installing all components..."
    echo ""
    
    setup_systemd_services
    echo ""
    setup_desktop_autostart
    echo ""
    setup_shell_scripts
    echo ""
    setup_cron_jobs
    echo ""
    setup_init_scripts
    echo ""
    
    log_success "Full setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Review and customize the installed configurations"
    echo "2. Restart your system or log out/in to test autostart"
    echo "3. Check the status with: $0 and choose option 9"
}

main() {
    print_header
    check_requirements
    
    while true; do
        print_menu
        read -p "Choose an option (0-9): " -r choice
        echo ""
        
        case $choice in
            1) setup_systemd_services ;;
            2) setup_desktop_autostart ;;
            3) setup_shell_scripts ;;
            4) setup_cron_jobs ;;
            5) setup_init_scripts ;;
            6) full_setup ;;
            7) custom_setup ;;
            8) uninstall_components ;;
            9) check_status ;;
            0) 
                log_info "Goodbye!"
                exit 0
                ;;
            *)
                log_error "Invalid option. Please choose 0-9."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..." -r
        echo ""
    done
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
