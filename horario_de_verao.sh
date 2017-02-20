#!/bin/bash

uid=$(id -u)

if [[ $uid != 0 ]]; then
    echo "Apenas o root pode mudar a hora do sistema."
    exit;
fi

date_data=$(date | grep -oP '([0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2})')
hora_atual=$(echo $date_data | grep -oP '[^:]*' | head -n1)
resto=$(echo $date_data | grep -oP '(?<=:).+')

echo "A hora atual se encontra em $hora_atual horas."
echo -n "Alterar [ + / - ]: "
read choice

echo $choice
if [ "$choice" != "+" ] && [ "$choice" != "-" ]; then
    echo "Nenhuma opcao valida fornecida.";
    exit;
fi

if [ "$choice" == "+" ]; then
    hora_nova=$((hora_atual+1));
    hora_nova=$((hora_nova % 24))

    #  Avoid errors
    if [[ $hora_nova == 0 ]]; then
        hora_nova="00"
    fi

    echo "Ajustando hora para $hora_nova:$resto ...";
    date +%T -s "$hora_nova:$resto" > /dev/null 2>&1

    exit;
else
    hora_nova=$((hora_atual-1));
    hora_nova=$((hora_nova % 24));


    #  Avoid errors
    if [[ $hora_nova == 0 ]]; then
        hora_nova="00";
    fi

    echo "Ajustando hora para $hora_nova:$resto ...";
    date +%T -s "$hora_nova:$resto" > /dev/null 2>&1
    exit;
fi

