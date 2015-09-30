#!/bin/bash
 
# a zimbra mailbox server to make admin requests (can be localhost or remote)
ZADMIN="https://zm-mbox-01:7071"
# set default quota in MB
DEFAULTQUOTA=3072

# exit if no param
if [ "x$1" == "x" ]; then
 	echo "USAGE = $0 username [newQuota]"
	exit 1
fi

# if second param given, skip interactive part
if [ "x$2" != "x" ]; then
	newQuota=$2
else
	# get current mailbox usage
	echo -n "Current usage: "
	size="$(zmmailbox -u ${ZADMIN} -z -m $1 gms || echo 0)"
	echo "${size}"
	# get current quota
	echo -n "Current quota: "
	actualQuota="$((zmprov ga $1 zimbraMailQuota || echo 0) | grep -v "#" |cut -d ":" -f 2 | head -n 1|sed -e 's/ //g')"
	let dispQuota=$actualQuota/1024/1024
	echo "$dispQuota MB"
	# read new quota
	echo -n "New Quota (in MB)? "
	read newQuota
fi

# cancel if no input
if [ "x${newQuota}" == "x" ]; then
	echo "cancel, keeping existing quota."
	exit
fi

let newQuota=$newQuota*1024*1024

# issue warning if new quota is below our default
if [ ${newQuota} -lt $((${DEFAULTQUOTA}*1024*1024)) ]; then
	echo "WARNING: setting quota below our default (${DEFAULTQUOTA} MB)"
fi

# change the quota
zmprov ma $1 zimbraMailQuota $newQuota
echo "New quota for $1 = $((${newQuota}/1024/1024)) MB"
