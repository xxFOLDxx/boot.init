# Linux Boot Automation Workspace

This workspace provides multiple solutions for automatically starting programs and performing tasks when your Linux machine boots up.

## Available Solutions

### 1. Systemd Services (`systemd-services/`)
- Custom systemd service files for running programs at boot
- Examples for different types of applications (GUI, CLI, background services)
- Service management scripts

### 2. Desktop Autostart (`desktop-autostart/`)
- XDG autostart desktop entries for GUI applications
- User-specific autostart configuration

### 3. Shell Startup Scripts (`shell-scripts/`)
- Bash/Fish profile scripts for terminal-based automation
- Environment setup and aliases

### 4. Cron Jobs (`cron-jobs/`)
- System and user crontab examples for scheduled tasks
- Boot-time execution with @reboot

### 5. Init Scripts (`init-scripts/`)
- Traditional SysV init scripts (for older systems)
- Custom startup scripts

### 6. Configuration Files (`config/`)
- Sample configuration files for various scenarios
- Environment variables and settings

## Quick Start

1. Choose the appropriate method for your needs:
   - **Systemd Services**: For system-wide services and background processes
   - **Desktop Autostart**: For GUI applications that should start with your desktop session
   - **Shell Scripts**: For terminal-based automation and environment setup
   - **Cron Jobs**: For scheduled tasks and simple boot-time commands

2. Copy and customize the example files
3. Follow the installation instructions in each directory

## Installation Methods

### Method 1: Interactive Setup Script
```bash
./setup.sh
```

### Method 2: Manual Installation
Follow the README files in each subdirectory for manual setup.

## Security Considerations

- Always review scripts before running them
- Use appropriate file permissions (644 for configs, 755 for executables)
- Run services with minimal required privileges
- Consider using systemd user services when possible

## Troubleshooting

- Check systemd service status: `systemctl status service-name`
- View logs: `journalctl -u service-name`
- Test autostart: Log out and back in
- Debug shell scripts: Add `set -x` for verbose output

## Examples Included

- Start a web server at boot
- Launch development environment
- Mount network drives
- Set up development tools
- Configure display settings
- Start monitoring tools
