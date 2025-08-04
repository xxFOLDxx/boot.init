# Development-specific Fish configuration
# Place this in ~/.config/fish/conf.d/dev-aliases.fish

# Docker aliases
alias dps 'docker ps'
alias dpsa 'docker ps -a'
alias di 'docker images'
alias drm 'docker rm'
alias drmi 'docker rmi'
alias dlog 'docker logs'
alias dexec 'docker exec -it'

# Docker Compose aliases
alias dc 'docker-compose'
alias dcu 'docker-compose up'
alias dcd 'docker-compose down'
alias dcb 'docker-compose build'
alias dcl 'docker-compose logs'

# Git workflow functions
function gac
    git add .
    git commit -m "$argv"
end

function gacp
    git add .
    git commit -m "$argv"
    git push
end

function gnb
    git checkout -b $argv[1]
    git push -u origin $argv[1]
end

function gclean
    git branch --merged | grep -v "\*\|master\|main\|develop" | xargs -n 1 git branch -d
end

# Node.js/npm functions
function nrs
    npm run start
end

function nrd
    npm run dev
end

function nrb
    npm run build
end

function nrt
    npm run test
end

function ni
    npm install $argv
end

function nid
    npm install --save-dev $argv
end

# Python functions
function py
    python3 $argv
end

function venv
    python3 -m venv $argv[1]
    source $argv[1]/bin/activate.fish
end

function pip-upgrade-all
    pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U
end

# Project management functions
function new-project
    if test (count $argv) -eq 0
        echo "Usage: new-project <project-name> [template]"
        return 1
    end
    
    set project_name $argv[1]
    set template (test (count $argv) -gt 1; and echo $argv[2]; or echo "basic")
    
    mkdir -p "$PROJECTS_DIR/$project_name"
    cd "$PROJECTS_DIR/$project_name"
    
    switch $template
        case "node" "nodejs"
            npm init -y
            mkdir src tests docs
            echo "node_modules/\n.env\n*.log" > .gitignore
        case "python"
            python3 -m venv venv
            mkdir src tests docs
            echo "venv/\n__pycache__/\n*.pyc\n.env" > .gitignore
            echo "# $project_name\n\nA Python project." > README.md
        case "rust"
            cargo init .
        case "go"
            go mod init $project_name
            mkdir cmd internal pkg
        case "*"
            mkdir src tests docs
            echo "# $project_name\n\nA new project." > README.md
    end
    
    git init
    git add .
    git commit -m "Initial commit"
    
    echo "Created new $template project: $project_name"
end

# System monitoring aliases
alias top 'htop'
alias iotop 'sudo iotop'
alias nethogs 'sudo nethogs'
alias meminfo 'cat /proc/meminfo'
alias cpuinfo 'cat /proc/cpuinfo'

# Network utilities
function port-check
    if test (count $argv) -eq 0
        echo "Usage: port-check <port>"
        return 1
    end
    
    netstat -tuln | grep ":$argv[1] "
end

function kill-port
    if test (count $argv) -eq 0
        echo "Usage: kill-port <port>"
        return 1
    end
    
    set pid (lsof -ti:$argv[1])
    if test -n "$pid"
        kill -9 $pid
        echo "Killed process on port $argv[1]"
    else
        echo "No process found on port $argv[1]"
    end
end

# File operations
function watch-file
    if test (count $argv) -eq 0
        echo "Usage: watch-file <file> [command]"
        return 1
    end
    
    set file $argv[1]
    set cmd (test (count $argv) -gt 1; and echo $argv[2..]; or echo "echo File changed: $file")
    
    while inotifywait -e modify "$file" >/dev/null 2>&1
        eval $cmd
    end
end

# Quick web server
function webserver
    set port (test (count $argv) -gt 0; and echo $argv[1]; or echo "8000")
    set dir (test (count $argv) -gt 1; and echo $argv[2]; or echo ".")
    
    echo "Starting web server on port $port serving $dir"
    echo "Access at: http://localhost:$port"
    
    cd $dir
    python3 -m http.server $port
end

# Log viewing
function logs
    set service $argv[1]
    
    if test -z "$service"
        journalctl -f
    else
        journalctl -u $service -f
    end
end

# Quick backup function
function qbackup
    set timestamp (date +%Y%m%d_%H%M%S)
    tar -czf "backup_$timestamp.tar.gz" $argv
    echo "Backup created: backup_$timestamp.tar.gz"
end
