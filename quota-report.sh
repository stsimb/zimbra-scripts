#!/bin/bash

input=$(mktemp)
output=$(mktemp)
email=$(mktemp)

sender="admin@zimbra.gr"
recipients="admin@zimbra.gr"
number=50

date=$(date +"%a, %d %b %Y %H:%M:%S %z (%Z)")
datef="$(date +%F)"

/opt/zimbra/bin/zmprov getQuotaUsage `zmhostname` | awk {'print $1" "$3" "$2'} >> ${input}

cat $input | sort -rn -k 2 | while read line
do
	usage=`echo $line | cut -f2 -d " "`
	quota=`echo $line | cut -f3 -d " "`
	user=`echo $line | cut -f1 -d " "`
	echo "`expr $usage / 1024 / 1024` of `expr $quota / 1024 / 1024` MB $user" >> ${output}
done

cat << EOF > ${email}
Date: ${date}
From: ${sender}
To: ${recipients}
Subject: Daily quota report for ${datef}

top ${number} mailboxes by disk usage (quota)
--------------------------------------
EOF

head -${number} ${output} >> ${email}
cat ${email} | /opt/zimbra/postfix/sbin/sendmail -t ${recipients}
rm -f ${input} ${output} ${email}
