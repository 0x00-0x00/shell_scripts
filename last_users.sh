#!/bin/bash
uid=$(whoami)
echo "Current user: $uid"
if [ "$uid" != "root" ];
	then
		echo "Only root user can see logs content."
		exit
fi

echo "Last users to login:"
cat /var/log/auth.log | grep opened | awk {'print $11'} | sort | uniq

exit
