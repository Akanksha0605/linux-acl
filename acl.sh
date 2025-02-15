#! /bin/bash

#install packages

yum -y install nfs4-acl-tools acl libacl

#Find on which filesystem /var/log is mounted
FS="$(df -h /var/log | awk 'NR==2 {print $1}')"

#Find UUID
UUID="$(lsblk -d -fs $FS | awk 'NR==2 {print $3}')"

#Find the UUID and matching line number in /etc/fstab
LINENUMBER="$(grep -n "$UUID" /etc/fstab | awk -F: '{print $1}')"

#Edit /etc/fstab with acl as mount option
#sed -i "${LINENUMBER}s/defaults /defaults,acl /" /etc/fstab

#Remounting the filesystem
mount -o remount ${FS}

#Set adam user & group to read /var/log
#setfacl -m u:adam:r /var/log
#setfacl -m g:adam:r /var/log

#To verify

aclstatus="$(getfacl /var/log)"
#echo ${aclstatus}

if grep -e 'user:adam:r—\|group:adam:r—‘ <<< $aclstatus ; then
  echo "ACL rules applied"
else
  echo "ACL rules NOT applied :("
fi
