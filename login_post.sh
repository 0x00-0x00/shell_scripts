#!/bin/bash
#
# Script escrito por Andre Marques (zc00l) para realizar requests POST
# usando dados de payload
# ---------------------------------------------------------------------
#


function helpme {
    echo -e "\033[093mUso:\033[0m $0 -u URL -d POST_DATA";
    exit 0;
}

function log {
    echo -e "[\033[092m+\033[0m] INFO: $1";
    return 0;
}

function error {
    echo -e "[\033[091m!\033[0m] ERRO: $1";
    return 0;
}

if [[ $# < 2 ]]; then
    helpme;
fi


# Variables
URL=""
POST_DATA=""

while getopts "u:d:" opt; do
    case $opt in
        u)URL=$OPTARG; log "URL set to: '$OPTARG'";;
        d)POST_DATA=$OPTARG; log "POST DATA set to: '$OPTARG'";;
    esac;
done

if [[ $URL == "" ]] || [[ $POST_DATA == "" ]]; then
    error "Faltam valores para as variáveis.";
    exit 0;
fi

wget $URL --post-data=$POST_DATA;
if [[ $? == 0 ]]; then
    log "Request enviada com sucesso!";
else
    error "Não foi possível enviar a request.";
fi
exit 0;

