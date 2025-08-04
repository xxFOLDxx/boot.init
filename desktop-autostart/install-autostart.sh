#!/bin/bash
set -euo pipefail

# Desktop Autostart Installation Script
# Usage: ./install-autostart.sh [remove]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTOSTART_DIR="$HOME/.config/autostart"

print_usage() {
    echo "Usage: $0 [remove|list|enable|disable] [app-name]"
    echo ""
    echo "Commands:"
    echo "  install           - Install all desktop entries (default)"
    echo "  remove            - Remove all installed desktop entries"
    echo "  list              - List available and installed entries"
    echo "  enable <app>      - Enable specific autostart entry"
    echo "  disable <app>     - Disable specific autostart entry"
    echo ""
    echo "Examples:"
    echo "  $0                - Install all autostart entries"
    echo "  $0 remove         - Remove all autostart entries"
    echo "  $0 disable terminal - Disable terminal autostart"
    echo "  $0 enable browser - Enable browser autostart"
}

install_entries() {
    echo "Installing desktop autostart entries..."
    
    # Create autostart directory if it doesn't exist
    mkdir -p "$AUTOSTART_DIR"
    
    local installed=0
    local skipped=0
    
    for desktop_file in "$SCRIPT_DIR"/*.desktop; do
        if [[ -f "$desktop_file" ]]; then
            local filename="$(basename "$desktop_file")"
            local target="$AUTOSTART_DIR/$filename"
            
            if [[ -f "$target" ]]; then
                echo "  $filename - already exists, skipping"
                ((skipped++))
            else
                cp "$desktop_file" "$target"
                chmod 644 "$target"
                echo "  $filename - installed"
                ((installed++))
            fi
        fi
    done
    
    echo ""
    echo "Installation complete:"
    echo "  Installed: $installed"
    echo "  Skipped: $skipped"
    echo ""
    echo "Autostart entries will take effect on next login."
}

remove_entries() {
    echo "Removing desktop autostart entries..."
    
    if [[ ! -d "$AUTOSTART_DIR" ]]; then
        echo "Autostart directory doesn't exist: $AUTOSTART_DIR"
        return
    fi
    
    local removed=0
    
    for desktop_file in "$SCRIPT_DIR"/*.desktop; do
        if [[ -f "$desktop_file" ]]; then
            local filename="$(basename "$desktop_file")"
            local target="$AUTOSTART_DIR/$filename"
            
            if [[ -f "$target" ]]; then
                rm "$target"
                echo "  $filename - removed"
                ((removed++))
            fi
        fi
    done
    
    echo ""
    echo "Removal complete: $removed entries removed"
}

list_entries() {
    echo "Available desktop entries in $SCRIPT_DIR:"
    echo ""
    
    for desktop_file in "$SCRIPT_DIR"/*.desktop; do
        if [[ -f "$desktop_file" ]]; then
            local filename="$(basename "$desktop_file")"
            local name="$(grep "^Name=" "$desktop_file" | cut -d'=' -f2-)"
            local target="$AUTOSTART_DIR/$filename"
            local status="not installed"
            
            if [[ -f "$target" ]]; then
                if grep -q "^Hidden=true" "$target"; then
                    status="installed (disabled)"
                else
                    status="installed (enabled)"
                fi
            fi
            
            printf "  %-20s %-30s %s\n" "$filename" "$name" "$status"
        fi
    done
}

enable_entry() {
    local app_name="$1"
    local desktop_file="$app_name.desktop"
    local source="$SCRIPT_DIR/$desktop_file"
    local target="$AUTOSTART_DIR/$desktop_file"
    
    if [[ ! -f "$source" ]]; then
        echo "Error: Desktop file not found: $source"
        exit 1
    fi
    
    # Create autostart directory if it doesn't exist
    mkdir -p "$AUTOSTART_DIR"
    
    # Copy and enable
    cp "$source" "$target"
    
    # Remove Hidden=true if it exists
    sed -i '/^Hidden=true/d' "$target"
    
    # Ensure it's enabled
    if ! grep -q "^Hidden=" "$target"; then
        echo "Hidden=false" >> "$target"
    fi
    
    chmod 644 "$target"
    echo "Enabled autostart for: $app_name"
}

disable_entry() {
    local app_name="$1"
    local desktop_file="$app_name.desktop"
    local target="$AUTOSTART_DIR/$desktop_file"
    
    if [[ ! -f "$target" ]]; then
        echo "Error: Autostart entry not found: $target"
        exit 1
    fi
    
    # Set Hidden=true to disable
    if grep -q "^Hidden=" "$target"; then
        sed -i 's/^Hidden=.*/Hidden=true/' "$target"
    else
        echo "Hidden=true" >> "$target"
    fi
    
    echo "Disabled autostart for: $app_name"
}

# Parse arguments
COMMAND="install"
APP_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        remove|list|enable|disable)
            COMMAND="$1"
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            if [[ -z "$APP_NAME" ]]; then
                APP_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Execute command
case "$COMMAND" in
    install)
        install_entries
        ;;
    remove)
        remove_entries
        ;;
    list)
        list_entries
        ;;
    enable)
        if [[ -z "$APP_NAME" ]]; then
            echo "Error: App name required for enable command"
            print_usage
            exit 1
        fi
        enable_entry "$APP_NAME"
        ;;
    disable)
        if [[ -z "$APP_NAME" ]]; then
            echo "Error: App name required for disable command"
            print_usage
            exit 1
        fi
        disable_entry "$APP_NAME"
        ;;
    *)
        echo "Error: Unknown command: $COMMAND"
        print_usage
        exit 1
        ;;
esac
