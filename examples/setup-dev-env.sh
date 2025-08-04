#!/bin/bash
set -euo pipefail

# Development Environment Setup Script
# This script initializes a complete development environment

SCRIPT_NAME="$(basename "$0")"
LOG_FILE="$HOME/logs/dev-env-setup.log"
PROJECTS_DIR="$HOME/projects"
TOOLS_DIR="$HOME/.local/bin"

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "Starting development environment setup..."

# Create project directories
log "Creating project directories..."
mkdir -p "$PROJECTS_DIR"/{active,archived,templates,playground}
mkdir -p "$HOME"/{logs,backups,tmp,scripts}
mkdir -p "$TOOLS_DIR"

# Set up development tools paths
log "Configuring development paths..."
export PATH="$TOOLS_DIR:$HOME/.cargo/bin:$HOME/.npm-global/bin:$HOME/go/bin:$PATH"

# Check and install development tools
check_and_install() {
    local tool="$1"
    local install_cmd="$2"
    
    if ! command -v "$tool" >/dev/null 2>&1; then
        log "Installing $tool..."
        eval "$install_cmd" || log "Failed to install $tool"
    else
        log "$tool is already installed"
    fi
}

# Git configuration
if command -v git >/dev/null 2>&1; then
    log "Configuring Git..."
    git config --global init.defaultBranch main 2>/dev/null || true
    git config --global pull.rebase false 2>/dev/null || true
    git config --global core.editor "code --wait" 2>/dev/null || true
fi

# Node.js global packages
if command -v npm >/dev/null 2>&1; then
    log "Setting up Node.js global packages..."
    npm config set prefix "$HOME/.npm-global" 2>/dev/null || true
    
    # Install common global packages
    for package in nodemon live-server http-server json-server; do
        if ! npm list -g "$package" >/dev/null 2>&1; then
            log "Installing $package globally..."
            npm install -g "$package" 2>/dev/null || log "Failed to install $package"
        fi
    done
fi

# Python development setup
if command -v python3 >/dev/null 2>&1; then
    log "Setting up Python development environment..."
    
    # Ensure pip is available
    if ! command -v pip3 >/dev/null 2>&1; then
        log "Installing pip..."
        curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 - --user || log "Failed to install pip"
    fi
    
    # Install common development packages
    for package in virtualenv black flake8 pytest mypy; do
        if ! pip3 show "$package" >/dev/null 2>&1; then
            log "Installing $package..."
            pip3 install --user "$package" 2>/dev/null || log "Failed to install $package"
        fi
    done
fi

# Docker setup (if available)
if command -v docker >/dev/null 2>&1; then
    log "Configuring Docker..."
    
    # Add user to docker group if not already there
    if ! groups | grep -q docker; then
        log "Adding user to docker group (requires logout/login to take effect)"
        sudo usermod -aG docker "$USER" 2>/dev/null || log "Failed to add user to docker group"
    fi
    
    # Start docker service if not running
    if ! systemctl is-active --quiet docker 2>/dev/null; then
        log "Starting Docker service..."
        sudo systemctl start docker 2>/dev/null || log "Failed to start Docker service"
    fi
fi

# VS Code extensions (if VS Code is available)
if command -v code >/dev/null 2>&1; then
    log "Installing VS Code extensions..."
    
    extensions=(
        "ms-python.python"
        "ms-vscode.vscode-typescript-next"
        "bradlc.vscode-tailwindcss"
        "esbenp.prettier-vscode"
        "ms-vscode.vscode-eslint"
        "ms-vscode.vscode-json"
        "redhat.vscode-yaml"
        "ms-vscode.vscode-docker"
        "gitpod.gitpod-desktop"
    )
    
    for ext in "${extensions[@]}"; do
        if ! code --list-extensions | grep -q "$ext"; then
            log "Installing VS Code extension: $ext"
            code --install-extension "$ext" 2>/dev/null || log "Failed to install $ext"
        fi
    done
fi

# SSH key setup (if not exists)
if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    log "Generating SSH key..."
    read -p "Enter your email for SSH key: " -r email
    if [ -n "$email" ]; then
        ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N "" || log "Failed to generate SSH key"
        log "SSH key generated. Add the public key to your Git services:"
        log "$(cat "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || echo "Failed to read public key")"
    fi
fi

# Create useful aliases and functions script
cat > "$TOOLS_DIR/dev-utils.sh" << 'EOF'
#!/bin/bash

# Development utility functions

# Quick project creation
new_project() {
    local name="$1"
    local type="${2:-basic}"
    
    if [ -z "$name" ]; then
        echo "Usage: new_project <name> [type]"
        return 1
    fi
    
    mkdir -p "$HOME/projects/active/$name"
    cd "$HOME/projects/active/$name"
    
    case "$type" in
        node)
            npm init -y
            mkdir src tests docs
            echo "node_modules/\n.env\n*.log" > .gitignore
            ;;
        python)
            python3 -m venv venv
            mkdir src tests docs
            echo "venv/\n__pycache__/\n*.pyc\n.env" > .gitignore
            ;;
        web)
            mkdir css js images docs
            touch index.html style.css script.js
            ;;
        *)
            mkdir src tests docs
            touch README.md
            ;;
    esac
    
    git init
    echo "# $name" > README.md
    git add .
    git commit -m "Initial commit"
    
    echo "Project $name created in $(pwd)"
}

# Quick server start
serve() {
    local port="${1:-8000}"
    local dir="${2:-.}"
    
    echo "Starting server on port $port serving $dir"
    echo "Access at: http://localhost:$port"
    
    if command -v python3 >/dev/null 2>&1; then
        cd "$dir" && python3 -m http.server "$port"
    elif command -v http-server >/dev/null 2>&1; then
        http-server "$dir" -p "$port"
    else
        echo "No suitable server found. Install python3 or http-server"
        return 1
    fi
}

# Git workflow helpers
gac() {
    git add .
    git commit -m "$*"
}

gacp() {
    git add .
    git commit -m "$*"
    git push
}

# Export functions
export -f new_project serve gac gacp
EOF

chmod +x "$TOOLS_DIR/dev-utils.sh"
log "Development utilities created at $TOOLS_DIR/dev-utils.sh"

# Start common development services
log "Starting development services..."

# Start database services if available
for service in postgresql mysql redis-server; do
    if systemctl list-unit-files "$service.service" >/dev/null 2>&1; then
        if ! systemctl is-active --quiet "$service" 2>/dev/null; then
            log "Starting $service..."
            sudo systemctl start "$service" 2>/dev/null || log "Failed to start $service"
        fi
    fi
done

# Create development workspace in VS Code
if command -v code >/dev/null 2>&1; then
    log "Opening development workspace..."
    code "$PROJECTS_DIR" &
fi

log "Development environment setup complete!"
log "Log file: $LOG_FILE"

echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "What was configured:"
echo "  ✓ Project directories created"
echo "  ✓ Development tools configured"
echo "  ✓ Git settings applied"
echo "  ✓ VS Code extensions installed"
echo "  ✓ Utility functions created"
echo ""
echo "Next steps:"
echo "  1. Source the utilities: source $TOOLS_DIR/dev-utils.sh"
echo "  2. Add SSH key to Git services (if generated)"
echo "  3. Start a new project: new_project my-app node"
echo "  4. Check the log: cat $LOG_FILE"
echo ""
