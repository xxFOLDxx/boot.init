# Init Scripts (Legacy System V)

Traditional SysV init scripts for systems that don't use systemd. These are typically found in `/etc/init.d/` and controlled with `service` commands.

## Quick Setup

1. Copy script to `/etc/init.d/`
2. Make executable: `chmod +x /etc/init.d/script-name`
3. Enable for boot: `update-rc.d script-name defaults`

```bash
# Install init script
sudo cp my-service /etc/init.d/
sudo chmod +x /etc/init.d/my-service
sudo update-rc.d my-service defaults

# Control service
sudo service my-service start
sudo service my-service stop
sudo service my-service restart
sudo service my-service status
```

## Script Structure

Init scripts should support these operations:
- `start` - Start the service
- `stop` - Stop the service  
- `restart` - Restart the service
- `reload` - Reload configuration
- `status` - Show service status

## Examples Included

- `dev-service` - Development service template
- `backup-daemon` - Backup daemon script
- `custom-app` - Custom application launcher

## LSB Headers

Include LSB (Linux Standard Base) headers for proper dependency management:

```bash
### BEGIN INIT INFO
# Provides:          my-service
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: My custom service
# Description:       Detailed description of the service
### END INIT INFO
```

## Run Levels

- 0: Halt
- 1: Single-user mode
- 2-5: Multi-user mode
- 6: Reboot

## Best Practices

- Use absolute paths
- Include proper error handling
- Create PID files for daemon processes
- Use proper exit codes
- Include logging
- Test all operations (start, stop, restart, status)

## Modern Alternative

Consider using systemd services instead of init scripts on modern systems for better features and integration.
