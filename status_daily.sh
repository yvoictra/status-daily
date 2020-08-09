#!/bin/bash

echo "<html><body><pre>" > /tmp/status_daily.txt

vnstat -m >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt

vnstat -d >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt

vnstat -h >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt

fail2ban-client status sshd >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt
echo -n "bantime: " >> /tmp/status_daily.txt
fail2ban-client get sshd bantime >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt

fail2ban-client status wordpress-soft >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt
echo -n "bantime: " >> /tmp/status_daily.txt
fail2ban-client get wordpress-soft bantime >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt

fail2ban-client status wordpress-hard >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt
echo -n "bantime: " >> /tmp/status_daily.txt
fail2ban-client get wordpress-hard bantime >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt

fail2ban-client status nginx-xmlrpc >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt
echo -n "bantime: " >> /tmp/status_daily.txt
fail2ban-client get nginx-xmlrpc bantime >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt

fail2ban-client status nginx-wp-login  >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt
echo -n "bantime: " >> /tmp/status_daily.txt
fail2ban-client get nginx-wp-login bantime >> /tmp/status_daily.txt
echo >> /tmp/status_daily.txt

#fail2ban-client status portscan >> /tmp/status_daily.txt
#echo >> /tmp/status_daily.txt
#echo -n "bantime: " >> /tmp/status_daily.txt
#fail2ban-client get portscan bantime >> /tmp/status_daily.txt

echo "</pre></body></html>" >> /tmp/status_daily.txt

mail -a "Content-type: text/html;" -a "From: 4cme <admin@4cme.cf>" -s "Acme - Daily Status Report" egomezm@gmail.com < /tmp/status_daily.txt
