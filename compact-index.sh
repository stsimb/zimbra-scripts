#!/bin/bash
# When the num of deleted docs are > 50,000, index compaction is recommended
# https://bugzilla.zimbra.com/show_bug.cgi?id=76414
# stsimb Sep 2015
#
export PATH="/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin"
SCRIPT_NAME=`basename $0`
LOCKFILE="/tmp/${SCRIPT_NAME}.lock"
[ -f ${LOCKFILE} ] && logger "$0 already running......" && echo "Already running..." && exit 1
date >  "${LOCKFILE}"

### REAL START SCRIPT #########################################################

THRESHOLD=50000

input=$(mktemp)
zmprov="/opt/zimbra/bin/zmprov"
zmaccts="/opt/zimbra/bin/zmaccts"

# get all active accounts
$zmaccts | awk '/@.*active/ {print $1}' | sort -u > ${input}

# process all accounts
for acct in $(cat ${input}); do
	echo -n "$(date) ${acct}"

	# getIndexStats
	stats="`$zmprov getIndexStats $acct`"
	echo -n " ${stats//:/ }"

	# compare with threshold
	numDeletedDocs=${stats##*:}
	if [ ${numDeletedDocs} -gt ${THRESHOLD} ]; then
		# start compact job
		echo -n " compact index "
		$zmprov compactIndexMailbox $acct start
	else
		# skip this account
		echo " skip index compaction."
	fi
done

rm -f "${input}"
### REAL END SCRIPT ###########################################################
### Please do not write below this line.

/bin/rm -f "${LOCKFILE}"
exit $?
