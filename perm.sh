#!/bin/bash

#########################################################
#							#
# Script para alterar permissões para um grupo		#
# Ajuste de permissões em servidores de Arquivos	#
# que somente um grupo deve ter acesso ao conteúdo	#
#							#
#########################################################


data=$(date +%Y-%m-%d)
logfile=/var/log/permissions_$data.log

if [ "$(id -u)" != "0" ]; then
	echo "Not enough permissions to run this script." >> logfile 2>&1
	exit
fi

echo "Changing permissions to all server files ..." >> $logfile
chgrp watchers -v -R /media/watchers/* >> $logfile 2>&1
chmod g+srw -v -R /media/watchers/* >> $logfile 2>&1
echo "Permission script completed." >> $logfile
