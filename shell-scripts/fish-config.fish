# Fish Shell Configuration
# Place this in ~/.config/fish/config.fish

# Environment Variables
set -x EDITOR vim
set -x BROWSER firefox
set -x PAGER less

# Development Environment
set -x PROJECTS_DIR "$HOME/projects"
set -x DEV_TOOLS_DIR "$HOME/.local/bin"

# Add development tools to PATH
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.npm-global/bin"
fish_add_path "$HOME/go/bin"

# Node.js configuration
set -x NPM_CONFIG_PREFIX "$HOME/.npm-global"

# Python configuration
set -x PYTHONPATH "$HOME/.local/lib/python3.11/site-packages"

# Rust configuration
set -x RUST_SRC_PATH (rustc --print sysroot)/lib/rustlib/src/rust/src

# Go configuration
set -x GOPATH "$HOME/go"
set -x GOBIN "$GOPATH/bin"

# Docker configuration
set -x DOCKER_BUILDKIT 1

# Common Aliases
alias ll 'ls -la'
alias la 'ls -A'
alias l 'ls -CF'
alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'

# Git aliases
alias gs 'git status'
alias ga 'git add'
alias gc 'git commit'
alias gp 'git push'
alias gl 'git log --oneline'
alias gd 'git diff'

# Development aliases
alias serve 'python3 -m http.server 8000'
alias ports 'netstat -tuln'
alias myip 'curl -s ipinfo.io/ip'

# System aliases
alias df 'df -h'
alias du 'du -h'
alias free 'free -h'
alias ps 'ps aux'

# Quick directory navigation
alias projects 'cd $PROJECTS_DIR'
alias downloads 'cd ~/Downloads'
alias docs 'cd ~/Documents'

# Development Functions
function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
end

function extract
    switch $argv[1]
        case '*.tar.bz2'
            tar xjf $argv[1]
        case '*.tar.gz'
            tar xzf $argv[1]
        case '*.bz2'
            bunzip2 $argv[1]
        case '*.rar'
            unrar x $argv[1]
        case '*.gz'
            gunzip $argv[1]
        case '*.tar'
            tar xf $argv[1]
        case '*.tbz2'
            tar xjf $argv[1]
        case '*.tgz'
            tar xzf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*.Z'
            uncompress $argv[1]
        case '*.7z'
            7z x $argv[1]
        case '*'
            echo "Unknown archive format: $argv[1]"
    end
end

function backup
    if test (count $argv) -eq 0
        echo "Usage: backup <file_or_directory>"
        return 1
    end
    
    set backup_name "$argv[1].backup.(date +%Y%m%d_%H%M%S)"
    cp -r $argv[1] $backup_name
    echo "Backup created: $backup_name"
end

function find_large_files
    set size (test (count $argv) -gt 0; and echo $argv[1]; or echo "100M")
    find . -type f -size +$size -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
end

function weather
    set location (test (count $argv) -gt 0; and echo $argv[1]; or echo "")
    curl -s "wttr.in/$location"
end

# Startup Tasks
if status is-interactive
    # Display system information on startup
    echo "Welcome back! System status:"
    echo "  Date: "(date)
    echo "  Uptime: "(uptime | cut -d',' -f1 | cut -d' ' -f4-)
    echo "  Disk: "(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')
    echo "  Load: "(cat /proc/loadavg | cut -d' ' -f1-3)
    echo ""
    
    # Check for system updates (uncomment if desired)
    # if command -q apt
    #     set updates (apt list --upgradable 2>/dev/null | wc -l)
    #     if test $updates -gt 1
    #         echo "📦 $updates package updates available"
    #     end
    # end
    
    # Check if in projects directory, if not, offer to go there
    if test (pwd) = $HOME
        echo "💡 Tip: Type 'projects' to go to your projects directory"
    end
end

# Prompt customization (optional)
function fish_greeting
    # Override default greeting
    # echo "🐟 Fish shell ready for development!"
end

# Custom prompt (uncomment to use)
# function fish_prompt
#     set_color $fish_color_cwd
#     echo -n (basename (prompt_pwd))
#     set_color normal
#     echo -n ' $ '
# end
