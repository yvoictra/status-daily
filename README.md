# status-daily

# Packages needed

- vnstat
- fail2ban
- mail

# Crontab

    0 6 * * * /usr/local/bin/status-daily/status-daily.sh >> /dev/null 2>&1
