#!/bin/bash 

#variaveis de tempo
DATA=$(date +%Y-%m-%d)
ANO=$(date +%Y)
MES=$(date +%m)
DIA=$(date +%d)
ONTEM=$((DIA - 1))

#Variaves de condicao
diff_check=0

#Variaveis de IO
REPORT_FOLDER=/media/watchers/Arquivos/CONFIG/RaspberryPi/reports
FILE=/media/watchers/JORNAL_WATCHER
TREE_HOJE=$REPORT_FOLDER/tree_$ANO-$MES-$DIA.log
TREE_ONTEM=$REPORT_FOLDER/tree_$ANO-$MES-$ONTEM.log

#Variaveis do Jornal
JOURNAL_NAME="Jornal Watchers"
LINE_BREAK="________________________________________________________________"
BL=""

echo "Iniciando rotina de geração de jornal do servidor ..."

if [ -f $FILE ]; 
	then
		echo "Arquivando antigo jornal ..."
		mv $FILE /media/watchers/Arquivos/CONFIG/RaspberryPi/reports/jornal_$DATA.log
fi


echo "Gerando cabeçalho da nova edição do jornal ..."
echo "$JOURNAL_NAME edição $DATA" >> $FILE
echo "$LINE_BREAK" >> $FILE


echo $BL >> $FILE
echo $LINE_BREAK >> $FILE

echo "Novo arquivos: " >> $FILE
echo $LINE_BEAK >> $FILE
echo $BL >> $FILE
echo $BL >> $FILE

if [ -d "$REPORT_FOLDER" ]; then
	echo "Found report folder."
	
	if [ -f "$TREE_HOJE" ];
		then
			echo "Arvore de arquivos do dia atual encontrada."
			((diff_check++))
		else
			echo "Arvore de arquivos do dia atual não encontrada."
	fi

	if [ -f $TREE_ONTEM ];
		then
			echo "Arvore de arquivos de ontem encontrada."
			((diff_check++))
		else
			echo "Arvore de arquivos de ontem não encontrada."

	fi


	if [ $diff_check == "2" ];
		then
			diff $TREE_HOJE $TREE_ONTEM >> $FILE
	fi
	
	else
		echo "Pasta de logs não encontrada."
		exit

fi
echo $LINE_BREAK >> $FILE
echo $BL >> $FILE

echo "Consumo de banda:" >> $FILE
echo $LINE_BREAK >> $FILE
cat $REPORT_FOLDER/vnstat_$ANO-$MES-$DIA.log >> $FILE
echo $LINE_BREAK >> $FILE
echo $BL >> $FILE

echo $LINE_BREAK >> $FILE

echo "Últimos 30 usuários que se conectaram no sistema: " >> $FILE
echo $LINE_BREAK >> $FILE
last -n 30 >> $FILE
echo $LINE_BREAK >> $FILE
echo $BL >> $FILE

exit
