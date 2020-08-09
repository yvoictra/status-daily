#!/bin/bash

. ./status-daily.config

from_email="From: `hostname` <admin@`hostname --fqdn`>"
subject_email="`hostname` - Daily Status Report"


echo "<html><body><pre>" > /tmp/status_daily.txt

VNSTAT_IFS=`vnstat --iflist | sed -E 's/^[^:]+:[ \t]+//' | sed -E 's/lo //' | sed -E 's/\(.+\) //'`

for VNSTAT_IF in $VNSTAT_IFS
do
	vnstat -m -i $VNSTAT_IF >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt

	vnstat -d -i $VNSTAT_IF >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt

	vnstat -h -i $VNSTAT_IF >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt
done

JAILS=`fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g'`
for JAIL in $JAILS
do
	fail2ban-client status $JAIL >> /tmp/status_daily.txt
	echo -n "bantime: " >> /tmp/status_daily.txt
	fail2ban-client get $JAIL bantime >> /tmp/status_daily.txt
	echo >> /tmp/status_daily.txt
done

echo "</pre></body></html>" >> /tmp/status_daily.txt

mail -a "Content-type: text/html;" -a "$from_email" -s "$subject_email" $dest_email < /tmp/status_daily.txt
