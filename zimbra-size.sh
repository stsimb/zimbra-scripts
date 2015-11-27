#!/bin/bash
# script to report zimbra mailbox size per folder for a specific user
# based on info at http://www.zimbra.com/forums/administrators/23655-per-folder-size-command-line.html#post121758
# stsimb feb 2014

PATH=/opt/zimbra/bin:/bin:/usr/bin

if [ "$(id -un)x" != "zimbrax" ]; then
  echo "Fatal error: This script needs to run as user zimbra."
  exit 1
fi

if [ $# == 0 ] ; then
  echo "Report zimbra mailbox size per folder for a specific user"
  echo
  echo "Usage = $0 username"
  echo 
  exit 1
fi

USER=$1

backend="$(zmprov ga ${USER} zimbraMailHost | tail -2 | awk '{print $2}')"
if [ "${backend}x" != "$(zmhostname)x" ]; then
  echo "Fatal error: need to run on ${backend} for ${USER}."
  exit 1
fi

quota="$(expr `zmprov ga ${USER} zimbraMailQuota | tail -2 | awk '{print $2}'` / 1024 / 1024)"
size="$(zmmailbox -z -m ${USER} gms)"
echo "${USER}'s max mailbox size = ${quota} MB, current mailbox size = ${size}."
echo

TF=$(mktemp)
zimbraID="$(zmprov ga ${USER} zimbraID | tail -2 | awk '{print $2}')"
rm -f ${TF}
zmmailbox -z -m ${USER} gaf | grep mess | egrep -v "\(.*@.*:2\)" > ${TF}
echo "size (MB)  msgcount     unread folder"
echo "--------- --------- ---------- ----------------------------"
while read line ; do
  folder="$(echo ${line} | awk '{print $5,$6,$7,$8,$9}')"
  msgcount="$(echo ${line} | awk '{print $4}')"
  unread="$(echo ${line} | awk '{print $3}')"
  fid=$(echo ${line} | awk '{print $1}')
  if [ ! -z "${fid##*[!0-9]*}" ]; then
    if [ "x${msgcount}" != "x0" ]; then
      mboxinfo=$(mysql -N -e "select id, group_id from zimbra.mailbox where account_id=\"${zimbraID}\"")
      mboxid=$(echo ${mboxinfo} | awk '{print $1}')
      gid=$(echo ${mboxinfo} | awk '{print $2}')
      info=$(mysql -N -e "select size, metadata from mboxgroup${gid}.mail_item where mailbox_id=${mboxid} and id=${fid}")   
      size=$(echo ${info} | egrep -o ":szi.*:" | cut -d: -f2 | cut -c 4- | sed -e 's/e4$//')
      sizeMB="$(expr ${size} / 1024 / 1024 2>/dev/null)" # || echo 0)"
      sizeKB="$(expr ${size} / 1024 2>/dev/null)"
    else
      sizeMB="0"
      unset sizeKB
    fi
    if [ -z $sizeKB ]; then
      sizeMB="${sizeMB}"
    else
      sizeMB="${sizeMB}.`printf '%.3s' ${sizeKB}`"
    fi
    printf "%9s %9s %10s " ${sizeMB} ${msgcount} ${unread}
    echo ${folder}
#  else
#    echo "${folder} is shared, skipping"
  fi
done < ${TF}
rm -f ${TF}
