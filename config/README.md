# Configuration Files

Sample configuration files for various boot automation scenarios.

## Environment Configuration

- `environment.conf` - System environment variables
- `dev-env.conf` - Development environment settings
- `network.conf` - Network configuration
- `paths.conf` - Custom PATH configurations

## Service Configuration

- `web-server.conf` - Web server settings
- `backup.conf` - Backup configuration
- `monitoring.conf` - Monitoring settings

## User Configuration

- `user-settings.conf` - User-specific settings
- `aliases.conf` - Command aliases
- `functions.conf` - Shell function definitions

## Usage

1. Copy configuration files to appropriate locations
2. Customize values for your system
3. Source or reference them in your scripts

## Common Locations

- System-wide: `/etc/default/`, `/etc/`
- User-specific: `~/.config/`, `~/`
- Service-specific: `/etc/systemd/system/`, `~/.config/systemd/user/`

## Environment File Format

```bash
# Environment variables
VAR_NAME=value
ANOTHER_VAR="value with spaces"

# Comments start with #
# Export variables if needed
export EXPORTED_VAR=value
```

## Systemd Environment Files

Systemd uses a specific format for environment files:

```bash
# No export keyword
# No quotes unless containing special characters
VARIABLE=value
QUOTED_VAR="value with spaces"
```
