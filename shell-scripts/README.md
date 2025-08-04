# Shell Startup Scripts

Shell startup scripts run when you open a terminal session. They're perfect for setting up environment variables, aliases, and running commands that should be available in every terminal session.

## Shell Configuration Files

### Fish Shell (your current shell)
- `~/.config/fish/config.fish` - Main configuration file
- `~/.config/fish/conf.d/` - Additional configuration files

### Bash (fallback)
- `~/.bashrc` - Interactive shell configuration
- `~/.bash_profile` - Login shell configuration
- `~/.profile` - POSIX-compatible profile

## Quick Setup

1. Copy the example files to your home directory
2. Customize the settings for your needs
3. Source the files or restart your terminal

```bash
# Install shell configurations
./install-shell-config.sh

# Install just for current user
./install-shell-config.sh --user-only
```

## Examples Included

- `fish-config.fish` - Fish shell configuration with development setup
- `bashrc-example` - Bash configuration with aliases and functions
- `profile-example` - Environment variables and PATH setup
- `dev-aliases.fish` - Development-specific aliases and functions
- `startup-tasks.fish` - Commands to run on terminal startup

## Features

### Environment Setup
- Development tool paths
- Environment variables
- Project directories

### Aliases and Functions
- Common command shortcuts
- Development workflow helpers
- System administration shortcuts

### Startup Tasks
- Check system status
- Update development tools
- Mount network drives
- Start background services

## Customization

Edit the configuration files to:
- Add your own aliases
- Set custom environment variables
- Include your development tools
- Configure your preferred settings

## Fish Shell Specific

Fish shell uses a different syntax than bash:

```fish
# Set environment variable
set -x EDITOR vim

# Create alias
alias ll 'ls -la'

# Create function
function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
end
```
