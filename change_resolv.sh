#!/bin/bash

function log
{
    echo -e "\033[092mINFO\033[0m: $1";
    return 0;
}

function error
{
    echo -e "\033[091mERROR\033[0m: $1";
    return 0;
}


uid=$(id -u);
if [[ $uid != 0 ]]; then
    error "Apenas o root pode alterar o arquivo /etc/resolv.conf!";
    exit 0;
fi

if [[ $1 == "" ]]; then
    error "Sem argumentos o suficiente.";
    log "Uso: $0 -s SERVER_DNS";
    exit 0;
fi

while getops "s:" opt; do
    case $opt in
        s)SERVER_DNS=$OPTARG; log "Servidor DNS definido em: $OPTARG";;
    esac
done

sed -i "s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/${SERVER_DNS}/g" /etc/resolv.conf
if [[ $? == 0 ]]; then
    log "DNS alterado com sucesso!";
else
    error "Nao foi possivel alterar o DNS.";
    exit 1;
fi

exit 0;
