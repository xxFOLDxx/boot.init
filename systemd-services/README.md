# Systemd Services

Systemd is the modern way to manage services on most Linux distributions. Services defined here will start automatically at boot.

## Quick Setup

1. Copy your service file to the appropriate location:
   - System services: `/etc/systemd/system/`
   - User services: `~/.config/systemd/user/`

2. Enable and start the service:
   ```bash
   # For system services
   sudo systemctl enable your-service.service
   sudo systemctl start your-service.service
   
   # For user services
   systemctl --user enable your-service.service
   systemctl --user start your-service.service
   ```

3. Check status and logs:
   ```bash
   systemctl status your-service.service
   journalctl -u your-service.service
   ```

## Examples Included

- `web-server.service` - Start a development web server
- `backup-service.service` - Run automated backups
- `development-env.service` - Set up development environment
- `network-mount.service` - Mount network drives
- `monitoring.service` - Start system monitoring
- `user-app.service` - User-specific application launcher

## Service Types

- **simple**: Default type, process doesn't fork
- **forking**: Process forks and parent exits
- **oneshot**: Process exits after completing task
- **notify**: Process sends readiness notification
- **idle**: Delayed start until other services complete

## Best Practices

- Use descriptive service names and descriptions
- Set appropriate dependencies with `After=` and `Requires=`
- Configure restart behavior with `Restart=`
- Use proper working directories and users
- Include environment variables when needed
- Add resource limits for security
