# Desktop Autostart

XDG autostart is the standard way to automatically start GUI applications when a user logs into their desktop session.

## How It Works

Desktop entries placed in `~/.config/autostart/` will be automatically executed when the user logs in to their desktop environment (GNOME, KDE, XFCE, etc.).

## Quick Setup

1. Copy `.desktop` files to `~/.config/autostart/`
2. Make sure they have the correct permissions (644)
3. Log out and back in to test

```bash
# Install autostart entries
./install-autostart.sh

# Remove autostart entries
./install-autostart.sh remove
```

## Examples Included

- `terminal.desktop` - Open terminal with development environment
- `browser.desktop` - Launch web browser with specific tabs
- `ide.desktop` - Start your preferred IDE
- `notes.desktop` - Open note-taking application
- `music.desktop` - Start music player
- `monitoring.desktop` - Launch system monitor

## Desktop Entry Format

```ini
[Desktop Entry]
Type=Application
Name=Application Name
Exec=command-to-run
Icon=application-icon
Comment=Description of what this does
Categories=Category;
StartupNotify=true
NoDisplay=false
Hidden=false
X-GNOME-Autostart-enabled=true
```

## Key Fields

- **Type**: Usually "Application"
- **Name**: Display name for the application
- **Exec**: Command to execute
- **Icon**: Icon to display (optional)
- **Hidden**: Set to true to disable without deleting
- **StartupNotify**: Whether to show startup notification
- **NoDisplay**: Hide from application menus

## Conditional Execution

You can make autostart entries conditional:

- **OnlyShowIn**: Only run in specific desktop environments
- **NotShowIn**: Don't run in specific desktop environments
- **TryExec**: Only run if command exists

## Troubleshooting

- Check if files are in `~/.config/autostart/`
- Verify file permissions (should be readable)
- Test commands manually first
- Check desktop environment logs
- Use `Hidden=true` to temporarily disable
