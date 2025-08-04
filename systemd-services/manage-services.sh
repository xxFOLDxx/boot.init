#!/bin/bash
set -euo pipefail

# Systemd Service Management Script
# Usage: ./manage-services.sh [install|remove|status|logs] [service-name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_SERVICE_DIR="/etc/systemd/system"
USER_SERVICE_DIR="$HOME/.config/systemd/user"

print_usage() {
    echo "Usage: $0 [install|remove|status|logs|list] [service-name]"
    echo ""
    echo "Commands:"
    echo "  install <service>  - Install and enable a service"
    echo "  remove <service>   - Disable and remove a service"
    echo "  status <service>   - Show service status"
    echo "  logs <service>     - Show service logs"
    echo "  list               - List available services"
    echo ""
    echo "Options:"
    echo "  --user            - Use user services instead of system services"
    echo "  --dry-run         - Show what would be done without executing"
}

install_service() {
    local service_file="$1"
    local service_name="$(basename "$service_file")"
    local target_dir
    local systemctl_cmd="systemctl"
    
    if [[ "$USE_USER_SERVICE" == "true" ]]; then
        target_dir="$USER_SERVICE_DIR"
        systemctl_cmd="systemctl --user"
        mkdir -p "$target_dir"
    else
        target_dir="$SYSTEM_SERVICE_DIR"
    fi
    
    echo "Installing service: $service_name"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would copy: $service_file -> $target_dir/$service_name"
        echo "Would run: $systemctl_cmd daemon-reload"
        echo "Would run: $systemctl_cmd enable $service_name"
        echo "Would run: $systemctl_cmd start $service_name"
        return
    fi
    
    # Copy service file
    if [[ "$USE_USER_SERVICE" == "true" ]]; then
        cp "$service_file" "$target_dir/"
    else
        sudo cp "$service_file" "$target_dir/"
    fi
    
    # Reload systemd and enable service
    if [[ "$USE_USER_SERVICE" == "true" ]]; then
        systemctl --user daemon-reload
        systemctl --user enable "$service_name"
        echo "Service $service_name installed and enabled (user service)"
        echo "Start with: systemctl --user start $service_name"
    else
        sudo systemctl daemon-reload
        sudo systemctl enable "$service_name"
        echo "Service $service_name installed and enabled (system service)"
        echo "Start with: sudo systemctl start $service_name"
    fi
}

remove_service() {
    local service_name="$1"
    local systemctl_cmd="systemctl"
    local target_dir
    
    if [[ "$USE_USER_SERVICE" == "true" ]]; then
        target_dir="$USER_SERVICE_DIR"
        systemctl_cmd="systemctl --user"
    else
        target_dir="$SYSTEM_SERVICE_DIR"
    fi
    
    echo "Removing service: $service_name"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would run: $systemctl_cmd stop $service_name"
        echo "Would run: $systemctl_cmd disable $service_name"
        echo "Would remove: $target_dir/$service_name"
        echo "Would run: $systemctl_cmd daemon-reload"
        return
    fi
    
    # Stop and disable service
    if [[ "$USE_USER_SERVICE" == "true" ]]; then
        systemctl --user stop "$service_name" 2>/dev/null || true
        systemctl --user disable "$service_name" 2>/dev/null || true
        rm -f "$target_dir/$service_name"
        systemctl --user daemon-reload
    else
        sudo systemctl stop "$service_name" 2>/dev/null || true
        sudo systemctl disable "$service_name" 2>/dev/null || true
        sudo rm -f "$target_dir/$service_name"
        sudo systemctl daemon-reload
    fi
    
    echo "Service $service_name removed"
}

show_status() {
    local service_name="$1"
    
    if [[ "$USE_USER_SERVICE" == "true" ]]; then
        systemctl --user status "$service_name"
    else
        systemctl status "$service_name"
    fi
}

show_logs() {
    local service_name="$1"
    
    if [[ "$USE_USER_SERVICE" == "true" ]]; then
        journalctl --user -u "$service_name" -f
    else
        journalctl -u "$service_name" -f
    fi
}

list_services() {
    echo "Available service files in $SCRIPT_DIR:"
    echo ""
    for service in "$SCRIPT_DIR"/*.service; do
        if [[ -f "$service" ]]; then
            local name="$(basename "$service")"
            local desc="$(grep "^Description=" "$service" | cut -d'=' -f2-)"
            printf "  %-30s %s\n" "$name" "$desc"
        fi
    done
}

# Parse arguments
USE_USER_SERVICE="false"
DRY_RUN="false"
COMMAND=""
SERVICE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            USE_USER_SERVICE="true"
            shift
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        install|remove|status|logs|list)
            COMMAND="$1"
            shift
            ;;
        *)
            if [[ -z "$SERVICE" ]]; then
                SERVICE="$1"
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$COMMAND" ]]; then
    print_usage
    exit 1
fi

case "$COMMAND" in
    install)
        if [[ -z "$SERVICE" ]]; then
            echo "Error: Service name required for install command"
            exit 1
        fi
        
        service_file="$SCRIPT_DIR/$SERVICE"
        if [[ ! -f "$service_file" ]]; then
            echo "Error: Service file not found: $service_file"
            exit 1
        fi
        
        install_service "$service_file"
        ;;
    
    remove)
        if [[ -z "$SERVICE" ]]; then
            echo "Error: Service name required for remove command"
            exit 1
        fi
        remove_service "$SERVICE"
        ;;
    
    status)
        if [[ -z "$SERVICE" ]]; then
            echo "Error: Service name required for status command"
            exit 1
        fi
        show_status "$SERVICE"
        ;;
    
    logs)
        if [[ -z "$SERVICE" ]]; then
            echo "Error: Service name required for logs command"
            exit 1
        fi
        show_logs "$SERVICE"
        ;;
    
    list)
        list_services
        ;;
    
    *)
        echo "Error: Unknown command: $COMMAND"
        print_usage
        exit 1
        ;;
esac
