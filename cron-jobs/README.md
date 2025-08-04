# Cron Jobs for Boot and Scheduled Tasks

Cron is a time-based job scheduler that can run tasks at boot time and on regular schedules.

## Quick Setup

1. Edit your crontab:
   ```bash
   crontab -e
   ```

2. Add entries from the examples below

3. View your current crontab:
   ```bash
   crontab -l
   ```

## Cron Time Format

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │
# * * * * * command to run
```

## Special Time Strings

- `@reboot` - Run once at startup
- `@yearly` or `@annually` - Run once a year (0 0 1 1 *)
- `@monthly` - Run once a month (0 0 1 * *)
- `@weekly` - Run once a week (0 0 * * 0)
- `@daily` or `@midnight` - Run once a day (0 0 * * *)
- `@hourly` - Run once an hour (0 * * * *)

## Examples Included

- `boot-tasks.cron` - Tasks to run at boot time
- `maintenance.cron` - Regular maintenance tasks
- `backup.cron` - Backup schedules
- `monitoring.cron` - System monitoring tasks

## Environment Variables

Cron runs with a minimal environment. Set variables at the top of your crontab:

```cron
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=user@example.com
HOME=/home/username
```

## Logging

- System cron logs: `/var/log/cron` or `/var/log/syslog`
- Mail output: Check your mail with `mail` command
- Custom logging: Redirect output in your cron command

```cron
0 2 * * * /path/to/script.sh >> /var/log/myscript.log 2>&1
```

## Installation

```bash
# Install all cron jobs
./install-cron.sh

# Install specific cron job
./install-cron.sh boot-tasks

# Remove all cron jobs
./install-cron.sh remove
```

## Troubleshooting

- Check cron service: `systemctl status cron`
- View cron logs: `journalctl -u cron`
- Test scripts manually first
- Use absolute paths in scripts
- Set proper permissions on scripts (755)
- Check environment variables
