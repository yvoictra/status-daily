#!/bin/bash

# Load the configuration file

. /usr/local/bin/status-daily/status-daily.config

# Prepare the e-mail

ipv4=`curl -s -4 icanhazip.com`
ipv6=`curl -s -6 icanhazip.com`

from_email="From: `hostname` <admin@`hostname --fqdn`>"

if [ -z "$ipv6" ]
then
	subject_email="`hostname` - Daily Status Report [$ipv4]"
else
	subject_email="`hostname` - Daily Status Report [$ipv4 | $ipv6]"
fi

echo "<html><body><pre>" > /tmp/status_daily.txt

echo "################################################################################" >> /tmp/status_daily.txt
echo "# vnstat Statistics" >> /tmp/status_daily.txt
echo "################################################################################" >> /tmp/status_daily.txt

# Prepare vnstat output

VNSTAT_IFS=`vnstat --iflist | sed -E 's/^[^:]+:[ \t]+//' | sed -E 's/lo //' | sed -E 's/\(.+\) //'`

for VNSTAT_IF in $VNSTAT_IFS
do
	vnstat -y -i $VNSTAT_IF >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt

	vnstat -m -i $VNSTAT_IF >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt

	vnstat -d -i $VNSTAT_IF >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt

	vnstat -h -i $VNSTAT_IF >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt

	vnstat -hg -i $VNSTAT_IF >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt

	echo "################################################################################" >> /tmp/status_daily.txt
done

echo "################################################################################" >> /tmp/status_daily.txt
echo "# fail2ban Statistics" >> /tmp/status_daily.txt
echo "################################################################################" >> /tmp/status_daily.txt

# Prepare fail2ban output

JAILS=`fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g'`
for JAIL in $JAILS
do
	fail2ban-client status $JAIL >> /tmp/status_daily.txt
	echo -n "bantime: " >> /tmp/status_daily.txt
	fail2ban-client get $JAIL bantime >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt
done

# Send mail statistics

echo "################################################################################" >> /tmp/status_daily.txt
echo "# Mail Statistics" >> /tmp/status_daily.txt
echo "################################################################################" >> /tmp/status_daily.txt

cat $(find /var/log/ -type f ! -name "*.gz" -name "mail.log*" 2> /dev/null) | /usr/sbin/pflogsumm -d yesterday >> /tmp/status_daily.txt

echo "</pre></body></html>" >> /tmp/status_daily.txt

# Send mail

mail -a "Content-type: text/html;" -a "$from_email" -s "$subject_email" $dest_email < /tmp/status_daily.txt
